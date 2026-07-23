using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Admin.Details
{
    public partial class Project_Details : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "AD";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Administrator";
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

            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string queryDetails = @"
                    SELECT p.ProjectTitle, p.ProjectType, p.Functionality, p.Status, p.SubmittedAt, g.GroupName
                    FROM Projects p
                    INNER JOIN Groups g ON p.GroupId = g.GroupId
                    WHERE p.ProjectId = @ProjectId";

                using (SqlCommand cmd = new SqlCommand(queryDetails, conn))
                {
                    cmd.Parameters.AddWithValue("@ProjectId", projectId);
                    
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
                        }
                        else
                        {
                            ShowError("Project not found.");
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

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "form-message error";
            lblMessage.Visible = true;
            DetailsContainer.Visible = false;
        }
    }
}
