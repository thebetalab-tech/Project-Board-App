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
                            ddlGroups.Items.Add(new ListItem(text, rdr["GroupId"].ToString()));
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
            DataTable dt = new DataTable();

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
                    ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
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
    }
}
