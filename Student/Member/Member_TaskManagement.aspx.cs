using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Member
{
    public partial class Member_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "M";
        protected string UserName { get; set; } = "Student Member";
        protected string UserEmail { get; set; } = "member@example.com";

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
            UserEmail = Session["Email"]?.ToString() ?? "";
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
                    cmd.Parameters.AddWithValue("@Action", "BY_ASSIGNED_TO");
                    cmd.Parameters.AddWithValue("@UserId", memberId);

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            TotalTasks = dt.Rows.Count;
            PendingCount = 0;
            InProgressCount = 0;
            CompletedCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                string st = row["Status"].ToString();
                if (st == "Pending" || st == "Working" || st == "Revision Needed" || st == "Failed") PendingCount++;
                else if (st == "In Progress" || st == "Appealed") InProgressCount++;
                else if (st == "Completed") CompletedCount++;
            }

            rptMemberTasks.DataSource = dt;
            rptMemberTasks.DataBind();

            lblNoTasks.Visible = dt.Rows.Count == 0;
        }

        private int GetMemberGroupId(int memberId)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT TOP 1 GroupId FROM GroupMembers WHERE UserId = @UserId AND JoinStatus = 'Accepted'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", memberId);
                    conn.Open();
                    object res = cmd.ExecuteScalar();
                    return res != null && res != DBNull.Value ? Convert.ToInt32(res) : 0;
                }
            }
        }

        private void LoadGroupMentorTasks()
        {
            int memberId = Convert.ToInt32(Session["UserId"]);
            int groupId = GetMemberGroupId(memberId);
            DataTable dt = new DataTable();

            if (groupId > 0)
            {
                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "MENTOR_LEADER_TASKS");
                        cmd.Parameters.AddWithValue("@GroupId", groupId);

                        conn.Open();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }

            rptGroupMentorTasks.DataSource = dt;
            rptGroupMentorTasks.DataBind();
            lblNoGroupMentorTasks.Visible = dt.Rows.Count == 0;
        }

        protected void rptMemberTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int taskId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ReportToLeader")
            {
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

            int taskId = Convert.ToInt32(hfReportTaskId.Value);
            string status = "Appealed";
            string reportText = txtMemberReportText.Text.Trim();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "SUBMIT_REPORT");
                    cmd.Parameters.AddWithValue("@TaskId", taskId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@ReportText", reportText);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Send email to Leader (Scenario 4)
                try
                {
                    string infoSql = @"
                        SELECT t.TaskTitle, u.FullName AS LeaderName, u.Email AS LeaderEmail
                        FROM Tasks t
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

                                Project_Board.Services.EmailService.SendMemberReportSubmitted(leaderEmail, leaderName, memberName, taskTitle, reportText);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }

            lblMessage.Text = "Appeal Completion submitted successfully to your Leader!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadMemberTasks();
            LoadGroupMentorTasks();
        }
    }
}