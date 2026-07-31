using System;
using System.Data;
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
        protected string UserName { get; set; } = "Student Leader";
        protected string UserEmail { get; set; } = "leader@example.com";
        protected bool MemberNeeded { get; set; } = true;
        
        // Mentor Information
        protected bool IsMentorAssigned { get; set; } = false;
        protected string MentorName { get; set; } = "Not Assigned";
        protected string MentorEmail { get; set; } = "";
        protected string MentorInitials { get; set; } = "FM";
        protected string GroupStatus { get; set; } = "Forming";

        // Task Statistics
        protected int PendingTasks { get; set; } = 0;
        protected int InProgressTasks { get; set; } = 0;
        protected int CompletedTasks { get; set; } = 0;
        protected int OverdueTasks { get; set; } = 0;
        protected int AppealedTasks { get; set; } = 0;
        protected int TotalGroupTasks { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Leader";
            UserEmail = Session["Email"]?.ToString() ?? "leader@example.com";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = @"
                    SELECT g.GroupName, t.TechName, g.GroupId, g.MemberNeeded
                    FROM Groups g
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    LEFT JOIN Users m ON g.MentorId = m.UserId
                    WHERE g.LeaderId = @LeaderId";

                using (SqlCommand cmd = new SqlCommand(groupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            groupId = Convert.ToInt32(reader["GroupId"]);
                            GroupName = reader["GroupName"].ToString();
                            TechName = reader["TechName"] != DBNull.Value ? reader["TechName"].ToString() : "Not Assigned";
                            int groupId = Convert.ToInt32(reader["GroupId"]);
                            
                            if (reader["MemberNeeded"] != DBNull.Value)
                            {
                                MentorName = reader["MentorName"] != DBNull.Value ? reader["MentorName"].ToString() : "Faculty Mentor";
                                MentorEmail = reader["MentorEmail"] != DBNull.Value ? reader["MentorEmail"].ToString() : "";
                                if (!string.IsNullOrEmpty(MentorName)) MentorInitials = MentorName.Substring(0, 1).ToUpper();

                                if (GroupStatus.Equals("Assigned Mentor", StringComparison.OrdinalIgnoreCase) ||
                                    GroupStatus.Equals("Accepted", StringComparison.OrdinalIgnoreCase) ||
                                    GroupStatus.Equals("Active", StringComparison.OrdinalIgnoreCase))
                                {
                                    IsMentorAssigned = true;
                                }
                            }
                        }
                    }
                }

                if (groupId > 0)
                {
                    // Load Members
                    string memSql = @"
                        SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, u.IsLeader,
                               ISNULL(gm.JoinStatus, 'Accepted') AS JoinStatus,
                               CASE WHEN g.LeaderId = u.UserId THEN 'Leader' ELSE 'Member' END AS Role
                        FROM Users u
                        LEFT JOIN GroupMembers gm ON u.UserId = gm.UserId AND gm.GroupId = @GroupId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted')
                        LEFT JOIN Groups g ON g.GroupId = @GroupId AND g.LeaderId = u.UserId
                        WHERE (gm.GroupId IS NOT NULL OR g.LeaderId IS NOT NULL)
                        ORDER BY CASE WHEN g.LeaderId = u.UserId THEN 0 ELSE 1 END, u.FullName ASC";

                    using (SqlCommand mCmd = new SqlCommand(memSql, conn))
                    {
                        mCmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataAdapter da = new SqlDataAdapter(mCmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            TotalMembers = dt.Rows.Count;
                            rptMembers.DataSource = dt;
                            rptMembers.DataBind();
                        }
                    }

                    // Load Task Statistics
                    string taskSql = "SELECT Status, DueDate FROM Task WHERE GroupId = @GroupId";
                    using (SqlCommand tCmd = new SqlCommand(taskSql, conn))
                    {
                        tCmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataReader tRdr = tCmd.ExecuteReader())
                        {
                            while (tRdr.Read())
                            {
                                TotalGroupTasks++;
                                string st = tRdr["Status"].ToString();
                                DateTime? dueDate = tRdr["DueDate"] != DBNull.Value ? Convert.ToDateTime(tRdr["DueDate"]) : (DateTime?)null;

                                if (st == "Completed") CompletedTasks++;
                                else if (st == "In Progress") InProgressTasks++;
                                else if (st == "Appealed") AppealedTasks++;
                                else PendingTasks++;

                                if (dueDate.HasValue && dueDate.Value < DateTime.Now && st != "Completed") OverdueTasks++;
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