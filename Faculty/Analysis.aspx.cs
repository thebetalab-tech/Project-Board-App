using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

namespace Project_Board.Faculty
{
    public partial class Analysis : System.Web.UI.Page
    {
        public string TasksByStatusJson { get; set; } = "{}";
        public string ProjectsByStatusJson { get; set; } = "{}";
        public string GroupsByStatusJson { get; set; } = "{}";
        public string TechsJson { get; set; } = "{}";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Faculty")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadAnalysisData();
            }
        }

        private void LoadAnalysisData()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString
                ?? ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string chartQuery = @"
                    SELECT Status, COUNT(1) as Cnt FROM Groups WHERE MentorId = @FacultyId GROUP BY Status;
                    
                    SELECT p.Status, COUNT(1) as Cnt 
                    FROM Projects p 
                    INNER JOIN (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g ON p.GroupId = g.GroupId 
                    WHERE g.MentorId = @FacultyId 
                    GROUP BY p.Status;
                    
                    SELECT t.Status, COUNT(1) as Cnt 
                    FROM Task t 
                    INNER JOIN (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g ON t.GroupId = g.GroupId 
                    WHERE g.MentorId = @FacultyId 
                    GROUP BY t.Status;

                    SELECT tech.TechName, COUNT(1) as Cnt 
                    FROM (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g 
                    INNER JOIN Technologies tech ON g.TechId = tech.TechId 
                    WHERE g.MentorId = @FacultyId 
                    GROUP BY tech.TechName;
                ";

                using (SqlCommand cmd = new SqlCommand(chartQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                            
                            // Groups by Status
                            var dictGroups = new Dictionary<string, int>();
                            while (reader.Read()) { dictGroups[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                            GroupsByStatusJson = js.Serialize(dictGroups);

                            // Projects by Status
                            if (reader.NextResult())
                            {
                                var dictProjects = new Dictionary<string, int>();
                                while (reader.Read()) { dictProjects[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                ProjectsByStatusJson = js.Serialize(dictProjects);
                            }

                            // Tasks by Status
                            if (reader.NextResult())
                            {
                                var dictTasks = new Dictionary<string, int>();
                                while (reader.Read()) { dictTasks[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                TasksByStatusJson = js.Serialize(dictTasks);
                            }

                            // Mentored Tech Domains
                            if (reader.NextResult())
                            {
                                var dictTechs = new Dictionary<string, int>();
                                while (reader.Read()) { dictTechs[reader["TechName"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                TechsJson = js.Serialize(dictTechs);
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
