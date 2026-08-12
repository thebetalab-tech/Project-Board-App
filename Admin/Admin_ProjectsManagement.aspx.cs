using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_ProjectsManagement : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Fetch user information from session
                string userName = Session["FullName"]?.ToString() ?? "Guest";
                string userEmail = Session["Email"]?.ToString() ?? "No email provided";
                string intial = userName.Substring(0, 1).ToUpper();
                userNameLabel.Text = userName;
                userEmailLabel.Text = userEmail;
                userintial.Text = intial;

                LoadProjects();
            }
        }

        private void LoadProjects()
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        p.ProjectId,
                        p.ProjectTitle,
                        p.Functionality,
                        p.Status,
                        g.GroupName,
                        (
                            SELECT '<span class=""tech-tag"">' + pk.Keyword + '</span>'
                            FROM ProjectKeywords pk 
                            WHERE pk.ProjectId = p.ProjectId
                            FOR XML PATH('')
                        ) AS KeywordHtml
                    FROM Projects p
                    JOIN Groups g ON p.GroupId = g.GroupId";
                
                if (filter != "All")
                {
                    query += " WHERE p.Status = @Status";
                }
                
                query += " ORDER BY p.SubmittedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", filter);
                    }
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            rptProjects.DataSource = reader;
                            rptProjects.DataBind();
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
            }
        }

        protected void ddlReportFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadProjects();
        }

        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int projectId = Convert.ToInt32(e.CommandArgument);
            string newStatus = "";

            if (e.CommandName == "Approve")
            {
                newStatus = "Approved";
            }
                        else if (e.CommandName == "Reject")
            {
                Response.Redirect($"~/Admin/RejectionForm.aspx?type=Project&id={projectId}");
                return;
            }

            if (!string.IsNullOrEmpty(newStatus))
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "UPDATE Projects SET Status = @Status WHERE ProjectId = @ProjectId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@ProjectId", projectId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            LoadProjects();
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine("Error updating project status: " + ex.Message);
                        }
                    }
                }
            }
        }

        protected void btnExportReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;
            
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        p.ProjectTitle AS [Project Title],
                        p.Functionality AS [Functionality],
                        g.GroupName AS [Group Name],
                        p.Status AS [Status],
                        p.CreatedAt AS [Submitted On]
                    FROM Projects p
                    LEFT JOIN Groups g ON p.GroupId = g.GroupId";

                if (filter != "All")
                {
                    query += " WHERE p.Status = @Status";
                }
                
                query += " ORDER BY p.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", filter);
                    }
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        string userName = Session["FullName"]?.ToString() ?? "Admin";
                        string userEmail = Session["Email"]?.ToString() ?? "admin@example.com";
                        
                        Project_Board.Services.ReportService.GeneratePdfReport("Projects Management Report", dt, userName, userEmail, "Status: " + filter, Response);
                    }
                }
            }
        }
    }
}