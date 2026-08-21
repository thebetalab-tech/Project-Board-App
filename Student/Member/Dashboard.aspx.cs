using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Student.Member
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected string UserName { get; set; } = "Student Member";
        protected string UserEmail { get; set; } = "member@example.com";

        protected bool IsAssigned { get; set; } = false;
        protected bool MemberNeeded { get; set; } = true;
        protected string GroupName { get; set; } = "Not Assigned";
        protected string TechName { get; set; } = "Not Assigned";
        protected string LeaderName { get; set; } = "Not Assigned";
        protected string LeaderInitials { get; set; } = "TL";
        protected string LeaderEnrollment { get; set; } = "Not Assigned";
        protected string LeaderEmail { get; set; } = "Not Assigned";

        // Mentor Profile Info
        protected bool IsMentorAssigned { get; set; } = false;
        protected bool IsMentorPending { get; set; } = false;
        protected string MentorName { get; set; } = "Not Assigned";
        protected string MentorEmail { get; set; } = "";
        protected string MentorInitials { get; set; } = "FM";

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Member";
            UserEmail = Session["Email"]?.ToString() ?? "member@example.com";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadDashboardData();
            }
            // Don't redirect in Page_Load - let the page render and show "Not in a Team" message
            // The user can click "Join Group" from the dashboard if they want to join one
        }

        private void LoadDashboardData()
        {
            int userId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                int groupId = 0;

                // Single Source of Truth Query: Identifies Team & Mentor Status for both Leaders and Members
                string query = @"
                    SELECT TOP 1 
                        g.GroupId,
                        g.GroupName,
                        t.TechName,
                        g.MemberNeeded,
                        g.Status AS GroupStatus,
                        g.MentorId,
                        m.FullName AS MentorName,
                        m.Email AS MentorEmail,
                        l.FullName AS LeaderName,
                        l.EnrollmentNo AS LeaderEnrollment,
                        l.Email AS LeaderEmail
                    FROM Groups g
                    LEFT JOIN GroupMembers gm ON g.GroupId = gm.GroupId AND gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted')
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    LEFT JOIN Users l ON g.LeaderId = l.UserId
                    LEFT JOIN Users m ON g.MentorId = m.UserId
                    WHERE g.LeaderId = @UserId OR (gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted'))
                    ORDER BY CASE WHEN g.LeaderId = @UserId THEN 0 ELSE 1 END;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            IsAssigned = true;
                            groupId = Convert.ToInt32(reader["GroupId"]);
                            GroupName = reader["GroupName"].ToString();
                            TechName = reader["TechName"] != DBNull.Value ? reader["TechName"].ToString() : "Not Assigned";
                            LeaderName = reader["LeaderName"] != DBNull.Value ? reader["LeaderName"].ToString() : "Not Assigned";
                            LeaderEnrollment = reader["LeaderEnrollment"] != DBNull.Value ? reader["LeaderEnrollment"].ToString() : "N/A";
                            LeaderEmail = reader["LeaderEmail"] != DBNull.Value ? reader["LeaderEmail"].ToString() : "N/A";

                            if (!string.IsNullOrEmpty(LeaderName))
                            {
                                LeaderInitials = LeaderName.Substring(0, 1).ToUpper();
                            }

                            if (reader["MemberNeeded"] != DBNull.Value)
                            {
                                MemberNeeded = Convert.ToBoolean(reader["MemberNeeded"]);
                            }

                            string grpStatus = reader["GroupStatus"] != DBNull.Value ? reader["GroupStatus"].ToString() : "";

                            if (reader["MentorId"] != DBNull.Value)
                            {
                                MentorName = reader["MentorName"] != DBNull.Value ? reader["MentorName"].ToString() : "Faculty Mentor";
                                MentorEmail = reader["MentorEmail"] != DBNull.Value ? reader["MentorEmail"].ToString() : "";
                                if (!string.IsNullOrEmpty(MentorName)) MentorInitials = MentorName.Substring(0, 1).ToUpper();

                                if (grpStatus.Equals("Assigned Mentor", StringComparison.OrdinalIgnoreCase) ||
                                    grpStatus.Equals("Accepted", StringComparison.OrdinalIgnoreCase) ||
                                    grpStatus.Equals("Active", StringComparison.OrdinalIgnoreCase))
                                {
                                    IsMentorAssigned = true;
                                    IsMentorPending = false;
                                }
                                else if (grpStatus.Equals("Pending Faculty Approval", StringComparison.OrdinalIgnoreCase) ||
                                         grpStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                                {
                                    IsMentorAssigned = false;
                                    IsMentorPending = true;
                                }
                            }
                        }
                    }
                }

                if (groupId > 0)
                {
                    // Load Roster Members
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
                            rptMembers.DataSource = dt;
                            rptMembers.DataBind();
                        }
                    }

                    // Load Member Assigned Tasks
                    string taskSql = @"
                        SELECT t.TaskId, t.TaskTitle, t.TaskDescription, t.DueDate, t.Status, uBy.FullName AS AssignedByName
                        FROM Task t
                        INNER JOIN Users uBy ON t.AssignedBy = uBy.UserId
                        WHERE t.AssignedTo = @UserId AND t.GroupId = @GroupId
                        ORDER BY t.CreatedAt DESC";

                    using (SqlCommand tCmd = new SqlCommand(taskSql, conn))
                    {
                        tCmd.Parameters.AddWithValue("@UserId", userId);
                        tCmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataAdapter da = new SqlDataAdapter(tCmd))
                        {
                            DataTable dtTasks = new DataTable();
                            da.Fill(dtTasks);
                            rptAssignedTasks.DataSource = dtTasks;
                            rptAssignedTasks.DataBind();
                        }
                    }
                }
            }
        }
    }
}