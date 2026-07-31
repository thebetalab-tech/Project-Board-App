using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace Project_Board.Student
{
    public partial class Appeal : Page
    {
        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
        private int TaskId => Request.QueryString["TaskId"] != null ? Convert.ToInt32(Request.QueryString["TaskId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (TaskId == 0)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadTaskDetails();
            }
        }

        private void LoadTaskDetails()
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT t.TaskTitle, t.FeedbackText, t.TaskDescription, t.AssignedTo, u.FullName AS AssignedByName
                    FROM Task t
                    INNER JOIN Users u ON t.AssignedBy = u.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TaskId", TaskId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Security check: Only the assigned user can appeal
                            int assignedTo = Convert.ToInt32(reader["AssignedTo"]);
                            int currentUserId = Convert.ToInt32(Session["UserId"]);
                            if (assignedTo != currentUserId)
                            {
                                lblMessage.Text = "You are not authorized to appeal this task.";
                                lblMessage.CssClass = "alert alert-danger";
                                lblMessage.Visible = true;
                                btnSubmit.Enabled = false;
                            }

                            lblTaskTitle.Text = reader["TaskTitle"].ToString();
                            lblAssignorName.Text = reader["AssignedByName"].ToString();
                            
                            string feedback = reader["FeedbackText"] != DBNull.Value ? reader["FeedbackText"].ToString() : "";
                            string description = reader["TaskDescription"] != DBNull.Value ? reader["TaskDescription"].ToString() : "";
                            
                            lblFeedback.Text = string.IsNullOrEmpty(feedback) ? (string.IsNullOrEmpty(description) ? "No details provided." : description) : feedback;
                        }
                    }
                }
                
                // Load existing appeal draft if any
                string appealSql = "SELECT Reason, ChangesMade, Explanation, IsCompleted FROM Appeals WHERE TaskId = @TaskId AND StudentId = @StudentId";
                using (SqlCommand cmdAppeal = new SqlCommand(appealSql, conn))
                {
                    cmdAppeal.Parameters.AddWithValue("@TaskId", TaskId);
                    cmdAppeal.Parameters.AddWithValue("@StudentId", Convert.ToInt32(Session["UserId"]));
                    using (SqlDataReader rdr = cmdAppeal.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            txtReason.Text = rdr["Reason"].ToString();
                            txtChangesMade.Text = rdr["ChangesMade"].ToString();
                            txtExplanation.Text = rdr["Explanation"].ToString();
                            chkIsCompleted.Checked = rdr["IsCompleted"] != DBNull.Value && Convert.ToBoolean(rdr["IsCompleted"]);
                        }
                    }
                }
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (TaskId == 0) return;

            string reason = txtReason.Text.Trim();
            string changesMade = txtChangesMade.Text.Trim();
            string explanation = txtExplanation.Text.Trim();
            bool isCompleted = chkIsCompleted.Checked;
            int studentId = Convert.ToInt32(Session["UserId"]);

            if (string.IsNullOrEmpty(reason))
            {
                lblMessage.Text = "Please provide an appeal message/reason before submitting.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                // Get GroupId and Reviewer Info
                int groupId = 0;
                string reviewerEmail = "";
                string reviewerName = "";
                string taskTitle = "";
                string taskLevel = "";
                
                string infoSql = @"
                    SELECT t.GroupId, t.TaskTitle, t.TaskLevel, u.Email AS ReviewerEmail, u.FullName AS ReviewerName
                    FROM Task t
                    INNER JOIN Users u ON t.AssignedBy = u.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                {
                    infoCmd.Parameters.AddWithValue("@TaskId", TaskId);
                    using (SqlDataReader rdr = infoCmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            groupId = Convert.ToInt32(rdr["GroupId"]);
                            taskTitle = rdr["TaskTitle"].ToString();
                            taskLevel = rdr["TaskLevel"].ToString();
                            reviewerEmail = rdr["ReviewerEmail"].ToString();
                            reviewerName = rdr["ReviewerName"].ToString();
                        }
                    }
                }

                // Upsert Appeal
                string upsertAppealSql = @"
                    IF EXISTS (SELECT 1 FROM Appeals WHERE TaskId = @TaskId AND StudentId = @StudentId)
                    BEGIN
                        UPDATE Appeals 
                        SET Reason = @Reason, ChangesMade = @ChangesMade, Explanation = @Explanation, IsCompleted = @IsCompleted, Status = 'Pending Review', CreatedAt = GETDATE() 
                        WHERE TaskId = @TaskId AND StudentId = @StudentId;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO Appeals (TaskId, StudentId, GroupId, Reason, ChangesMade, Explanation, IsCompleted, Status, CreatedAt)
                        VALUES (@TaskId, @StudentId, @GroupId, @Reason, @ChangesMade, @Explanation, @IsCompleted, 'Pending Review', GETDATE());
                    END";

                using (SqlCommand appealCmd = new SqlCommand(upsertAppealSql, conn))
                {
                    appealCmd.Parameters.AddWithValue("@TaskId", TaskId);
                    appealCmd.Parameters.AddWithValue("@StudentId", studentId);
                    appealCmd.Parameters.AddWithValue("@GroupId", groupId);
                    appealCmd.Parameters.AddWithValue("@Reason", reason);
                    appealCmd.Parameters.AddWithValue("@ChangesMade", changesMade);
                    appealCmd.Parameters.AddWithValue("@Explanation", explanation);
                    appealCmd.Parameters.AddWithValue("@IsCompleted", isCompleted);
                    appealCmd.ExecuteNonQuery();
                }

                // Update Task state
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "SUBMIT_REPORT");
                    cmd.Parameters.AddWithValue("@TaskId", TaskId);
                    cmd.Parameters.AddWithValue("@Status", "Appealed");
                    cmd.Parameters.AddWithValue("@ReportText", reason);
                    cmd.ExecuteNonQuery();
                }

                // Send Emails
                try
                {
                    string studentName = Session["FullName"]?.ToString() ?? "Student";
                    
                    if (taskLevel == "MentorToLeader")
                    {
                        // Notify Mentor
                        Project_Board.Services.EmailService.SendLeaderReportSubmitted(reviewerEmail, reviewerName, studentName, "Your Group", taskTitle, reason);
                        Project_Board.Services.EmailService.SendTaskAppealSubmittedEmail(reviewerEmail, reviewerName, studentName, "Your Group", taskTitle);
                    }
                    else if (taskLevel == "LeaderToMember")
                    {
                        // Notify Leader
                        Project_Board.Services.EmailService.SendMemberReportSubmitted(reviewerEmail, reviewerName, studentName, taskTitle, reason);
                        Project_Board.Services.EmailService.SendTaskAppealSubmittedEmail(reviewerEmail, reviewerName, studentName, "Your Group", taskTitle);
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }

            // Redirect back to dashboard
            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
            if (role == "Leader")
            {
                Response.Redirect("~/Student/Leader/Leader_TaskManagement.aspx");
            }
            else
            {
                Response.Redirect("~/Student/Member/Member_TaskManagement.aspx");
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
            if (role == "Leader")
            {
                Response.Redirect("~/Student/Leader/Leader_TaskManagement.aspx");
            }
            else
            {
                Response.Redirect("~/Student/Member/Member_TaskManagement.aspx");
            }
        }
    }
}
