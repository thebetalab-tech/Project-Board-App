using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Mentor_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "M";
        protected string UserName { get; set; } = "Mentor";
        protected string UserEmail { get; set; } = "mentor@example.com";

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

            UserName = Session["FullName"]?.ToString() ?? "Faculty / Mentor";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadAssignedGroups();
                LoadTasks();
            }
        }

        private void LoadAssignedGroups()
        {
            int currentUserId = Convert.ToInt32(Session["UserId"]);
            string userRole = Session["UserRole"]?.ToString() ?? "";

            ddlGroups.Items.Clear();
            ddlGroups.Items.Add(new ListItem("-- Select Group to Assign Task --", ""));

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                // If Admin, can view/assign to all groups with leaders. If Faculty/Mentor, assigned groups.
                string query = @"
                    SELECT g.GroupId, g.GroupName, u.FullName AS LeaderName 
                    FROM Groups g
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    WHERE (@Role = 'Admin' OR g.MentorId = @MentorId)
                    ORDER BY g.GroupName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Role", userRole);
                    cmd.Parameters.AddWithValue("@MentorId", currentUserId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string itemText = $"{reader["GroupName"]} (Leader: {reader["LeaderName"]})";
                            ddlGroups.Items.Add(new ListItem(itemText, reader["GroupId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadTasks()
        {
            int currentUserId = Convert.ToInt32(Session["UserId"]);
            string userRole = Session["UserRole"]?.ToString() ?? "";
            string filterGroupId = ddlFilterGroup.SelectedValue;
            string filterStatus = ddlFilterStatus.SelectedValue;

            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "MENTOR_LEADER_TASKS");
                    cmd.Parameters.AddWithValue("@UserId", userRole == "Admin" ? (object)DBNull.Value : currentUserId);
                    if (!string.IsNullOrEmpty(filterGroupId))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", Convert.ToInt32(filterGroupId));
                    }

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            // Client-side or DataView status filtering if status filter selected
            DataView dv = dt.DefaultView;
            if (!string.IsNullOrEmpty(filterStatus))
            {
                dv.RowFilter = $"Status = '{filterStatus}'";
            }

            DataTable filteredDt = dv.ToTable();

            // Calculate stats
            TotalTasks = dt.Rows.Count;
            PendingCount = 0;
            InProgressCount = 0;
            CompletedCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                string st = row["Status"].ToString();
                if (st == "Pending") PendingCount++;
                else if (st == "In Progress") InProgressCount++;
                else if (st == "Completed") CompletedCount++;
            }

            rptMentorTasks.DataSource = filteredDt;
            rptMentorTasks.DataBind();

            lblNoTasks.Visible = filteredDt.Rows.Count == 0;
        }

        protected void btnCreateTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlGroups.SelectedValue))
            {
                lblMessage.Text = "Please select a group to assign the task.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            int groupId = Convert.ToInt32(ddlGroups.SelectedValue);
            string title = txtTaskTitle.Text.Trim();
            string description = txtTaskDescription.Text.Trim();
            DateTime? dueDate = null;

            if (!string.IsNullOrEmpty(txtDueDate.Text))
            {
                dueDate = DateTime.Parse(txtDueDate.Text);
            }

            int mentorId = Convert.ToInt32(Session["UserId"]);
            int leaderId = 0;

            // Fetch LeaderId for selected group
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT LeaderId FROM Groups WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        leaderId = Convert.ToInt32(result);
                    }
                }
            }

            if (leaderId == 0)
            {
                lblMessage.Text = "Selected group does not have an assigned leader.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            // Save task using stored procedure
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "INSERT");
                    cmd.Parameters.AddWithValue("@TaskTitle", title);
                    cmd.Parameters.AddWithValue("@TaskDescription", description);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.Parameters.AddWithValue("@AssignedBy", mentorId);
                    cmd.Parameters.AddWithValue("@AssignedTo", leaderId);
                    cmd.Parameters.AddWithValue("@TaskLevel", "MentorToLeader");
                    cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", "Pending");

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Clear inputs & refresh
            txtTaskTitle.Text = "";
            txtTaskDescription.Text = "";
            txtDueDate.Text = "";
            ddlGroups.SelectedIndex = 0;

            lblMessage.Text = "Task successfully assigned to Group Leader!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadTasks();
        }

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTasks();
        }

        protected void rptMentorTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int taskId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ViewReport")
            {
                LoadTaskDetails(taskId);
            }
            else if (e.CommandName == "DeleteTask")
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
                LoadTasks();
            }
        }

        private void LoadTaskDetails(int taskId)
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
                            lblModalTitle.Text = reader["TaskTitle"].ToString();
                            lblModalGroup.Text = reader["GroupName"].ToString();
                            lblModalLeader.Text = reader["AssignedToName"].ToString();
                            lblModalStatus.Text = reader["Status"].ToString();
                            lblModalDescription.Text = string.IsNullOrEmpty(reader["TaskDescription"].ToString()) 
                                ? "No description provided." 
                                : reader["TaskDescription"].ToString();

                            string report = reader["ReportText"].ToString();
                            if (!string.IsNullOrEmpty(report))
                            {
                                lblModalReportText.Text = report;
                                string subDate = reader["ReportSubmittedAt"] != DBNull.Value 
                                    ? Convert.ToDateTime(reader["ReportSubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt") 
                                    : "";
                                lblModalReportDate.Text = "Submitted at: " + subDate;
                                pnlReportContent.Visible = true;
                                pnlNoReport.Visible = false;
                            }
                            else
                            {
                                pnlReportContent.Visible = false;
                                pnlNoReport.Visible = true;
                            }
                        }
                    }
                }
            }

            // Show modal using JS Script
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenReportModal", "openModal('reportModal');", true);
        }
    }
}