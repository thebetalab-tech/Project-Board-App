using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.User
{
    public partial class PublicProfile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string idStr = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(idStr) && int.TryParse(idStr, out int userId))
                {
                    LoadUserProfile(userId);
                }
                else
                {
                    lblError.Text = "Invalid user specified.";
                }
            }
        }

        private void LoadUserProfile(int userId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
                ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT FullName, Email, Role, IsLeader, EnrollmentNo 
                        FROM Users 
                        WHERE UserId = @UserId AND IsActive = 1";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                pnlProfile.Visible = true;
                                
                                string fullName = reader["FullName"].ToString();
                                string role = reader["Role"].ToString();
                                bool isLeader = Convert.ToBoolean(reader["IsLeader"]);
                                string email = reader["Email"].ToString();
                                string enrollmentNo = reader["EnrollmentNo"]?.ToString();

                                litName.Text = fullName;
                                litAvatar.Text = fullName.Length > 0 ? fullName.Substring(0, 1).ToUpper() : "U";
                                litEmail.Text = email;
                                
                                string displayRole = isLeader ? "Student Leader" : role;
                                string roleClass = "role-" + role.ToLower();
                                litRoleBadge.Text = $"<span class=\"role-badge {roleClass}\">{displayRole}</span>";

                                if (!string.IsNullOrEmpty(enrollmentNo) && role.Equals("Student", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlEnrollment.Visible = true;
                                    litEnrollment.Text = enrollmentNo;
                                }
                            }
                            else
                            {
                                lblError.Text = "User not found or account is inactive.";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Could not load profile: " + ex.Message;
            }
        }
    }
}
