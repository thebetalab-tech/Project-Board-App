using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "A";
        protected string UserName { get; set; } = "System Admin";
        protected string UserEmail { get; set; } = "admin@example.com";

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "System Admin";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }
            userintial.Text = UserInitials;
            userNameLabel.Text = UserName;
            userEmailLabel.Text = UserEmail;

            if (!IsPostBack)
            {
                LoadAllGroups();
                LoadAllUsers();
                LoadGlobalTasks();
            }
        }

        private void LoadAllGroups()
        {
            ddlGroups.Items.Clear();
            ddlGroups.Items.Add(new ListItem("-- Select Group --", ""));

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT GroupId, GroupName FROM Groups ORDER BY GroupName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            ddlGroups.Items.Add(new ListItem(rdr["GroupName"].ToString(), rdr["GroupId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadAllUsers()
        {
            ddlAssignToUser.Items.Clear();
            ddlAssignToUser.Items.Add(new ListItem("-- Select Any User / Student / Faculty --", ""));

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT UserId, FullName, Role, EnrollmentNo FROM Users WHERE IsActive = 1 ORDER BY Role ASC, FullName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string role = rdr["Role"].ToString();
                            string text = $"{rdr["FullName"]} ({role})";
                            if (rdr["EnrollmentNo"] != DBNull.Value) text += $" - {rdr["EnrollmentNo"]}";
                            ddlAssignToUser.Items.Add(new ListItem(text, rdr["UserId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadGlobalTasks()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT t.TaskId, t.TaskTitle, t.TaskDescription, t.DueDate, t.Status, t.TaskLevel,
                           g.GroupName, uTo.FullName AS AssignedToName, uBy.FullName AS AssignedByName
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                    ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            rptAdminTasks.DataSource = dt;
            rptAdminTasks.DataBind();
            lblNoTasks.Visible = dt.Rows.Count == 0;
        }

        protected void btnAdminCreateTask_Click(object sender, EventArgs e)
        {
            int adminId = Convert.ToInt32(Session["UserId"]);

            if (string.IsNullOrEmpty(ddlGroups.SelectedValue) || string.IsNullOrEmpty(ddlAssignToUser.SelectedValue))
            {
                lblMessage.Text = "Please select both a Group and an Assignee.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            int groupId = Convert.ToInt32(ddlGroups.SelectedValue);
            int assignedTo = Convert.ToInt32(ddlAssignToUser.SelectedValue);
            string title = txtTaskTitle.Text.Trim();
            string description = txtTaskDescription.Text.Trim();
            string points = txtPointsToCover.Text.Trim();
            DateTime? dueDate = string.IsNullOrEmpty(txtDueDate.Text) ? (DateTime?)null : Convert.ToDateTime(txtDueDate.Text);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "INSERT");
                    cmd.Parameters.AddWithValue("@TaskTitle", title);
                    cmd.Parameters.AddWithValue("@TaskDescription", description);
                    cmd.Parameters.AddWithValue("@PointsToCover", points);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.Parameters.AddWithValue("@AssignedBy", adminId);
                    cmd.Parameters.AddWithValue("@AssignedTo", assignedTo);
                    cmd.Parameters.AddWithValue("@TaskLevel", "AdminToAll");
                    cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", "Working");

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            lblMessage.Text = "Admin Global Task created and assigned successfully!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            txtTaskTitle.Text = "";
            txtTaskDescription.Text = "";
            txtPointsToCover.Text = "";
            txtDueDate.Text = "";

            LoadGlobalTasks();
        }

        protected void rptAdminTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteTask")
            {
                int taskId = Convert.ToInt32(e.CommandArgument);
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

                lblMessage.Text = "Task deleted successfully.";
                lblMessage.CssClass = "alert alert-success";
                lblMessage.Visible = true;

                LoadGlobalTasks();
            }
        }
    }
}
