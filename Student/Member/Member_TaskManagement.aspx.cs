using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace Project_Board.Student.Member
{
    public partial class Member_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected string UserName { get; set; } = "Student Member";
        protected string UserEmail { get; set; } = "member@example.com";
        protected int MemberTasksCompleted { get; set; } = 0;
        protected int TotalMemberTasks { get; set; } = 0;

        protected int TotalTasks { get; set; } = 0;
        protected int PendingCount { get; set; } = 0;
        protected int InProgressCount { get; set; } = 0;
        protected int CompletedCount { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Member";
            UserEmail = Session["Email"]?.ToString() ?? "member@example.com";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadMemberTasks();
                LoadGroupMentorTasks();
            }
        }

        private void LoadMemberTasks()
        {
            int memberId = Convert.ToInt32(Session["UserId"]);
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "MEMBER_ASSIGNED_TASKS");
                    cmd.Parameters.AddWithValue("@UserId", memberId);

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            TotalMemberTasks = dt.Rows.Count;
            TotalTasks = dt.Rows.Count;
            MemberTasksCompleted = 0;
            PendingCount = 0;
            InProgressCount = 0;
            CompletedCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                string st = row["Status"] != DBNull.Value ? row["Status"].ToString() : "";
                if (st == "Completed")
                {
                    MemberTasksCompleted++;
                    CompletedCount++;
                }
                else if (st == "Appealed" || st == "In Progress" || st == "Working")
                {
                    InProgressCount++;
                }
                else
                {
                    PendingCount++;
                }
            }

            rptMemberTasks.DataSource = dt;
            rptMemberTasks.DataBind();
            lblNoTasks.Visible = dt.Rows.Count == 0;
        }

        private void LoadGroupMentorTasks()
        {
            int memberId = Convert.ToInt32(Session["UserId"]);
            int groupId = 0;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string groupSql = @"
                    SELECT TOP 1 g.GroupId 
                    FROM Groups g
                    LEFT JOIN GroupMembers gm ON g.GroupId = gm.GroupId AND gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted')
                    WHERE g.LeaderId = @UserId OR (gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted'))
                    ORDER BY CASE WHEN g.LeaderId = @UserId THEN 0 ELSE 1 END;";

                using (SqlCommand cmd = new SqlCommand(groupSql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", memberId);
                    object res = cmd.ExecuteScalar();
                    if (res != null) groupId = Convert.ToInt32(res);
                }

                if (groupId > 0)
                {
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "MENTOR_LEADER_TASKS");
                        cmd.Parameters.AddWithValue("@GroupId", groupId);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }

                    rptGroupMentorTasks.DataSource = dt;
                    rptGroupMentorTasks.DataBind();
                    lblNoGroupMentorTasks.Visible = dt.Rows.Count == 0;
                }
                else
                {
                    lblNoGroupMentorTasks.Visible = true;
                }
            }
        }

        protected void rptMemberTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ReportToLeader")
            {
                int taskId = Convert.ToInt32(e.CommandArgument);
                hfReportTaskId.Value = taskId.ToString();

                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "BY_ID");
                        cmd.Parameters.AddWithValue("@TaskId", taskId);

                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblModalTaskTitle.Text = reader["TaskTitle"].ToString();
                                lblModalLeaderName.Text = reader["AssignedByName"].ToString();
                                
                                string feedback = reader["FeedbackText"] != DBNull.Value ? reader["FeedbackText"].ToString() : "";
                                if (!string.IsNullOrEmpty(feedback))
                                {
                                    lblModalLeaderFeedbackText.Text = feedback;
                                    pnlModalLeaderFeedback.Visible = true;
                                }
                                else pnlModalLeaderFeedback.Visible = false;

                                txtMemberReportText.Text = reader["ReportText"] != DBNull.Value ? reader["ReportText"].ToString() : "";
                            }
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "OpenReportModal", "openModal('reportModal');", true);
            }
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfReportTaskId.Value)) return;
            if (Session["UserId"] == null) return;

            int taskId = Convert.ToInt32(hfReportTaskId.Value);
            int memberId = Convert.ToInt32(Session["UserId"]);
            string status = "Appealed";
            string reportText = txtMemberReportText.Text.Trim();
            string changesMade = txtMemberChangesMade.Text.Trim();
            string explanation = txtMemberExplanation.Text.Trim();
            bool isCompleted = chkMemberIsCompleted.Checked;

            if (string.IsNullOrEmpty(reportText))
            {
                lblMessage.Text = "Please provide appeal message before submitting.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                // RBAC Security Check: Verify this task is assigned strictly to this member
                string verifySql = "SELECT TaskId, GroupId FROM Task WHERE TaskId = @TaskId AND AssignedTo = @MemberId";
                int groupId = 0;
                bool isAuthorized = false;

                using (SqlCommand checkCmd = new SqlCommand(verifySql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@TaskId", taskId);
                    checkCmd.Parameters.AddWithValue("@MemberId", memberId);
                    using (SqlDataReader checkRdr = checkCmd.ExecuteReader())
                    {
                        if (checkRdr.Read())
                        {
                            isAuthorized = true;
                            groupId = Convert.ToInt32(checkRdr["GroupId"]);
                        }
                    }
                }

                if (!isAuthorized)
                {
                    lblMessage.Text = "Unauthorized: You can only appeal tasks explicitly assigned to you.";
                    lblMessage.CssClass = "alert alert-danger";
                    lblMessage.Visible = true;
                    return;
                }

                // Save/Update Appeal in Appeals table
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
                    appealCmd.Parameters.AddWithValue("@TaskId", taskId);
                    appealCmd.Parameters.AddWithValue("@StudentId", memberId);
                    appealCmd.Parameters.AddWithValue("@GroupId", groupId);
                    appealCmd.Parameters.AddWithValue("@Reason", reportText);
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
                    cmd.Parameters.AddWithValue("@TaskId", taskId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@ReportText", reportText);
                    cmd.ExecuteNonQuery();
                }

                // Send email to Team Leader (Scenario 5)
                try
                {
                    string infoSql = @"
                        SELECT t.TaskTitle, u.FullName AS LeaderName, u.Email AS LeaderEmail
                        FROM Task t
                        INNER JOIN Users u ON t.AssignedBy = u.UserId
                        WHERE t.TaskId = @TaskId";
                    using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                    {
                        infoCmd.Parameters.AddWithValue("@TaskId", taskId);
                        using (SqlDataReader rdr = infoCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string taskTitle = rdr["TaskTitle"].ToString();
                                string leaderName = rdr["LeaderName"].ToString();
                                string leaderEmail = rdr["LeaderEmail"].ToString();
                                string memberName = Session["FullName"]?.ToString() ?? "Student Member";
                                string groupName = "Your Group"; // Member context

                                Project_Board.Services.EmailService.SendMemberReportSubmitted(leaderEmail, leaderName, memberName, taskTitle, reportText);
                                Project_Board.Services.EmailService.SendTaskAppealSubmittedEmail(leaderEmail, leaderName, memberName, groupName, taskTitle);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }

            lblMessage.Text = "Completion appeal successfully submitted to your Team Leader for review!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadMemberTasks();
        }
    }
}