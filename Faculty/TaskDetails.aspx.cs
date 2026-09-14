using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
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
                    INNER JOIN (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g ON t.GroupId = g.GroupId
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
                            lblTaskTitle.Text = HttpUtility.HtmlEncode(rdr["TaskTitle"].ToString());
                            lblGroupName.Text = HttpUtility.HtmlEncode(rdr["GroupName"].ToString());
                            lblAssignedTo.Text = HttpUtility.HtmlEncode(rdr["AssignedToName"].ToString());

                            bool isLeader = rdr["IsLeader"] != DBNull.Value && Convert.ToBoolean(rdr["IsLeader"]);
                            lblStudentRole.Text = isLeader ? "Group Leader" : "Group Member";

                            lblAssignedBy.Text = HttpUtility.HtmlEncode(rdr["AssignedByName"].ToString());
                            lblDueDate.Text = rdr["DueDate"] != DBNull.Value ? Convert.ToDateTime(rdr["DueDate"]).ToString("MMM dd, yyyy") : "No Due Date";
                            lblStatus.Text = HttpUtility.HtmlEncode(rdr["Status"].ToString());

                            lblDescription.Text = Project_Board.Utils.UiHelper.TextPreview(rdr["TaskDescription"], "N/A");
                            lblPointsToCover.Text = Project_Board.Utils.UiHelper.TextPreview(rdr["PointsToCover"], "N/A");

                            lblReportText.Text = Project_Board.Utils.UiHelper.TextPreview(rdr["ReportText"], "No submission yet");
                            lblReportSubmittedAt.Text = rdr["ReportSubmittedAt"] != DBNull.Value ? Convert.ToDateTime(rdr["ReportSubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt") : "N/A";
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

                            lblAppealReason.Text = Project_Board.Utils.UiHelper.TextPreview(aRdr["Reason"], "N/A");
                            lblAppealStatus.Text = HttpUtility.HtmlEncode(aRdr["Status"].ToString());
                            lblAppealCreatedAt.Text = aRdr["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(aRdr["CreatedAt"]).ToString("MMM dd, yyyy hh:mm tt") : "N/A";
                            lblReviewerName.Text = aRdr["ReviewerName"] != DBNull.Value ? HttpUtility.HtmlEncode(aRdr["ReviewerName"].ToString()) : "Pending Review";
                            lblReviewerRemarks.Text = Project_Board.Utils.UiHelper.TextPreview(aRdr["Remarks"], "No remarks provided");


                        }
                        else
                        {
                            pnlAppealSection.Visible = false;
                        }
                    }
                }
            }
        }


    }
}
