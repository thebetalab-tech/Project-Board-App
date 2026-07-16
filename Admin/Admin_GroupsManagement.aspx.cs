using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_GroupsManagement : System.Web.UI.Page
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
                userNameLabel.Text = userName;
                userEmailLabel.Text = userEmail;

                LoadGroups();
            }
        }

        private void LoadGroups()
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        g.GroupId,
                        g.GroupName,
                        g.Status,
                        l.FullName AS LeaderName,
                        m.FullName AS MentorName,
                        STUFF((
                            SELECT ', ' + u.FullName 
                            FROM GroupMembers gm 
                            JOIN Users u ON gm.UserId = u.UserId 
                            WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted'
                            FOR XML PATH('')
                        ), 1, 2, '') AS Members
                    FROM Groups g
                    JOIN Users l ON g.LeaderId = l.UserId
                    LEFT JOIN Users m ON g.MentorId = m.UserId
                    ORDER BY g.GroupName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            rptGroups.DataSource = reader;
                            rptGroups.DataBind();
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