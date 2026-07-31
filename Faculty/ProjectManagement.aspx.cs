using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using Project_Board.Services;

namespace Project_Board.Faculty
{
    public partial class ProjectManagement : System.Web.UI.Page
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
                LoadProjects();
            }
        }

        private void LoadProjects()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string query = @"
                    SELECT p.ProjectId, p.ProjectTitle, p.ProjectType, p.Status, p.SubmittedAt, g.GroupName 
                    FROM Projects p
                    INNER JOIN Groups g ON p.GroupId = g.GroupId
                    WHERE g.MentorId = @FacultyId
                    ORDER BY p.SubmittedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        dt.Columns.Add("Keywords", typeof(string));

                        foreach (DataRow row in dt.Rows)
                        {
                            int projId = Convert.ToInt32(row["ProjectId"]);
                            string kwQuery = "SELECT Keyword FROM ProjectKeywords WHERE ProjectId = @ProjectId";
                            using (SqlCommand kwCmd = new SqlCommand(kwQuery, conn))
                            {
                                kwCmd.Parameters.AddWithValue("@ProjectId", projId);
                                List<string> kwList = new List<string>();
                                using (SqlDataReader rdr = kwCmd.ExecuteReader())
                                {
                                    while (rdr.Read())
                                    {
                                        kwList.Add(rdr["Keyword"].ToString());
                                    }
                                }
                                row["Keywords"] = string.Join(", ", kwList);
                            }
                        }

                        rptProjects.DataSource = dt;
                        rptProjects.DataBind();
                    }
                }
            }
        }

        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int projectId = Convert.ToInt32(e.CommandArgument);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string newStatus = e.CommandName == "Approve" ? "Approved" : "Rejected";
                
                string update = "UPDATE Projects SET Status = @Status WHERE ProjectId = @ProjectId";
                using (SqlCommand cmd = new SqlCommand(update, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@ProjectId", projectId);
                    cmd.ExecuteNonQuery();
                }

                // Retrieve Leader email, name, project title and group name for notification
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
                
                ShowMessage($"Project '{newStatus.ToLower()}' successfully.", e.CommandName == "Approve");
            }
            LoadProjects();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "form-message success" : "form-message error";
            lblMessage.Visible = true;
        }
    }
}
