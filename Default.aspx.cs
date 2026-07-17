using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace Project_Board
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional: If a user is already logged in, redirect them away from the login page
            if (Session["UserId"] != null)
            {
                RedirectUserBasedOnRole(Session["Role"].ToString());
            }
        }

        protected void loginBtn_Click(object sender, EventArgs e)
        {
            // Using direct control access instead of Request.Form because MasterPages alter the name attribute
            string loginId = txtLoginID.Text.Trim();
            string password = txtPassword.Text;

            // Fallback to searching Request.Form explicitly
            if (string.IsNullOrEmpty(loginId) || string.IsNullOrEmpty(password))
            {
                foreach (string key in Request.Form.AllKeys)
                {
                    if (!string.IsNullOrEmpty(key))
                    {
                        if (string.IsNullOrEmpty(loginId) && key.EndsWith("txtLoginID", StringComparison.OrdinalIgnoreCase))
                            loginId = Request.Form[key];
                        if (string.IsNullOrEmpty(password) && key.EndsWith("txtPassword", StringComparison.OrdinalIgnoreCase))
                            password = Request.Form[key];
                    }
                }
            }

            loginId = loginId?.Trim();

            // Basic Validation
            if (string.IsNullOrEmpty(loginId) || string.IsNullOrEmpty(password))
            {
                string keys = string.Join(", ", Request.Form.AllKeys);
                lblError.Text = "Please enter both login ID and password. (Debug Keys: " + keys + ")";
                return;
            }

            // We cannot use sp_LoginUser directly with a hashed parameter because SignUp uses PBKDF2 with random salts.
            // We must retrieve the stored hash from the database and verify it in C#.
            string connectionString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
                ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    // The query looks up the user by Email or EnrollmentNo
                    string query = @"SELECT UserId, FullName, Email, PasswordHash, Role, IsLeader 
                                     FROM Users 
                                     WHERE Email = @LoginId OR EnrollmentNo = @LoginId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@LoginId", loginId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                reader.Read();
                                string storedHash = reader["PasswordHash"].ToString();

                                if (VerifyPassword(password, storedHash))
                                {
                                    // SUCCESS: Store user data in Session variables
                                    Session["UserId"] = reader["UserId"].ToString();
                                    Session["FullName"] = reader["FullName"].ToString();
                                    Session["Role"] = reader["Role"].ToString();
                                    Session["Email"] = reader["Email"].ToString();
                                    Session["IsLeader"] = reader["IsLeader"].ToString();

                                    // Redirect to the appropriate dashboard
                                    RedirectUserBasedOnRole(Session["Role"].ToString());
                                }
                                else
                                {
                                    lblError.Text = "Invalid credentials. Please check your password.";
                                }
                            }
                            else
                            {
                                // FAILED: Invalid credentials or inactive account
                                lblError.Text = "Invalid credentials or account is inactive.";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log the exception in a real app. For now, display a generic error.
                lblError.Text = "An error occurred during login. Please try again later.";
                System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        // Helper Method: Redirects the user based on their role
        private void RedirectUserBasedOnRole(string role)
        {
            if (role == "Student")
            {
                if(Session["IsLeader"] != null && Session["IsLeader"].ToString() == "True")
                {
                    Response.Redirect("Student/Leader/Dashboard.aspx", false);           
                }
                else
                {
                    Response.Redirect("Student/Member/Dashboard.aspx", false);
                }
            }
            else if (role == "Faculty")
            {
                Response.Redirect("Faculty/Faculty_Dashboard.aspx", false);
            }
            else if (role == "Admin")
            {
                Response.Redirect("Admin/Admin_Dashboard.aspx", false);
            }
        }

        // Helper Method: Verifies a password against a PBKDF2 hash
        private bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrEmpty(storedHash)) return false;

            // Handle the PBKDF2 hash format used in SignUp.aspx.cs: QKDF2$100000$salt$hash
            if (storedHash.StartsWith("QKDF2$"))
            {
                string[] parts = storedHash.Split('$');
                if (parts.Length != 4) return false;

                int iterations = int.Parse(parts[1]);
                byte[] salt = Convert.FromBase64String(parts[2]);
                byte[] hash = Convert.FromBase64String(parts[3]);

                using (var deriveBytes = new Rfc2898DeriveBytes(password, salt, iterations))
                {
                    byte[] testHash = deriveBytes.GetBytes(32);
                    for (int i = 0; i < 32; i++)
                    {
                        if (hash[i] != testHash[i]) return false;
                    }
                    return true;
                }
            }
            else
            {
                // Fallback for old SHA256 hashes if any exist in the DB
                using (SHA256 sha256Hash = SHA256.Create())
                {
                    byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(password));
                    StringBuilder builder = new StringBuilder();
                    for (int i = 0; i < bytes.Length; i++)
                    {
                        builder.Append(bytes[i].ToString("x2"));
                    }
                    return builder.ToString() == storedHash;
                }
            }
        }
    }
}