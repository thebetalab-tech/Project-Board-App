using System;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Student.Member
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected bool IsAssigned { get; set; } = false;
        protected bool MemberNeeded { get; set; } = true;
        protected string GroupName { get; set; } = "Not Assigned";
        protected string TechName { get; set; } = "Not Assigned";
        protected string LeaderName { get; set; } = "Not Assigned";
        protected string LeaderInitials { get; set; } = "TL";
        protected string LeaderEnrollment { get; set; } = "Not Assigned";
        protected string LeaderEmail { get; set; } = "Not Assigned";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Student Member";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT g.GroupName, t.TechName, g.MemberNeeded,
                           l.FullName AS LeaderName, l.EnrollmentNo AS LeaderEnrollment, l.Email AS LeaderEmail
                    FROM GroupMembers gm
                    JOIN Groups g ON gm.GroupId = g.GroupId
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    JOIN Users l ON g.LeaderId = l.UserId
                    WHERE gm.UserId = @UserId AND gm.JoinStatus = 'Accepted';
                ";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                IsAssigned = true;
                                GroupName = reader["GroupName"].ToString();
                                TechName = reader["TechName"] != DBNull.Value ? reader["TechName"].ToString() : "Not Assigned";
                                LeaderName = reader["LeaderName"].ToString();
                                LeaderEnrollment = reader["LeaderEnrollment"] != DBNull.Value ? reader["LeaderEnrollment"].ToString() : "N/A";
                                LeaderEmail = reader["LeaderEmail"].ToString();

                                if (!string.IsNullOrEmpty(LeaderName))
                                {
                                    LeaderInitials = LeaderName.Substring(0, 1).ToUpper();
                                }

                                if (reader["MemberNeeded"] != DBNull.Value)
                                {
                                    MemberNeeded = Convert.ToBoolean(reader["MemberNeeded"]);
                                }
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