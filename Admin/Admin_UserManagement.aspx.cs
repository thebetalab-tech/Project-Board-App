using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_UserManagement : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Fetch user information from session
                string userName = Session["FullName"]?.ToString() ?? "Guest";
                string userEmail = Session["Email"]?.ToString() ?? "No email provided";
                userNameLabel.Text = userName;
                userEmailLabel.Text = userEmail;

                LoadUsers();
            }
        }

        private void LoadUsers()
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Using the Selection Stored Procedure
                using (SqlCommand cmd = new SqlCommand("sp_select_users", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "ALL");

                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            rptUsers.DataSource = reader;
                            rptUsers.DataBind();
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
            }
        }

        protected void btnAddUser_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string enrollment = txtEnrollment.Text.Trim();
            string role = ddlRole.SelectedValue;
            
            // Grabbing the password from the new frontend field
            string password = txtPassword.Text;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "Name, Email, and Password are required.";
                lblMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ff4d4d"); // Red
                return;
            }

            string passwordHash = HashPassword(password);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    // Using the CRUD Stored Procedure
                    using (SqlCommand insertCmd = new SqlCommand("sp_crud_users", conn))
                    {
                        insertCmd.CommandType = CommandType.StoredProcedure;
                        
                        insertCmd.Parameters.AddWithValue("@Action", "INSERT");
                        insertCmd.Parameters.AddWithValue("@FullName", fullName);
                        insertCmd.Parameters.AddWithValue("@Email", email);
                        insertCmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        insertCmd.Parameters.AddWithValue("@EnrollmentNo", string.IsNullOrEmpty(enrollment) ? (object)DBNull.Value : enrollment);
                        insertCmd.Parameters.AddWithValue("@Role", role);
                        insertCmd.Parameters.AddWithValue("@IsLeader", false); // Default to false for new users

                        conn.Open();
                        insertCmd.ExecuteNonQuery();
                        
                        // Reset form and reload data
                        txtFullName.Text = string.Empty;
                        txtEmail.Text = string.Empty;
                        txtPassword.Text = string.Empty; // Clear password field
                        txtEnrollment.Text = string.Empty;
                        ddlRole.SelectedIndex = 0;
                        
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "User added successfully.";
                        
                        LoadUsers();
                    }
                }
                catch (SqlException ex) when (ex.Number == 2601 || ex.Number == 2627)
                {
                    // This catches the UNIQUE constraint violation from SQL Server if the email exists
                    lblMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ff4d4d");
                    lblMessage.Text = "A user with this email already exists.";
                }
                catch (Exception ex)
                {
                    lblMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ff4d4d");
                    lblMessage.Text = "Error: " + ex.Message;
                }
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteUser")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Using the CRUD Stored Procedure for the Soft Delete
                    using (SqlCommand cmd = new SqlCommand("sp_crud_users", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "DELETE");
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            LoadUsers();
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine("Error deleting user: " + ex.Message);
                        }
                    }
                }
            }
        }

        // Helper method to get initials for the avatar
        protected string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "U";
            string[] parts = name.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }

        // Helper method to get avatar style based on role
        protected string GetAvatarStyle(string role)
        {
            if (role == "Faculty")
                return "background:var(--c-blue-bg);color:var(--c-blue);";
            if (role == "Admin")
                return "background:var(--c-accent-bg);color:var(--c-accent);";
            return ""; // Default styling for student
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