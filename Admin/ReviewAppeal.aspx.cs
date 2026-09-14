using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;

namespace Project_Board.Admin
{
    public partial class ReviewAppeal : Page
    {
        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
        private int TaskId => Request.QueryString["TaskId"] != null ? Convert.ToInt32(Request.QueryString["TaskId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (TaskId == 0)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadTaskAndAppealDetails();
            }
        }

        private void LoadTaskAndAppealDetails()
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT t.TaskTitle, t.FeedbackText, t.TaskDescription, t.Status, t.AssignedBy, 
                           g.GroupName, u.FullName AS AssignedByName
                    FROM Task t
                    LEFT JOIN (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g ON t.GroupId = g.GroupId
                    INNER JOIN Users u ON t.AssignedBy = u.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TaskId", TaskId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Security check: Only the assignor (Leader/Mentor) can review the appeal
                            int assignedBy = Convert.ToInt32(reader["AssignedBy"]);
                            int currentUserId = Convert.ToInt32(Session["UserId"]);
                            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
                            
                            if (assignedBy != currentUserId && role != "Admin")
                            {
                                lblMessage.Text = "You are not authorized to review this task.";
                                lblMessage.CssClass = "alert alert-danger";
                                lblMessage.Visible = true;
                                btnSubmitDecision.Enabled = false;
                            }

                            lblTaskTitle.Text = HttpUtility.HtmlEncode(reader["TaskTitle"].ToString());
                            lblGroupName.Text = HttpUtility.HtmlEncode(reader["GroupName"] != DBNull.Value ? reader["GroupName"].ToString() : "No Group");
                            lblStatus.Text = HttpUtility.HtmlEncode(reader["Status"].ToString());

                            string feedback = reader["FeedbackText"] != DBNull.Value ? reader["FeedbackText"].ToString() : "";
                            lblRequirements.Text = Project_Board.Utils.UiHelper.TextPreview(feedback, "No previous feedback given.");

                            string desc = reader["TaskDescription"] != DBNull.Value ? reader["TaskDescription"].ToString() : "";
                            lblTaskDescription.Text = Project_Board.Utils.UiHelper.TextPreview(desc, "No description provided.");

                            string currentStatus = reader["Status"].ToString();
                            if (ddlStatus.Items.FindByValue(currentStatus) != null)
                            {
                                ddlStatus.SelectedValue = currentStatus;
                            }
                        }
                    }
                }
                
                // Load Appeal
                string appealSql = "SELECT Reason, ChangesMade, Explanation, IsCompleted, CreatedAt FROM Appeals WHERE TaskId = @TaskId";
                using (SqlCommand cmdAppeal = new SqlCommand(appealSql, conn))
                {
                    cmdAppeal.Parameters.AddWithValue("@TaskId", TaskId);
                    using (SqlDataReader rdr = cmdAppeal.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            lblReason.Text = Project_Board.Utils.UiHelper.TextPreview(rdr["Reason"], "N/A");
                            lblChangesMade.Text = Project_Board.Utils.UiHelper.TextPreview(rdr["ChangesMade"], "N/A");
                            lblExplanation.Text = Project_Board.Utils.UiHelper.TextPreview(rdr["Explanation"], "N/A");
                            
                            bool isCompleted = rdr["IsCompleted"] != DBNull.Value && Convert.ToBoolean(rdr["IsCompleted"]);
                            lblIsCompleted.Text = isCompleted ? "Task is marked as completed by Student" : "Task is NOT marked as completed";
                            lblIsCompleted.ForeColor = isCompleted ? System.Drawing.Color.Green : System.Drawing.Color.Orange;

                            lblCreatedAt.Text = rdr["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(rdr["CreatedAt"]).ToString("MMM dd, yyyy hh:mm tt") : "";
                            
                            pnlAppeal.Visible = true;
                            pnlNoAppeal.Visible = false;
                        }
                        else
                        {
                            pnlAppeal.Visible = false;
                            pnlNoAppeal.Visible = true;
                        }
                    }
                }
            }
        }

        // Re-verifies that the current user is allowed to decide this task's appeal.
        // The check in LoadTaskAndAppealDetails only runs on the initial GET and merely
        // disables the button client-side, which does not stop a forged postback, so the
        // same check must be re-run here before any update is made.
        private bool IsAuthorizedForTask(SqlConnection conn)
        {
            int currentUserId = Convert.ToInt32(Session["UserId"]);
            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
            if (role == "Admin") return true;

            using (SqlCommand cmd = new SqlCommand("SELECT AssignedBy FROM Task WHERE TaskId = @TaskId", conn))
            {
                cmd.Parameters.AddWithValue("@TaskId", TaskId);
                object result = cmd.ExecuteScalar();
                if (result == null || result == DBNull.Value) return false;
                return Convert.ToInt32(result) == currentUserId;
            }
        }

        protected void btnSubmitDecision_Click(object sender, EventArgs e)
        {
            if (TaskId == 0) return;

            string status = ddlStatus.SelectedValue;
            string feedback = txtFeedback.Text.Trim();
            int reviewerId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                if (!IsAuthorizedForTask(conn))
                {
                    lblMessage.Text = "You are not authorized to review this task.";
                    lblMessage.CssClass = "alert alert-danger";
                    lblMessage.Visible = true;
                    btnSubmitDecision.Enabled = false;
                    return;
                }

                string memberEmail = "";
                string memberName = "";
                string taskTitle = "";
                string reviewerName = Session["FullName"]?.ToString() ?? "Reviewer";

                string infoSql = @"
                    SELECT t.TaskTitle, uTo.Email AS MemberEmail, uTo.FullName AS MemberName
                    FROM Task t
                    INNER JOIN Users uTo ON t.AssignedTo = uTo.UserId
                    WHERE t.TaskId = @TaskId";

                using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                {
                    infoCmd.Parameters.AddWithValue("@TaskId", TaskId);
                    using (SqlDataReader rdr = infoCmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            taskTitle = rdr["TaskTitle"].ToString();
                            memberEmail = rdr["MemberEmail"].ToString();
                            memberName = rdr["MemberName"].ToString();
                        }
                    }
                }

                // Update Task state
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "UPDATE_STATUS");
                    cmd.Parameters.AddWithValue("@TaskId", TaskId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@FeedbackText", string.IsNullOrEmpty(feedback) ? (object)DBNull.Value : feedback);
                    cmd.ExecuteNonQuery();
                }

                // Sync Appeals table
                string appealSql = @"
                    UPDATE Appeals 
                    SET Status = CASE 
                        WHEN @Status = 'Completed' THEN 'Accepted'
                        WHEN @Status IN ('Revision Needed', 'Failed') THEN 'Rejected'
                        ELSE Status
                    END,
                    ReviewerId = @ReviewerId,
                    Remarks = @FeedbackText,
                    ReviewedAt = GETDATE()
                    WHERE TaskId = @TaskId;";

                using (SqlCommand aCmd = new SqlCommand(appealSql, conn))
                {
                    aCmd.Parameters.AddWithValue("@Status", status);
                    aCmd.Parameters.AddWithValue("@ReviewerId", reviewerId);
                    aCmd.Parameters.AddWithValue("@FeedbackText", string.IsNullOrEmpty(feedback) ? (object)DBNull.Value : feedback);
                    aCmd.Parameters.AddWithValue("@TaskId", TaskId);
                    aCmd.ExecuteNonQuery();
                }

                // Send Email Notification
                try
                {
                    Project_Board.Services.EmailService.SendTaskStatusUpdatedNotification(memberEmail, memberName, reviewerName, taskTitle, status, feedback);
                    Project_Board.Services.EmailService.SendTaskAppealReviewedEmail(memberEmail, memberName, reviewerName, taskTitle, status == "Completed" ? "Accepted" : "Rejected", "");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Email Error] {ex.Message}");
                }
            }

            // Redirect back to dashboard
            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
            if (role == "Leader")
            {
                Response.Redirect("~/Student/Leader/Leader_TaskManagement.aspx");
            }
            else if (role == "Faculty")
            {
                Response.Redirect("~/Admin/Mentor_TaskManagement.aspx");
            }
            else
            {
                Response.Redirect("~/Admin/Admin_TaskManagement.aspx");
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? "";
            if (role == "Leader")
            {
                Response.Redirect("~/Student/Leader/Leader_TaskManagement.aspx");
            }
            else if (role == "Faculty")
            {
                Response.Redirect("~/Admin/Mentor_TaskManagement.aspx");
            }
            else
            {
                Response.Redirect("~/Admin/Admin_TaskManagement.aspx");
            }
        }
    }
}
