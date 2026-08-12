using System;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Faculty
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "FM";
        protected int MentoredGroupsCount { get; set; } = 0;
        protected int ActiveProjectsCount { get; set; } = 0;
        protected int PendingRequestsCount { get; set; } = 0;

        public string TasksByStatusJson { get; set; } = "{}";
        public string ProjectsByStatusJson { get; set; } = "{}";
        public string GroupsByStatusJson { get; set; } = "{}";

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
                LoadDashboardStats();
            }
        }

        private void LoadDashboardStats()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // Pending requests
                string qPending = "SELECT COUNT(*) FROM Groups WHERE MentorId = @FacultyId AND Status = 'Pending Faculty Approval'";
                using (SqlCommand cmd = new SqlCommand(qPending, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    PendingRequestsCount = Convert.ToInt32(cmd.ExecuteScalar());
                }

                // Active mentored groups
                string qGroups = "SELECT COUNT(*) FROM Groups WHERE MentorId = @FacultyId AND Status != 'Pending Faculty Approval' AND Status != 'Forming'";
                using (SqlCommand cmd = new SqlCommand(qGroups, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    MentoredGroupsCount = Convert.ToInt32(cmd.ExecuteScalar());
                }

                // Active projects from mentored groups
                string qProjects = @"
                    SELECT COUNT(*) FROM Projects p
                    INNER JOIN Groups g ON p.GroupId = g.GroupId
                    WHERE g.MentorId = @FacultyId AND g.Status != 'Pending Faculty Approval'";
                using (SqlCommand cmd = new SqlCommand(qProjects, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    ActiveProjectsCount = Convert.ToInt32(cmd.ExecuteScalar());
                }

                string chartQuery = @"
                    SELECT Status, COUNT(1) as Cnt FROM Groups WHERE MentorId = @FacultyId GROUP BY Status;
                    SELECT p.Status, COUNT(1) as Cnt FROM Projects p INNER JOIN Groups g ON p.GroupId = g.GroupId WHERE g.MentorId = @FacultyId GROUP BY p.Status;
                    SELECT t.Status, COUNT(1) as Cnt FROM Task t INNER JOIN Groups g ON t.GroupId = g.GroupId WHERE g.MentorId = @FacultyId GROUP BY t.Status;
                ";

                using (SqlCommand cmd = new SqlCommand(chartQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    try
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                            
                            // Groups by Status
                            var dictGroups = new System.Collections.Generic.Dictionary<string, int>();
                            while (reader.Read()) { dictGroups[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                            GroupsByStatusJson = js.Serialize(dictGroups);

                            // Projects by Status
                            if (reader.NextResult())
                            {
                                var dictProjects = new System.Collections.Generic.Dictionary<string, int>();
                                while (reader.Read()) { dictProjects[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                ProjectsByStatusJson = js.Serialize(dictProjects);
                            }

                            // Tasks by Status
                            if (reader.NextResult())
                            {
                                var dictTasks = new System.Collections.Generic.Dictionary<string, int>();
                                while (reader.Read()) { dictTasks[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                TasksByStatusJson = js.Serialize(dictTasks);
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
