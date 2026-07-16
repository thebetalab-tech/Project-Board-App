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
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
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
                    JOIN Groups g ON p.GroupId = g.GroupId
                    ORDER BY p.SubmittedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
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
                newStatus = "Rejected";
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
    }
}