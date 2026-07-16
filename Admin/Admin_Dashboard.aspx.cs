using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace Project_Board.Admin
{
    public partial class Admin_Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["role"] == null || Session["role"].ToString() != "Admin")
                {
                    Response.Redirect("~/Default.aspx");
                    return;
                }
                // Fetch user information from session
                string userName = Session["FullName"]?.ToString() ?? "Guest";
                string userEmail = Session["Email"]?.ToString() ?? "No email provided";
                string intial = userName.Substring(0, 1).ToUpper();
                userNameLabel.Text = userName;
                userEmailLabel.Text = userEmail;
                userintial.Text = intial;

                LoadDashboardStats();
            }
        }

        private void LoadDashboardStats()
        {
            string connString = System.Configuration.ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString
                ?? System.Configuration.ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

            if (string.IsNullOrEmpty(connString)) return;

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        (SELECT COUNT(1) FROM Users WHERE IsActive = 1) AS TotalUsers,
                        (SELECT COUNT(1) FROM Groups) AS TotalGroups,
                        (SELECT COUNT(1) FROM Projects WHERE Status = 'Pending') AS PendingProjects,
                        (SELECT COUNT(1) FROM Technologies) AS TotalTechs";

                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblTotalUsers.Text = reader["TotalUsers"].ToString();
                                lblTotalGroups.Text = reader["TotalGroups"].ToString();
                                lblPendingProjects.Text = reader["PendingProjects"].ToString();
                                lblTotalTechs.Text = reader["TotalTechs"].ToString();
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
            }
        }
    }
}