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
        public string UsersByRoleJson { get; set; } = "{}";
        public string ProjectsByStatusJson { get; set; } = "{}";
        public string TasksByStatusJson { get; set; } = "{}";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
                {
                    Response.Redirect("~/Default.aspx");
                    return;
                }


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
                        (SELECT COUNT(1) FROM Technologies) AS TotalTechs,
                        (SELECT CASE WHEN OBJECT_ID('DeletedRecords','U') IS NOT NULL 
                                     THEN (SELECT COUNT(1) FROM DeletedRecords) 
                                     ELSE 0 END) AS TotalDeleted;

                    SELECT Role, COUNT(1) as Cnt FROM Users WHERE IsActive = 1 GROUP BY Role;
                    SELECT Status, COUNT(1) as Cnt FROM Projects GROUP BY Status;
                    SELECT Status, COUNT(1) as Cnt FROM Task GROUP BY Status;
                ";

                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblTotalUsers.Text         = reader["TotalUsers"].ToString();
                                lblTotalGroups.Text        = reader["TotalGroups"].ToString();
                                lblPendingProjects.Text    = reader["PendingProjects"].ToString();
                                lblTotalTechs.Text         = reader["TotalTechs"].ToString();
                                lblTotalDeletedDash.Text   = reader["TotalDeleted"].ToString();
                            }

                            System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                            
                            // Users by Role
                            if (reader.NextResult())
                            {
                                var dict = new Dictionary<string, int>();
                                while (reader.Read()) { dict[reader["Role"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                UsersByRoleJson = js.Serialize(dict);
                            }

                            // Projects by Status
                            if (reader.NextResult())
                            {
                                var dict = new Dictionary<string, int>();
                                while (reader.Read()) { dict[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                ProjectsByStatusJson = js.Serialize(dict);
                            }

                            // Tasks by Status
                            if (reader.NextResult())
                            {
                                var dict = new Dictionary<string, int>();
                                while (reader.Read()) { dict[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                TasksByStatusJson = js.Serialize(dict);
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