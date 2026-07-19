using System;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Student.Leader
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected string GroupName { get; set; } = "Not Assigned";
        protected string TechName { get; set; } = "Not Assigned";
        protected int TotalMembers { get; set; } = 0;
        protected int PendingInvites { get; set; } = 0;
        protected int AcceptedInvites { get; set; } = 0;
        protected string UserInitials { get; set; } = "TL";
        protected bool MemberNeeded { get; set; } = true;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            
            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Student Leader";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadDashboardStats();
            }
        }
        
        private void LoadDashboardStats()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT g.GroupName, t.TechName, g.GroupId, g.MemberNeeded
                    FROM Groups g
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    WHERE g.LeaderId = @LeaderId;
                ";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            GroupName = reader["GroupName"].ToString();
                            TechName = reader["TechName"] != DBNull.Value ? reader["TechName"].ToString() : "Not Assigned";
                            int groupId = Convert.ToInt32(reader["GroupId"]);
                            
                            if (reader["MemberNeeded"] != DBNull.Value)
                            {
                                MemberNeeded = Convert.ToBoolean(reader["MemberNeeded"]);
                            }
                            
                            reader.Close();
                            
                            // Get Stats
                            string statsQuery = @"
                                SELECT 
                                    COUNT(UserId) AS Total,
                                    SUM(CASE WHEN JoinStatus = 'Pending' THEN 1 ELSE 0 END) AS Pending,
                                    SUM(CASE WHEN JoinStatus = 'Accepted' THEN 1 ELSE 0 END) AS Accepted
                                FROM GroupMembers
                                WHERE GroupId = @GroupId
                            ";
                            using (SqlCommand statsCmd = new SqlCommand(statsQuery, conn))
                            {
                                statsCmd.Parameters.AddWithValue("@GroupId", groupId);
                                using (SqlDataReader statsReader = statsCmd.ExecuteReader())
                                {
                                    if (statsReader.Read())
                                    {
                                        TotalMembers = statsReader["Total"] != DBNull.Value ? Convert.ToInt32(statsReader["Total"]) : 0;
                                        PendingInvites = statsReader["Pending"] != DBNull.Value ? Convert.ToInt32(statsReader["Pending"]) : 0;
                                        AcceptedInvites = statsReader["Accepted"] != DBNull.Value ? Convert.ToInt32(statsReader["Accepted"]) : 0;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}