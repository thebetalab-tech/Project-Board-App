using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Project_Board.Admin
{
    public partial class Admin_Analysis : System.Web.UI.Page
    {
        public string UsersByRoleJson { get; set; } = "{}";
        public string ProjectsByStatusJson { get; set; } = "{}";
        public string TasksByStatusJson { get; set; } = "{}";
        public string ProjectsByTechJson { get; set; } = "{}";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
                {
                    Response.Redirect("~/Default.aspx");
                    return;
                }
                


                LoadAnalysisData();
            }
        }

        private void LoadAnalysisData()
        {
            string connString = System.Configuration.ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString
                ?? System.Configuration.ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

            if (string.IsNullOrEmpty(connString)) return;

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            {
                string query = @"
                    SELECT Role, COUNT(1) as Cnt FROM Users WHERE IsActive = 1 GROUP BY Role;
                    SELECT Status, COUNT(1) as Cnt FROM Projects GROUP BY Status;
                    SELECT Status, COUNT(1) as Cnt FROM Task GROUP BY Status;
                    SELECT t.TechName, COUNT(p.ProjectId) as Cnt 
                    FROM Technologies t 
                    LEFT JOIN Groups g ON t.TechId = g.TechId 
                    LEFT JOIN Projects p ON g.GroupId = p.GroupId 
                    GROUP BY t.TechName HAVING COUNT(p.ProjectId) > 0;
                ";

                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                        {
                            System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                            
                            // Users by Role
                            var usersDict = new Dictionary<string, int>();
                            while (reader.Read()) { usersDict[reader["Role"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                            UsersByRoleJson = js.Serialize(usersDict);

                            // Projects by Status
                            if (reader.NextResult())
                            {
                                var projDict = new Dictionary<string, int>();
                                while (reader.Read()) { projDict[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                ProjectsByStatusJson = js.Serialize(projDict);
                            }

                            // Tasks by Status
                            if (reader.NextResult())
                            {
                                var taskDict = new Dictionary<string, int>();
                                while (reader.Read()) { taskDict[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                TasksByStatusJson = js.Serialize(taskDict);
                            }

                            // Projects by Tech
                            if (reader.NextResult())
                            {
                                var techDict = new Dictionary<string, int>();
                                while (reader.Read()) { techDict[reader["TechName"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                ProjectsByTechJson = js.Serialize(techDict);
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
