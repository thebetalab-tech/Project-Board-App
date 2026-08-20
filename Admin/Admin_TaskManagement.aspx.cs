using System.Collections.Generic;
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
            
            if (!IsPostBack)
            {
                LoadAllGroups();
                LoadGlobalTasks();
                txtDueDate.Attributes["min"] = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void LoadAllGroups()
        {
            ddlGroups.Items.Clear();
            ddlGroups.Items.Add(new ListItem("-- Select Group & Leader --", ""));

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT g.GroupId, g.GroupName, u.FullName AS LeaderName 
                    FROM Groups g
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    ORDER BY g.GroupName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string itemText = $"{rdr["GroupName"]} (Leader: {rdr["LeaderName"]})";
                            ddlGroups.Items.Add(new ListItem(itemText, rdr["GroupId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadGlobalTasks()
        {
            DataTable dt = new DataTable();
            string filter = ddlReportFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT t.TaskId, t.TaskTitle, t.TaskDescription, t.DueDate, t.Status, t.TaskLevel,
                           g.GroupName, uTo.FullName AS AssignedToName, uBy.FullName AS AssignedByName
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId";
                
                if (filter != "All")
                {
                    if (filter == "Completed") query += " WHERE t.Status = 'Completed'";
                    else if (filter == "In Progress") query += " WHERE t.Status = 'Working' OR t.Status = 'Pending'";
                    else if (filter == "Appealed") query += " WHERE t.Status = 'Appealed'";
                }
                
                query += " ORDER BY t.CreatedAt DESC";

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

        protected void ddlReportFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadGlobalTasks();
        }

        protected void btnAdminCreateTask_Click(object sender, EventArgs e)
        {
            int adminId = Convert.ToInt32(Session["UserId"]);

            if (string.IsNullOrEmpty(ddlGroups.SelectedValue))
            {
                lblMessage.Text = "Please select a target group.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            int groupId = Convert.ToInt32(ddlGroups.SelectedValue);
            string title = txtTaskTitle.Text.Trim();
            string description = txtTaskDescription.Text.Trim();
            string points = txtPointsToCover.Text.Trim();
            DateTime? dueDate = string.IsNullOrEmpty(txtDueDate.Text) ? (DateTime?)null : Convert.ToDateTime(txtDueDate.Text);

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
                    cmd.Parameters.AddWithValue("@AssignedTo", leaderId);
                    cmd.Parameters.AddWithValue("@TaskLevel", "AdminToLeader");
                    cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", "Working");

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Send email to Leader
                try
                {
                    string infoSql = @"
                        SELECT u.FullName AS LeaderName, u.Email AS LeaderEmail, g.GroupName
                        FROM Users u
                        INNER JOIN Groups g ON u.UserId = g.LeaderId
                        WHERE g.GroupId = @GroupId";
                    using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                    {
                        infoCmd.Parameters.AddWithValue("@GroupId", groupId);
                        // Connection is already open
                        using (SqlDataReader rdr = infoCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string leaderName = rdr["LeaderName"].ToString();
                                string leaderEmail = rdr["LeaderEmail"].ToString();
                                string groupName = rdr["GroupName"].ToString();
                                string adminName = Session["FullName"]?.ToString() ?? "System Admin";

                                Project_Board.Services.EmailService.SendFacultyTaskAssignedToLeader(
                                    leaderEmail,
                                    leaderName,
                                    adminName,
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
                    System.Diagnostics.Debug.WriteLine(ex.Message);
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

        protected void btnUpdateTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ConnString)) return;

            string taskIdStr = hdnEditTaskId.Value;
            string title = txtEditTaskTitle.Text.Trim();
            string desc = txtEditTaskDesc.Text.Trim();
            string status = ddlEditTaskStatus.SelectedValue;

            int taskId;
            if (!int.TryParse(taskIdStr, out taskId)) return;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                // Note: handling both 'Task' and 'Tasks' depending on schema
                string query = "UPDATE Tasks SET TaskTitle = @Title, TaskDescription = @Desc, Status = @Status WHERE TaskId = @TaskId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Title", title);
                    cmd.Parameters.AddWithValue("@Desc", desc);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@TaskId", taskId);
                    try
                    {
                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        
                        // Fallback if the table is named Task instead of Tasks
                        if (rowsAffected == 0)
                        {
                            cmd.CommandText = "UPDATE Task SET TaskTitle = @Title, TaskDescription = @Desc, Status = @Status WHERE TaskId = @TaskId";
                            cmd.ExecuteNonQuery();
                        }

                        LoadGlobalTasks();
                        lblEditMessage.ForeColor = System.Drawing.Color.Green;
                        lblEditMessage.Text = "Task updated successfully.";
                        ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal", "closeModal('editTaskModal');", true);
                    }
                    catch (Exception ex)
                    {
                        lblEditMessage.ForeColor = System.Drawing.Color.Red;
                        lblEditMessage.Text = "Error updating task: " + ex.Message;
                    }
                }
            }
        }

        protected void btnGeneratePdf_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ConnString)) return;
            string filter = ddlReportFilter.SelectedValue;
            
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT 
                        t.TaskTitle AS [Task Title],
                        t.TaskDescription AS [Description],
                        g.GroupName AS [Group Name],
                        u_to.FullName AS [Assigned To],
                        u_by.FullName AS [Assigned By],
                        t.TaskLevel AS [Task Level],
                        t.Status AS [Status],
                        t.DueDate AS [Due Date]
                    FROM Tasks t
                    LEFT JOIN Groups g ON t.GroupId = g.GroupId
                    LEFT JOIN Users u_to ON t.AssignedTo = u_to.UserId
                    LEFT JOIN Users u_by ON t.AssignedBy = u_by.UserId";

                if (filter != "All")
                {
                    if (filter == "Completed") query += " WHERE t.Status = 'Completed'";
                    else if (filter == "In Progress") query += " WHERE t.Status = 'Working' OR t.Status = 'Pending'";
                    else if (filter == "Appealed") query += " WHERE t.Status = 'Appealed'";
                }
                
                query += " ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        // Apply Column Selection
                        List<string> selectedCols = new List<string>();
                        if (chkColTaskTitle.Checked) selectedCols.Add("Task Title");
                        if (chkColTaskDescription.Checked) selectedCols.Add("Description");
                        if (chkColGroupName.Checked) selectedCols.Add("Group Name");
                        if (chkColAssignedTo.Checked) selectedCols.Add("Assigned To");
                        if (chkColAssignedBy.Checked) selectedCols.Add("Assigned By");
                        if (chkColLevel.Checked) selectedCols.Add("Task Level");
                        if (chkColStatus.Checked) selectedCols.Add("Status");
                        if (chkColDueDate.Checked) selectedCols.Add("Due Date");
                        
                        string userName = Session["FullName"]?.ToString() ?? "Admin";
                        string userEmail = Session["Email"]?.ToString() ?? "admin@example.com";
                        
                        byte[] pdfBytes = Project_Board.Utils.ReportService.GeneratePdfReport("Global Task Report - " + filter, dt, userName, userEmail, selectedCols);
                        
                        Response.Clear();
                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition", "attachment;filename=Admin_TaskReport.pdf");
                        Response.BinaryWrite(pdfBytes);
                        Response.End();
                    }
                }
            }
        }
    }
}

