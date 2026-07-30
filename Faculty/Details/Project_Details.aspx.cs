using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using Project_Board.Services;

namespace Project_Board.Faculty.Details
{
    public partial class Project_Details : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "FM";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Faculty")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Faculty Member";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }

                if (Request.QueryString["ProjectId"] != null)
                {
                    LoadProjectDetails(Request.QueryString["ProjectId"]);
                }
                else
                {
                    ShowError("Project ID is missing.");
                }
            }
        }

        private void LoadProjectDetails(string projectIdStr)
        {
            if (!int.TryParse(projectIdStr, out int projectId))
            {
                ShowError("Invalid Project ID.");
                return;
            }

            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string queryDetails = @"
                    SELECT p.ProjectTitle, p.ProjectType, p.Functionality, p.Status, p.SubmittedAt, g.GroupName
                    FROM Projects p
                    INNER JOIN Groups g ON p.GroupId = g.GroupId
                    WHERE p.ProjectId = @ProjectId AND g.MentorId = @FacultyId";

                using (SqlCommand cmd = new SqlCommand(queryDetails, conn))
                {
                    cmd.Parameters.AddWithValue("@ProjectId", projectId);
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litProjectTitle.Text = reader["ProjectTitle"].ToString();
                            litGroupName.Text = reader["GroupName"].ToString();
                            litProjectType.Text = reader["ProjectType"].ToString() == "IDP" ? "Industry Defined Project (IDP)" : "User Defined Project (UDP)";
                            
                            string status = reader["Status"].ToString();
                            litStatus.Text = $"<span class='badge status-{status.ToLower()}'>{status}</span>";
                            
                            litSubmittedAt.Text = Convert.ToDateTime(reader["SubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt");
                            litFunctionality.Text = reader["Functionality"].ToString().Replace("\n", "<br/>");

                            // Set button visibility based on current status
                            if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                            {
                                btnApprove.Visible = false;
                                btnReject.Visible = true;
                            }
                            else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                            {
                                btnApprove.Visible = true;
                                btnReject.Visible = false;
                            }
                            else
                            {
                                btnApprove.Visible = true;
                                btnReject.Visible = true;
                            }
                        }
                        else
                        {
                            ShowError("Project not found or you do not have permission to view it.");
                            return;
                        }
                    }
                }

                string queryKeywords = @"
                    SELECT Keyword
                    FROM ProjectKeywords
                    WHERE ProjectId = @ProjectId";

                using (SqlCommand cmdKeywords = new SqlCommand(queryKeywords, conn))
                {
                    cmdKeywords.Parameters.AddWithValue("@ProjectId", projectId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmdKeywords))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptKeywords.DataSource = dt;
                        rptKeywords.DataBind();
                    }
                }
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            UpdateProjectStatus("Approved");
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            UpdateProjectStatus("Rejected");
        }

        private void UpdateProjectStatus(string newStatus)
        {
            if (!int.TryParse(Request.QueryString["ProjectId"], out int projectId)) return;

            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string update = "UPDATE Projects SET Status = @Status WHERE ProjectId = @ProjectId";
                using (SqlCommand cmd = new SqlCommand(update, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@ProjectId", projectId);
                    cmd.ExecuteNonQuery();
                }

                string infoQuery = @"
                    SELECT p.ProjectTitle, g.GroupName, u.Email AS LeaderEmail, u.FullName AS LeaderName
                    FROM Projects p
                    INNER JOIN Groups g ON p.GroupId = g.GroupId
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    WHERE p.ProjectId = @ProjectId";

                using (SqlCommand iCmd = new SqlCommand(infoQuery, conn))
                {
                    iCmd.Parameters.AddWithValue("@ProjectId", projectId);
                    using (SqlDataReader rdr = iCmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string projectTitle = rdr["ProjectTitle"].ToString();
                            string groupName = rdr["GroupName"].ToString();
                            string leaderEmail = rdr["LeaderEmail"].ToString();
                            string leaderName = rdr["LeaderName"].ToString();
                            string facultyName = Session["FullName"]?.ToString() ?? "Faculty Mentor";

                            EmailService.SendProjectStatusNotificationToLeader(
                                leaderEmail,
                                leaderName,
                                facultyName,
                                groupName,
                                projectTitle,
                                newStatus
                            );
                        }
                    }
                }
            }

            lblMessage.Text = $"Project has been successfully marked as '{newStatus}'. Notification email sent to Leader.";
            lblMessage.CssClass = "form-message success";
            lblMessage.Visible = true;

            LoadProjectDetails(projectId.ToString());
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "form-message error";
            lblMessage.Visible = true;
            DetailsContainer.Visible = false;
        }
    }
}