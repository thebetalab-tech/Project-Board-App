using System.Collections.Generic;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;
using Project_Board.Admin;
using Project_Board.Services;

namespace Project_Board.Student.Leader
{
    public partial class Leader_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "TL";
        protected string UserName { get; set; } = "Student Leader";
        protected string UserEmail { get; set; } = "leader@example.com";
        protected string GroupName { get; set; } = "Group Workspace";

        protected int TotalMentorTasks { get; set; } = 0;
        protected int PendingMentorTasks { get; set; } = 0;
        protected int InProgressMentorTasks { get; set; } = 0;
        protected int CompletedMentorTasks { get; set; } = 0;

        protected int TotalMemberTasks { get; set; } = 0;
        protected int MemberTasksCompleted { get; set; } = 0;
        protected int CurrentGroupId { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Leader";
            UserEmail = Session["Email"]?.ToString() ?? "leader@example.com";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadCurrentGroupId();
                LoadMentorTasks();
                LoadGroupMembers();
                LoadParentTasksDropdown();
                LoadMemberTasks();
                txtMemberTaskDueDate.Attributes["min"] = DateTime.Now.ToString("yyyy-MM-dd");
            }
            else
            {
                LoadCurrentGroupId();
            }
        }

        private void LoadCurrentGroupId()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT GroupId, GroupName FROM Groups WHERE LeaderId = @LeaderId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            CurrentGroupId = Convert.ToInt32(rdr["GroupId"]);
                            GroupName = rdr["GroupName"].ToString();
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

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT gm.UserId, u.FullName, u.Email, u.EnrollmentNo
                    FROM GroupMembers gm
                    INNER JOIN Users u ON gm.UserId = u.UserId
                    WHERE gm.GroupId = @GroupId AND gm.JoinStatus = 'Accepted' AND gm.UserId != @LeaderId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string text = $"{reader["FullName"]} ({reader["EnrollmentNo"]})";
                            ddlMembers.Items.Add(new ListItem(text, reader["UserId"].ToString()));
                        }
                    }
                }
            }
        }

        private void LoadParentTasksDropdown()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            ddlParentTask.Items.Clear();
            ddlParentTask.Items.Add(new ListItem("-- None (Standalone Task) --", ""));

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                int groupId = CurrentGroupId;
                string query = @"
                    SELECT t.TaskId, t.TaskTitle 
                    FROM Task t
                    WHERE t.GroupId = @GroupId 
                      AND t.TaskLevel IN ('MentorToLeader', 'AdminToLeader', 'AdminToAll')
                    ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);

                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string title = reader["TaskTitle"].ToString();
                            string id = reader["TaskId"].ToString();
                            ddlParentTask.Items.Add(new ListItem(title, id));
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
                string query = @"
                    SELECT 
                        t.*,
                        uBy.FullName AS AssignedByName,
                        uTo.FullName AS AssignedToName,
                        g.GroupName,
                        ISNULL(p.TaskTitle, '') AS ParentTaskTitle
                    FROM Task t
                    INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    LEFT JOIN Task p ON t.ParentTaskId = p.TaskId
                    WHERE t.TaskLevel IN ('MentorToLeader', 'AdminToLeader', 'AdminToAll')
                      AND (t.AssignedBy = @UserId OR t.AssignedTo = @UserId)
                    ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
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
                if (st == "Pending" || st == "Working" || st == "Revision Needed" || st == "Failed") PendingMentorTasks++;
                else if (st == "In Progress" || st == "Appealed") InProgressMentorTasks++;
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
            if (e.CommandName == "ReportToMentor")
            {
                int taskId = Convert.ToInt32(e.CommandArgument);
                Response.Redirect($"~/Student/Appeal.aspx?TaskId={taskId}");
            }
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
            int? parentTaskId = null;
            if (!string.IsNullOrEmpty(ddlParentTask.SelectedValue))
            {
                parentTaskId = Convert.ToInt32(ddlParentTask.SelectedValue);
            }

            string taskCategory = ddlTaskCategory.SelectedValue;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                if (taskCategory == "Project Task")
                {
                    bool hasProject = false;
                    using (SqlCommand cmdProject = new SqlCommand("SELECT 1 FROM Projects WHERE GroupId = @GroupId AND Status = 'Approved'", conn))
                    {
                        cmdProject.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                        conn.Open();
                        hasProject = cmdProject.ExecuteScalar() != null;
                    }
                    if (!hasProject)
                    {
                        lblMessage.Text = "Cannot assign a Project Task because there is no approved project in this group.";
                        lblMessage.CssClass = "alert alert-danger";
                        lblMessage.Visible = true;
                        return;
                    }
                }
                else
                {
                    conn.Open();
                }

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
                    cmd.Parameters.AddWithValue("@ParentTaskId", (object)parentTaskId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", "Working");
                    cmd.Parameters.AddWithValue("@TaskCategory", taskCategory);

                    cmd.ExecuteNonQuery();
                }

                // Send email to assigned member (Scenario 3)
                try
                {
                    string memSql = "SELECT FullName, Email FROM Users WHERE UserId = @UserId";
                    using (SqlCommand memCmd = new SqlCommand(memSql, conn))
                    {
                        memCmd.Parameters.AddWithValue("@UserId", memberId);
                        using (SqlDataReader rdr = memCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string memberName = rdr["FullName"].ToString();
                                string memberEmail = rdr["Email"].ToString();
                                string leaderName = Session["FullName"]?.ToString() ?? "Student Leader";

                                EmailService.SendTaskAssignedToMember(
                                    memberEmail,
                                    memberName,
                                    leaderName,
                                    title,
                                    description,
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

            txtMemberTaskTitle.Text = "";
            txtMemberTaskDescription.Text = "";
            txtMemberTaskDueDate.Text = "";
            ddlMembers.SelectedIndex = 0;
            ddlParentTask.SelectedIndex = 0;

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
                Response.Redirect($"~/Student/Leader/ReviewAppeal.aspx?TaskId={taskId}");
            }
            else if (e.CommandName == "DeleteMemberTask")
            {
                int leaderId = Convert.ToInt32(Session["UserId"]);
                string leaderName = Session["FullName"]?.ToString() ?? "Leader";

                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    conn.Open();

                    // ── AUDIT: Snapshot task details before deletion ──────────────
                    string snapshotSql = @"
                        SELECT t.TaskTitle, t.TaskDescription, t.Status, t.TaskLevel, t.TaskCategory,
                               t.DueDate, t.CreatedAt,
                               uTo.FullName AS AssignedToName,
                               uBy.FullName AS AssignedByName
                        FROM Task t
                        INNER JOIN Groups g ON t.GroupId = g.GroupId
                        INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                        WHERE t.TaskId = @TaskId";

                    string taskTitle = $"Task #{taskId}";
                    string taskDetails = "";

                    using (SqlCommand snapCmd = new SqlCommand(snapshotSql, conn))
                    {
                        snapCmd.Parameters.AddWithValue("@TaskId", taskId);
                        using (SqlDataReader rdr = snapCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                taskTitle = rdr["TaskTitle"]?.ToString() ?? taskTitle;
                                string dueDate = rdr["DueDate"] != DBNull.Value
                                    ? Convert.ToDateTime(rdr["DueDate"]).ToString("dd MMM yyyy")
                                    : "No due date";
                                string createdAt = rdr["CreatedAt"] != DBNull.Value
                                    ? Convert.ToDateTime(rdr["CreatedAt"]).ToString("dd MMM yyyy")
                                    : "N/A";
                                taskDetails = $"{{Title: {taskTitle}, AssignedTo: {rdr["AssignedToName"]}, AssignedBy: {rdr["AssignedByName"]}, Level: {rdr["TaskLevel"]}, Category: {rdr["TaskCategory"]}, Status: {rdr["Status"]}, DueDate: {dueDate}, CreatedAt: {createdAt}}}";
                            }
                        }
                    }

                    Admin_DeletedRecords.LogDeletion(conn, "Task", taskId, taskTitle, taskDetails,
                        leaderId > 0 ? (int?)leaderId : null, leaderName);

                    // ── HARD DELETE ──────────────────────────────────────────────
                    using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "DELETE");
                        cmd.Parameters.AddWithValue("@TaskId", taskId);
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadMemberTasks();
            }
        }

        protected void btnGenerateMentorPdf_Click(object sender, EventArgs e)
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT 
                        t.TaskTitle AS [Task Title],
                        t.TaskDescription AS [Description],
                        uBy.FullName AS [Assigned By],
                        t.DueDate AS [Due Date],
                        t.Status AS [Status]
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                    WHERE t.AssignedTo = @LeaderId AND t.TaskLevel IN ('MentorToLeader', 'AdminToLeader', 'AdminToAll')
                    ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        List<string> selectedCols = new List<string>();
                        if (chkMentorColTaskTitle.Checked) selectedCols.Add("Task Title");
                        if (chkMentorColDescription.Checked) selectedCols.Add("Description");
                        if (chkMentorColAssignedBy.Checked) selectedCols.Add("Assigned By");
                        if (chkMentorColDueDate.Checked) selectedCols.Add("Due Date");
                        if (chkMentorColStatus.Checked) selectedCols.Add("Status");

                        string userName = Session["FullName"]?.ToString() ?? "Student Leader";
                        string userEmail = Session["Email"]?.ToString() ?? "leader@example.com";
                        
                        byte[] pdfBytes = Project_Board.Utils.ReportService.GeneratePdfReport("Tasks Received From Mentor", dt, userName, userEmail, selectedCols);
                        
                        Response.Clear();
                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition", "attachment;filename=Leader_MentorTasksReport.pdf");
                        Response.BinaryWrite(pdfBytes);
                        Response.End();
                    }
                }
            }
        }

        protected void btnGenerateMemberPdf_Click(object sender, EventArgs e)
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT 
                        t.TaskTitle AS [Task Title],
                        t.TaskDescription AS [Description],
                        uTo.FullName AS [Assigned Member],
                        t.TaskCategory AS [Category],
                        t.DueDate AS [Due Date],
                        t.Status AS [Status]
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    WHERE t.AssignedBy = @LeaderId AND t.TaskLevel = 'LeaderToMember'
                    ORDER BY t.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        List<string> selectedCols = new List<string>();
                        if (chkMemberColTaskTitle.Checked) selectedCols.Add("Task Title");
                        if (chkMemberColDescription.Checked) selectedCols.Add("Description");
                        if (chkMemberColAssignedTo.Checked) selectedCols.Add("Assigned Member");
                        if (chkMemberColDueDate.Checked) selectedCols.Add("Due Date");
                        if (chkMemberColStatus.Checked) selectedCols.Add("Status");

                        string userName = Session["FullName"]?.ToString() ?? "Student Leader";
                        string userEmail = Session["Email"]?.ToString() ?? "leader@example.com";
                        
                        byte[] pdfBytes = Project_Board.Utils.ReportService.GeneratePdfReport("Tasks Assigned To Members", dt, userName, userEmail, selectedCols);
                        
                        Response.Clear();
                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition", "attachment;filename=Leader_MemberTasksReport.pdf");
                        Response.BinaryWrite(pdfBytes);
                        Response.End();
                    }
                }
            }
        }
    }
}

