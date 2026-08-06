using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Faculty
{
    public partial class TaskDetails : Page
    {
        protected string UserInitials { get; set; } = "FM";
        protected string UserName { get; set; } = "Faculty Member";
        protected string UserEmail { get; set; } = "faculty@example.com";
        protected int CurrentTaskId { get; set; } = 0;
        protected int CurrentAppealId { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || (Session["Role"]?.ToString() != "Faculty" && Session["Role"]?.ToString() != "Admin"))
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

            if (!int.TryParse(Request.QueryString["TaskId"], out int taskId))
            {
                Response.Redirect("~/Faculty/TaskManagement.aspx");
                return;
            }

            CurrentTaskId = taskId;

            if (!IsPostBack)
            {
                LoadTaskDetails();
            }
        }

        private void LoadTaskDetails()
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                // Fetch Task Details
                string taskSql = @"
                    SELECT t.*, g.GroupName, uTo.FullName AS AssignedToName, uTo.IsLeader, uBy.FullName AS AssignedByName
                    FROM Task t
                    INNER JOIN Groups g ON t.GroupId = g.GroupId
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand cmd = new SqlCommand(taskSql, conn))
                {
                    cmd.Parameters.AddWithValue("@TaskId", CurrentTaskId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            lblTaskTitle.Text = rdr["TaskTitle"].ToString();
                            lblGroupName.Text = rdr["GroupName"].ToString();
                            lblAssignedTo.Text = rdr["AssignedToName"].ToString();
                            
                            bool isLeader = Convert.ToBoolean(rdr["IsLeader"]);
                            lblStudentRole.Text = isLeader ? "Group Leader" : "Group Member";

                            lblAssignedBy.Text = rdr["AssignedByName"].ToString();
                            lblDueDate.Text = rdr["DueDate"] != DBNull.Value ? Convert.ToDateTime(rdr["DueDate"]).ToString("MMM dd, yyyy") : "No Due Date";
                            lblStatus.Text = rdr["Status"].ToString();

                            lblDescription.Text = rdr["TaskDescription"] != DBNull.Value ? rdr["TaskDescription"].ToString() : "N/A";
                            lblPointsToCover.Text = rdr["PointsToCover"] != DBNull.Value ? rdr["PointsToCover"].ToString() : "N/A";

                            lblReportText.Text = rdr["ReportText"] != DBNull.Value ? rdr["ReportText"].ToString() : "No submission yet";
                            lblReportSubmittedAt.Text = rdr["ReportSubmittedAt"] != DBNull.Value ? Convert.ToDateTime(rdr["ReportSubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt") : "N/A";

                            string existingFeedback = rdr["FeedbackText"] != DBNull.Value ? rdr["FeedbackText"].ToString() : "";
                            if (!string.IsNullOrEmpty(existingFeedback) && string.IsNullOrEmpty(txtRemarks.Text))
                            {
                                txtRemarks.Text = existingFeedback;
                            }
                        }
                        else
                        {
                            Response.Redirect("~/Faculty/TaskManagement.aspx");
                            return;
                        }
                    }
                }

                // Fetch Appeal Information if exists
                string appealSql = @"
                    SELECT TOP 1 a.*, uRev.FullName AS ReviewerName
                    FROM Appeals a
                    LEFT JOIN Users uRev ON a.ReviewerId = uRev.UserId
                    WHERE a.TaskId = @TaskId
                    ORDER BY a.CreatedAt DESC";

                using (SqlCommand aCmd = new SqlCommand(appealSql, conn))
                {
                    aCmd.Parameters.AddWithValue("@TaskId", CurrentTaskId);
                    using (SqlDataReader aRdr = aCmd.ExecuteReader())
                    {
                        if (aRdr.Read())
                        {
                            pnlAppealSection.Visible = true;
                            CurrentAppealId = Convert.ToInt32(aRdr["AppealId"]);
                            ViewState["CurrentAppealId"] = CurrentAppealId;

                            lblAppealReason.Text = aRdr["Reason"].ToString();
                            lblAppealStatus.Text = aRdr["Status"].ToString();
                            lblAppealCreatedAt.Text = Convert.ToDateTime(aRdr["CreatedAt"]).ToString("MMM dd, yyyy hh:mm tt");
                            lblReviewerName.Text = aRdr["ReviewerName"] != DBNull.Value ? aRdr["ReviewerName"].ToString() : "Pending Review";
                            lblReviewerRemarks.Text = aRdr["Remarks"] != DBNull.Value ? aRdr["Remarks"].ToString() : "No remarks provided";

                            btnAcceptAppeal.Visible = (aRdr["Status"].ToString() == "Pending Review");
                            btnRejectAppeal.Visible = (aRdr["Status"].ToString() == "Pending Review");
                        }
                        else
                        {
                            pnlAppealSection.Visible = false;
                            btnAcceptAppeal.Visible = false;
                            btnRejectAppeal.Visible = false;
                        }
                    }
                }
            }
        }

        protected void btnMarkCompleted_Click(object sender, EventArgs e)
        {
            UpdateTaskStatus("Completed", "Task marked as completed.");
        }

        protected void btnRejectCompletion_Click(object sender, EventArgs e)
        {
            string idStr = Request.QueryString["TaskId"];
            if (!string.IsNullOrEmpty(idStr))
            {
                Response.Redirect($"~/Faculty/RejectionForm.aspx?type=Task&id={idStr}");
            }
        }

        protected void btnAcceptAppeal_Click(object sender, EventArgs e)
        {
            ReviewAppeal("Accepted", "Appeal accepted and task marked as completed.");
        }

        protected void btnRejectAppeal_Click(object sender, EventArgs e)
        {
            string idStr = Request.QueryString["TaskId"];
            if (!string.IsNullOrEmpty(idStr))
            {
                Response.Redirect($"~/Faculty/RejectionForm.aspx?type=Appeal&id={idStr}");
            }
        }

        private void UpdateTaskStatus(string status, string message)
        {
            int reviewerId = Convert.ToInt32(Session["UserId"]);
            string remarks = txtRemarks.Text.Trim();
            string facultyName = Session["FullName"]?.ToString() ?? "Faculty Mentor";

            string taskTitle = "";
            string assignedToEmail = "";
            string assignedToName = "";

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                // Fetch task details for email notification
                string infoSql = @"
                    SELECT t.TaskTitle, uTo.Email AS AssignedToEmail, uTo.FullName AS AssignedToName
                    FROM Task t
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                {
                    infoCmd.Parameters.AddWithValue("@TaskId", CurrentTaskId);
                    using (SqlDataReader rdr = infoCmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            taskTitle = rdr["TaskTitle"].ToString();
                            assignedToEmail = rdr["AssignedToEmail"].ToString();
                            assignedToName = rdr["AssignedToName"].ToString();
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "UPDATE_STATUS");
                    cmd.Parameters.AddWithValue("@TaskId", CurrentTaskId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@FeedbackText", remarks);

                    cmd.ExecuteNonQuery();
                }
            }

            // Send notification email to assigned leader/member
            if (!string.IsNullOrEmpty(assignedToEmail))
            {
                try
                {
                    Project_Board.Services.EmailService.SendTaskStatusUpdatedNotification(
                        assignedToEmail,
                        assignedToName,
                        facultyName,
                        taskTitle,
                        status,
                        remarks
                    );
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Email Error] {ex.Message}");
                }
            }

            Response.Redirect("~/Faculty/TaskManagement.aspx");
        }

        private void ReviewAppeal(string appealStatus, string message)
        {
            int reviewerId = Convert.ToInt32(Session["UserId"]);
            int appealId = ViewState["CurrentAppealId"] != null ? Convert.ToInt32(ViewState["CurrentAppealId"]) : 0;
            string remarks = txtRemarks.Text.Trim();
            string facultyName = Session["FullName"]?.ToString() ?? "Faculty Mentor";

            if (appealId == 0) return;

            string taskTitle = "";
            string assignedToEmail = "";
            string assignedToName = "";

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                string infoSql = @"
                    SELECT t.TaskTitle, uTo.Email AS AssignedToEmail, uTo.FullName AS AssignedToName
                    FROM Task t
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                {
                    infoCmd.Parameters.AddWithValue("@TaskId", CurrentTaskId);
                    using (SqlDataReader rdr = infoCmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            taskTitle = rdr["TaskTitle"].ToString();
                            assignedToEmail = rdr["AssignedToEmail"].ToString();
                            assignedToName = rdr["AssignedToName"].ToString();
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand("sp_crud_appeals", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "REVIEW");
                    cmd.Parameters.AddWithValue("@AppealId", appealId);
                    cmd.Parameters.AddWithValue("@Status", appealStatus);
                    cmd.Parameters.AddWithValue("@ReviewerId", reviewerId);
                    cmd.Parameters.AddWithValue("@Remarks", remarks);

                    cmd.ExecuteNonQuery();
                }
            }

            if (!string.IsNullOrEmpty(assignedToEmail))
            {
                try
                {
                    string mappedStatus = appealStatus == "Accepted" ? "Completed" : "Revision Needed";
                    Project_Board.Services.EmailService.SendTaskStatusUpdatedNotification(
                        assignedToEmail,
                        assignedToName,
                        facultyName,
                        taskTitle,
                        mappedStatus,
                        remarks
                    );
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Email Error] {ex.Message}");
                }
            }

            Response.Redirect("~/Faculty/TaskManagement.aspx");
        }
    }
}
