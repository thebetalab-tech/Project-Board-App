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
        private int TaskId => int.TryParse(Request.QueryString["TaskId"], out int taskId) ? taskId : 0;

        // Session-backed display values. Kept as properties so the markup never calls
        // Substring on a possibly-empty session value (which throws ArgumentOutOfRangeException).
        protected string CurrentUserName
        {
            get
            {
                string name = Session["FullName"]?.ToString();
                return string.IsNullOrWhiteSpace(name) ? "User" : name;
            }
        }

        protected string CurrentUserEmail
        {
            get
            {
                string email = Session["Email"]?.ToString();
                return string.IsNullOrWhiteSpace(email) ? "user@example.com" : email;
            }
        }

        protected string CurrentUserInitial => CurrentUserName.Substring(0, 1).ToUpper();

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
                    SELECT t.TaskTitle, t.FeedbackText, t.TaskDescription, t.AssignedTo, u.FullName AS AssignedByName, t.DueDate
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

                            // Deadline check
                            DateTime? dueDate = reader["DueDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["DueDate"]);
                            if (dueDate.HasValue && dueDate.Value < DateTime.Now)
                            {
                                lblMessage.Text = "The deadline for this task has passed. You cannot submit an appeal.";
                                lblMessage.CssClass = "alert alert-danger";
                                lblMessage.Visible = true;
                                btnSubmit.Enabled = false;
                                txtReason.Enabled = false;
                                txtChangesMade.Enabled = false;
                                txtExplanation.Enabled = false;
                                chkIsCompleted.Enabled = false;
                            }

                            lblTaskTitle.Text = System.Web.HttpUtility.HtmlEncode(reader["TaskTitle"].ToString());
                            lblAssignorName.Text = System.Web.HttpUtility.HtmlEncode(reader["AssignedByName"].ToString());

                            string feedback = reader["FeedbackText"] != DBNull.Value ? reader["FeedbackText"].ToString() : "";
                            string description = reader["TaskDescription"] != DBNull.Value ? reader["TaskDescription"].ToString() : "";

                            // FeedbackText/TaskDescription are NVARCHAR(MAX) free text: encode and clamp
                            // so a long block cannot blow out the task card layout.
                            string details = string.IsNullOrEmpty(feedback) ? description : feedback;
                            lblFeedback.Text = Project_Board.Utils.UiHelper.TextPreview(details, "No details provided.");
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

            // Security & Deadline check
            using (SqlConnection checkConn = new SqlConnection(ConnString))
            {
                string checkQuery = "SELECT AssignedTo, DueDate FROM Task WHERE TaskId = @TaskId";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, checkConn))
                {
                    checkCmd.Parameters.AddWithValue("@TaskId", TaskId);
                    checkConn.Open();
                    using (SqlDataReader reader = checkCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int assignedTo = Convert.ToInt32(reader["AssignedTo"]);
                            int currentUserId = Convert.ToInt32(Session["UserId"]);
                            
                            if (assignedTo != currentUserId)
                            {
                                lblMessage.Text = "You are not authorized to appeal this task.";
                                lblMessage.CssClass = "alert alert-danger";
                                lblMessage.Visible = true;
                                return;
                            }

                            DateTime? dueDate = reader["DueDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["DueDate"]);
                            if (dueDate.HasValue && dueDate.Value < DateTime.Now)
                            {
                                lblMessage.Text = "The deadline for this task has passed. You cannot submit an appeal.";
                                lblMessage.CssClass = "alert alert-danger";
                                lblMessage.Visible = true;
                                return;
                            }
                        }
                    }
                }
            }

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

            try
            {
                if (!SaveAppeal(studentId, reason, changesMade, explanation, isCompleted))
                {
                    return;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Appeal.btnSubmit_Click failed for TaskId " + TaskId + ": " + ex);
                lblMessage.Text = "Your appeal could not be submitted right now. Please try again.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            RedirectToDashboard();
        }

        // Returns false when the submission was rejected and a message has already been
        // shown to the user; true when the appeal was persisted.
        private bool SaveAppeal(int studentId, string reason, string changesMade, string explanation, bool isCompleted)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                // Re-verify the task is actually assigned to this student. The check in
                // LoadTaskDetails only runs on the initial GET and merely disables the
                // button client-side, which does not stop a forged postback.
                using (SqlCommand ownerCmd = new SqlCommand("SELECT AssignedTo FROM Task WHERE TaskId = @TaskId", conn))
                {
                    ownerCmd.Parameters.AddWithValue("@TaskId", TaskId);
                    object assignedToResult = ownerCmd.ExecuteScalar();
                    if (assignedToResult == null || assignedToResult == DBNull.Value || Convert.ToInt32(assignedToResult) != studentId)
                    {
                        lblMessage.Text = "You are not authorized to appeal this task.";
                        lblMessage.CssClass = "alert alert-danger";
                        lblMessage.Visible = true;
                        btnSubmit.Enabled = false;
                        return false;
                    }
                }

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

            return true;
        }

        private void RedirectToDashboard()
        {
            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
            string isLeader = Session["IsLeader"]?.ToString() ?? "";

            if (role == "Admin")
            {
                Response.Redirect("~/Admin/Admin_TaskManagement.aspx");
            }
            else if (role == "Faculty")
            {
                Response.Redirect("~/Faculty/TaskManagement.aspx");
            }
            else if (role == "Student" && isLeader == "True")
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
            RedirectToDashboard();
        }
    }
}
