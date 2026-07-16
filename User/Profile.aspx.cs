using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web.UI;

namespace Project_Board.User
{
    public partial class Profile : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfileData();
            }
        }

        private void LoadProfileData()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string role = Session["Role"]?.ToString() ?? "";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Fetch User Details
                string userQuery = "SELECT FullName, Email, EnrollmentNo, Role FROM Users WHERE UserId = @UserId";
                using (SqlCommand cmd = new SqlCommand(userQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string fullName = reader["FullName"].ToString();
                                lblDisplayName.Text = fullName;
                                txtFullName.Text = fullName;
                                txtEmail.Text = reader["Email"].ToString();
                                txtEnrollment.Text = reader["EnrollmentNo"].ToString();
                                lblRoleBadge.Text = role;
                                
                                // Set Initials
                                string initials = "U";
                                if (!string.IsNullOrEmpty(fullName))
                                {
                                    string[] parts = fullName.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                                    if (parts.Length == 1) initials = parts[0].Substring(0, 1).ToUpper();
                                    else initials = (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
                                }
                                avatarInitials.InnerText = initials;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
                
                // Fetch Stats
                string statsQuery = "";
                if (role == "Admin")
                {
                    phStats.Visible = false; // Admins don't need to see personal stats on profile
                    statsQuery = @"
                        SELECT 
                            (SELECT COUNT(1) FROM Groups) AS GroupsCount,
                            (SELECT COUNT(1) FROM Projects) AS ProjectsCount";
                }
                else if (role == "Faculty")
                {
                    statsQuery = @"
                        SELECT 
                            (SELECT COUNT(1) FROM Groups WHERE MentorId = @UserId) AS GroupsCount,
                            (SELECT COUNT(1) FROM Projects WHERE GroupId IN (SELECT GroupId FROM Groups WHERE MentorId = @UserId)) AS ProjectsCount";
                }
                else
                {
                    // Student
                    statsQuery = @"
                        SELECT 
                            (SELECT COUNT(DISTINCT GroupId) FROM (SELECT GroupId FROM Groups WHERE LeaderId = @UserId UNION SELECT GroupId FROM GroupMembers WHERE UserId = @UserId) AS UserGroups) AS GroupsCount,
                            (SELECT COUNT(1) FROM Projects WHERE GroupId IN (SELECT GroupId FROM Groups WHERE LeaderId = @UserId UNION SELECT GroupId FROM GroupMembers WHERE UserId = @UserId)) AS ProjectsCount";
                }

                using (SqlCommand cmd = new SqlCommand(statsQuery, conn))
                {
                    if (conn.State == ConnectionState.Closed) conn.Open();
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    try
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblGroupsCount.Text = reader["GroupsCount"].ToString();
                                lblProjectsCount.Text = reader["ProjectsCount"].ToString();
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

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string newFullName = txtFullName.Text.Trim();
            string newEmail = txtEmail.Text.Trim();
            string newPass = txtNewPassword.Text;
            string confPass = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(newFullName) || string.IsNullOrEmpty(newEmail))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Name and Email cannot be empty.');", true);
                return;
            }

            if (!string.IsNullOrEmpty(newPass) && newPass != confPass)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Passwords do not match.');", true);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string updateQuery = "UPDATE Users SET FullName = @FullName, Email = @Email";
                if (!string.IsNullOrEmpty(newPass))
                {
                    updateQuery += ", PasswordHash = @PasswordHash";
                }
                updateQuery += " WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@FullName", newFullName);
                    cmd.Parameters.AddWithValue("@Email", newEmail);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    
                    if (!string.IsNullOrEmpty(newPass))
                    {
                        cmd.Parameters.AddWithValue("@PasswordHash", HashPassword(newPass));
                    }

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        
                        // Update Session so topbar updates on next refresh
                        Session["FullName"] = newFullName;
                        Session["Email"] = newEmail;

                        lblDisplayName.Text = newFullName;
                        
                        // Update Initials
                        string initials = "U";
                        string[] parts = newFullName.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        if (parts.Length == 1) initials = parts[0].Substring(0, 1).ToUpper();
                        else if (parts.Length > 1) initials = (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
                        avatarInitials.InnerText = initials;
                        
                        txtNewPassword.Text = string.Empty;
                        txtConfirmPassword.Text = string.Empty;

                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Profile updated successfully!');", true);
                    }
                    catch (SqlException ex) when (ex.Number == 2601 || ex.Number == 2627)
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Email already exists in the system.');", true);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Error updating profile.');", true);
                    }
                }
            }
        }

        // PBKDF2 Password Hashing
        private static string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }
            using (var deriveBytes = new Rfc2898DeriveBytes(password, salt, 100000))
            {
                byte[] hash = deriveBytes.GetBytes(32);
                return $"QKDF2$100000${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";
            }
        }
    }
}