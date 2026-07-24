using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Leader
{
    public partial class Leader_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "TL";
        protected string UserName { get; set; } = "Student Leader";
        protected string UserEmail { get; set; } = "leader@example.com";
        protected string GroupName { get; set; } = "My Group";
        protected int CurrentGroupId { get; set; } = 0;

        protected int TotalMentorTasks { get; set; } = 0;
        protected int PendingMentorTasks { get; set; } = 0;
        protected int InProgressMentorTasks { get; set; } = 0;
        protected int CompletedMentorTasks { get; set; } = 0;

        protected int TotalMemberTasks { get; set; } = 0;
        protected int MemberTasksCompleted { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Leader";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            LoadGroupInfo();

            if (!IsPostBack)
            {
                LoadGroupMembers();
                LoadMentorTasks();
                LoadMemberTasks();
            }
        }

        private void LoadGroupInfo()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT GroupId, GroupName FROM Groups WHERE LeaderId = @LeaderId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            CurrentGroupId = Convert.ToInt32(reader["GroupId"]);
                            GroupName = reader["GroupName"].ToString();
                        }
                    }
                }
            }
        }

        private void LoadGroupMembers()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            ddlMembers.Items.Clear();
            ddlMembers.Items.Add(new ListItem("-- Select Team Member --", ""));

            if (CurrentGroupId == 0) return;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT u.UserId, u.FullName 
                    FROM GroupMembers gm
                    INNER JOIN Users u ON gm.UserId = u.UserId
                    WHERE gm.GroupId = @GroupId AND gm.JoinStatus = 'Accepted' AND u.UserId <> @LeaderId
                    ORDER BY u.FullName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlMembers.Items.Add(new ListItem(reader["FullName"].ToString(), reader["UserId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadMentorTasks()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "MENTOR_LEADER_TASKS");
                    cmd.Parameters.AddWithValue("@UserId", leaderId);

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            TotalMentorTasks = dt.Rows.Count;
            PendingMentorTasks = 0;
            InProgressMentorTasks = 0;
            CompletedMentorTasks = 0;

            foreach (DataRow row in dt.Rows)
            {
                string st = row["Status"].ToString();
                if (st == "Pending") PendingMentorTasks++;
                else if (st == "In Progress") InProgressMentorTasks++;
                else if (st == "Completed") CompletedMentorTasks++;
            }

            rptMentorTasks.DataSource = dt;
            rptMentorTasks.DataBind();
            lblNoMentorTasks.Visible = dt.Rows.Count == 0;
        }

        private void LoadMemberTasks()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "LEADER_MEMBER_TASKS");
                    cmd.Parameters.AddWithValue("@UserId", leaderId);

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            TotalMemberTasks = dt.Rows.Count;
            MemberTasksCompleted = 0;
            foreach (DataRow row in dt.Rows)
            {
                if (row["Status"].ToString() == "Completed") MemberTasksCompleted++;
            }

            rptMemberTasks.DataSource = dt;
            rptMemberTasks.DataBind();
            lblNoMemberTasks.Visible = dt.Rows.Count == 0;
        }

        protected void rptMentorTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int taskId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ReportToMentor")
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
                                lblMentorModalTaskTitle.Text = reader["TaskTitle"].ToString();
                                ddlUpdateStatus.SelectedValue = reader["Status"].ToString();
                                txtLeaderReportText.Text = reader["ReportText"] != DBNull.Value ? reader["ReportText"].ToString() : "";
                            }
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "OpenReportMentorModal", "openModal('reportMentorModal');", true);
            }
        }

        protected void btnSubmitReportToMentor_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfReportTaskId.Value)) return;

            int taskId = Convert.ToInt32(hfReportTaskId.Value);
            string status = ddlUpdateStatus.SelectedValue;
            string reportText = txtLeaderReportText.Text.Trim();

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
            }

            lblMessage.Text = "Report and Status successfully updated for Mentor!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadMentorTasks();
        }

        protected void btnAssignMemberTask_Click(object sender, EventArgs e)
        {
            if (CurrentGroupId == 0)
            {
                lblMessage.Text = "You are not assigned as Leader of any group.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            if (string.IsNullOrEmpty(ddlMembers.SelectedValue))
            {
                lblMessage.Text = "Please select a team member to assign the task.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            int memberId = Convert.ToInt32(ddlMembers.SelectedValue);
            string title = txtMemberTaskTitle.Text.Trim();
            string description = txtMemberTaskDescription.Text.Trim();
            DateTime? dueDate = null;

            if (!string.IsNullOrEmpty(txtMemberTaskDueDate.Text))
            {
                dueDate = DateTime.Parse(txtMemberTaskDueDate.Text);
            }

            int leaderId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "INSERT");
                    cmd.Parameters.AddWithValue("@TaskTitle", title);
                    cmd.Parameters.AddWithValue("@TaskDescription", description);
                    cmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    cmd.Parameters.AddWithValue("@AssignedBy", leaderId);
                    cmd.Parameters.AddWithValue("@AssignedTo", memberId);
                    cmd.Parameters.AddWithValue("@TaskLevel", "LeaderToMember");
                    cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", "Pending");

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            txtMemberTaskTitle.Text = "";
            txtMemberTaskDescription.Text = "";
            txtMemberTaskDueDate.Text = "";
            ddlMembers.SelectedIndex = 0;

            lblMessage.Text = "Task successfully assigned to team member!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadMemberTasks();
        }

        protected void rptMemberTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int taskId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ViewMemberReport")
            {
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
                                lblViewMemberModalTaskTitle.Text = reader["TaskTitle"].ToString();
                                lblViewMemberModalMember.Text = reader["AssignedToName"].ToString();
                                lblViewMemberModalStatus.Text = reader["Status"].ToString();
                                lblViewMemberModalDesc.Text = string.IsNullOrEmpty(reader["TaskDescription"].ToString()) 
                                    ? "No description provided." 
                                    : reader["TaskDescription"].ToString();

                                string report = reader["ReportText"].ToString();
                                if (!string.IsNullOrEmpty(report))
                                {
                                    lblViewMemberModalReportText.Text = report;
                                    string subDate = reader["ReportSubmittedAt"] != DBNull.Value 
                                        ? Convert.ToDateTime(reader["ReportSubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt") 
                                        : "";
                                    lblViewMemberModalReportDate.Text = "Submitted at: " + subDate;
                                    pnlMemberReportContent.Visible = true;
                                    pnlNoMemberReport.Visible = false;
                                }
                                else
                                {
                                    pnlMemberReportContent.Visible = false;
                                    pnlNoMemberReport.Visible = true;
                                }
                            }
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "OpenViewMemberModal", "openModal('viewMemberModal');", true);
            }
            else if (e.CommandName == "DeleteMemberTask")
            {
                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "DELETE");
                        cmd.Parameters.AddWithValue("@TaskId", taskId);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadMemberTasks();
            }
        }
    }
}