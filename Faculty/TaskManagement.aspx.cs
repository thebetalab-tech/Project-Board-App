using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Faculty
{
    public partial class TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "FM";
        protected string UserName { get; set; } = "Faculty Member";
        protected string UserEmail { get; set; } = "faculty@example.com";

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Faculty")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Faculty Member";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadMentoredGroups();
                LoadTasks();
            }
        }

        private void LoadMentoredGroups()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            ddlGroups.Items.Clear();
            ddlGroups.Items.Add(new ListItem("-- Select Mentored Group --", ""));

            ddlAssignee.Items.Clear();
            ddlAssignee.Items.Add(new ListItem("-- Select Student / Leader --", ""));

            if (ddlFilterGroup != null)
            {
                ddlFilterGroup.Items.Clear();
                ddlFilterGroup.Items.Add(new ListItem("All Mentored Groups", "0"));
            }

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT g.GroupId, g.GroupName, u.FullName AS LeaderName 
                    FROM Groups g
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    WHERE g.MentorId = @FacultyId
                    ORDER BY g.GroupName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string text = $"{rdr["GroupName"]} (Leader: {rdr["LeaderName"]})";
                            string gId = rdr["GroupId"].ToString();
                            ddlGroups.Items.Add(new ListItem(text, gId));
                            if (ddlFilterGroup != null)
                            {
                                ddlFilterGroup.Items.Add(new ListItem(rdr["GroupName"].ToString(), gId));
                            }
                        }
                    }
                }
            }

            if (ddlGroups.Items.Count <= 1)
            {
                lblMessage.Text = "Note: You currently have no assigned mentored groups. Groups will appear here once you accept mentor requests.";
                lblMessage.CssClass = "alert alert-warning";
                lblMessage.Visible = true;
            }
        }

        protected void ddlFilterGroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTasks();
        }

        protected void ddlGroups_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlAssignee.Items.Clear();
            ddlAssignee.Items.Add(new ListItem("-- Select Student / Leader --", ""));

            if (string.IsNullOrEmpty(ddlGroups.SelectedValue)) return;

            int groupId = Convert.ToInt32(ddlGroups.SelectedValue);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT DISTINCT u.UserId, u.FullName, u.IsLeader
                    FROM Users u
                    LEFT JOIN GroupMembers gm ON u.UserId = gm.UserId AND gm.GroupId = @GroupId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted')
                    LEFT JOIN Groups g ON g.GroupId = @GroupId AND g.LeaderId = u.UserId
                    WHERE (gm.GroupId IS NOT NULL OR g.LeaderId IS NOT NULL)
                    ORDER BY u.IsLeader DESC, u.FullName ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            bool isLeader = Convert.ToBoolean(rdr["IsLeader"]);
                            string roleLabel = isLeader ? " [Leader]" : " [Member]";
                            ddlAssignee.Items.Add(new ListItem(rdr["FullName"].ToString() + roleLabel, rdr["UserId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadTasks()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            int selectedGroupId = 0;
            if (ddlFilterGroup != null && int.TryParse(ddlFilterGroup.SelectedValue, out int gid))
            {
                selectedGroupId = gid;
            }

            DataTable dt = new DataTable();
            string filter = ddlReportFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT t.TaskId, t.TaskTitle, t.TaskDescription, t.DueDate, t.Status,
                           g.GroupName, uTo.FullName AS AssignedToName, uBy.FullName AS AssignedByName
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                    WHERE g.MentorId = @FacultyId
                      AND (@GroupId = 0 OR t.GroupId = @GroupId)";
                
                if (filter != "All")
                {
                    query += " AND t.Status = @Status";
                }
                
                query += " ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    cmd.Parameters.AddWithValue("@GroupId", selectedGroupId);
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", filter);
                    }
                    
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            rptTasks.DataSource = dt;
            rptTasks.DataBind();
            lblNoTasks.Visible = dt.Rows.Count == 0;
        }

        protected void ddlReportFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTasks();
        }

        protected void btnCreateTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlGroups.SelectedValue) || string.IsNullOrEmpty(ddlAssignee.SelectedValue))
            {
                lblMessage.Text = "Please select both a Mentored Group and an Assignee Student.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            string title = txtTaskTitle.Text.Trim();
            if (string.IsNullOrEmpty(title))
            {
                lblMessage.Text = "Please enter a Task Title.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            int facultyId = Convert.ToInt32(Session["UserId"]);
            int groupId = Convert.ToInt32(ddlGroups.SelectedValue);
            int assignedTo = Convert.ToInt32(ddlAssignee.SelectedValue);
            string description = txtTaskDescription.Text.Trim();
            string points = txtPointsToCover.Text.Trim();
            DateTime? dueDate = string.IsNullOrEmpty(txtDueDate.Text) ? (DateTime?)null : Convert.ToDateTime(txtDueDate.Text);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                // Verify faculty mentors this group
                conn.Open();
                string verifySql = "SELECT COUNT(1) FROM Groups WHERE GroupId = @GroupId AND MentorId = @FacultyId";
                using (SqlCommand vCmd = new SqlCommand(verifySql, conn))
                {
                    vCmd.Parameters.AddWithValue("@GroupId", groupId);
                    vCmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    int count = Convert.ToInt32(vCmd.ExecuteScalar());
                    if (count == 0)
                    {
                        lblMessage.Text = "Unauthorized: You can only assign tasks to groups you actively mentor.";
                        lblMessage.CssClass = "alert alert-danger";
                        lblMessage.Visible = true;
                        return;
                    }
                }

                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "INSERT");
                    cmd.Parameters.AddWithValue("@TaskTitle", title);
                    cmd.Parameters.AddWithValue("@TaskDescription", description);
                    cmd.Parameters.AddWithValue("@PointsToCover", points);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.Parameters.AddWithValue("@AssignedBy", facultyId);
                    cmd.Parameters.AddWithValue("@AssignedTo", assignedTo);
                    cmd.Parameters.AddWithValue("@TaskLevel", "MentorToLeader");
                    cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", "Working");

                    cmd.ExecuteNonQuery();
                }

                // Send email to assigned Group Leader
                try
                {
                    string infoSql = @"
                        SELECT u.FullName AS LeaderName, u.Email AS LeaderEmail, g.GroupName, f.FullName AS FacultyName
                        FROM Users u
                        CROSS JOIN Users f
                        INNER JOIN Groups g ON g.GroupId = @GroupId
                        WHERE u.UserId = @LeaderId AND f.UserId = @FacultyId";

                    using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                    {
                        infoCmd.Parameters.AddWithValue("@LeaderId", assignedTo);
                        infoCmd.Parameters.AddWithValue("@FacultyId", facultyId);
                        infoCmd.Parameters.AddWithValue("@GroupId", groupId);

                        using (SqlDataReader rdr = infoCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string leaderName = rdr["LeaderName"].ToString();
                                string leaderEmail = rdr["LeaderEmail"].ToString();
                                string groupName = rdr["GroupName"].ToString();
                                string facultyName = rdr["FacultyName"].ToString();

                                Project_Board.Services.EmailService.SendFacultyTaskAssignedToLeader(
                                    leaderEmail,
                                    leaderName,
                                    facultyName,
                                    groupName,
                                    title,
                                    description,
                                    points,
                                    dueDate?.ToString("dd MMM yyyy")
                                );
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Email Error] {ex.Message}");
                }
            }

            lblMessage.Text = "Task created and assigned successfully!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            txtTaskTitle.Text = "";
            txtTaskDescription.Text = "";
            txtPointsToCover.Text = "";
            txtDueDate.Text = "";

            LoadTasks();
        }

        protected void btnExportReport_Click(object sender, EventArgs e)
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string filter = ddlReportFilter.SelectedValue;
            
            int selectedGroupId = 0;
            if (ddlFilterGroup != null && int.TryParse(ddlFilterGroup.SelectedValue, out int gid))
            {
                selectedGroupId = gid;
            }

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT 
                        t.TaskTitle AS [Task Title],
                        g.GroupName AS [Group Name],
                        uTo.FullName AS [Assigned To],
                        t.DueDate AS [Due Date],
                        t.Status AS [Status]
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    WHERE g.MentorId = @FacultyId
                      AND (@GroupId = 0 OR t.GroupId = @GroupId)";

                if (filter != "All")
                {
                    if (filter == "Completed") query += " AND t.Status = 'Completed'";
                    else if (filter == "In Progress") query += " AND (t.Status = 'Working' OR t.Status = 'Pending')";
                    else if (filter == "Appealed") query += " AND t.Status = 'Appealed'";
                }
                
                query += " ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    cmd.Parameters.AddWithValue("@GroupId", selectedGroupId);
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        string userName = Session["FullName"]?.ToString() ?? "Faculty";
                        string userEmail = Session["Email"]?.ToString() ?? "faculty@example.com";
                        string groupFilterStr = selectedGroupId == 0 ? "All Groups" : ddlFilterGroup.SelectedItem.Text;
                        
                        Project_Board.Services.ReportService.GeneratePdfReport("Mentored Group Tasks", dt, userName, userEmail, $"Group: {groupFilterStr}, Status: {filter}", Response);
                    }
                }
            }
        }
    }
}
