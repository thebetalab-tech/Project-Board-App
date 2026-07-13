using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;

namespace Project_Board
{
    public partial class SignUp : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void loginBtn_Click(object sender, EventArgs e)
        {
            // Reset message label state
            lblMessage.Text = string.Empty;
            lblMessage.CssClass = "form-message";

            // Grab input values
            string fullNameValue = fullName.Text.Trim();
            string emailValue = loginId.Text.Trim();
            string enrollmentNoValue = enrollment.Text.Trim();
            string passwordValue = password.Text;
            string confirmPasswordValue = confirmPassword.Text;

            // --- 1. Form Validation ---
            if (string.IsNullOrWhiteSpace(fullNameValue) || 
                string.IsNullOrWhiteSpace(emailValue) || 
                string.IsNullOrWhiteSpace(passwordValue) || 
                string.IsNullOrWhiteSpace(confirmPasswordValue))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (fullNameValue.Length > 100)
            {
                ShowMessage("Full name must be 100 characters or fewer.", false);
                return;
            }

            if (emailValue.Length > 100 || !IsValidEmail(emailValue))
            {
                ShowMessage("Enter a valid email address.", false);
                return;
            }

            if (!string.IsNullOrWhiteSpace(enrollmentNoValue) && enrollmentNoValue.Length > 20)
            {
                ShowMessage("Enrollment number must be 20 characters or fewer.", false);
                return;
            }

            if (passwordValue.Length < 8)
            {
                ShowMessage("Password must be at least 8 characters long.", false);
                return;
            }

            if (passwordValue != confirmPasswordValue)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            // --- 2. Database Connection Check ---
            string connectionString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
            if (string.IsNullOrWhiteSpace(connectionString))
            {
                ShowMessage("Database connection is not configured.", false);
                return;
            }

            // --- 3. Database Operations ---
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    if (UserExists(connection, emailValue))
                    {
                        ShowMessage("An account with this email already exists.", false);
                        return;
                    }

                    string passwordHash = HashPassword(passwordValue);

                    using (SqlCommand command = new SqlCommand("sp_crud_users", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        
                        // Using explicit SQL Types is great for performance and avoiding type mismatch errors
                        command.Parameters.Add("@Action", SqlDbType.NVarChar, 20).Value = "INSERT";
                        command.Parameters.Add("@FullName", SqlDbType.NVarChar, 100).Value = fullNameValue;
                        command.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = emailValue;
                        command.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 256).Value = passwordHash;
                        command.Parameters.Add("@EnrollmentNo", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(enrollmentNoValue) ? (object)DBNull.Value : enrollmentNoValue;
                        command.Parameters.Add("@Role", SqlDbType.NVarChar, 10).Value = "Student";
                        command.Parameters.Add("@IsLeader", SqlDbType.Bit).Value = false;

                        command.ExecuteNonQuery();
                    }
                }

                ShowMessage("Account created successfully. You can log in now.", true);

                // Optional: You can save the user's email or name in a Session variable here 
                // so you can welcome them by name on the OnBoarding page!
                Session["UserEmail"] = emailValue;
                Session["EnrollmentNo"] = enrollmentNoValue;
                Session["Role"] = "Student";
                Session["IsLeader"] = false;
                Session["UserFullName"] = fullNameValue;

                // Redirect the user to the Onboarding page
                Response.Redirect("OnBoarding.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (SqlException ex) when (ex.Number == 2601 || ex.Number == 2627)
            {
                ShowMessage($"That email is already in use. SQL error {ex.Number}: {ex.Message}", false);
            }
            catch (SqlException ex)
            {
                ShowMessage($"Database error {ex.Number}: {ex.Message}", false);
            }
            catch (Exception ex)
            {
                ShowMessage($"Signup failed: {ex.Message}", false);
            }
        }

        // --- Helper Methods ---

        private static bool IsValidEmail(string email)
        {
            try
            {
                var mailAddress = new MailAddress(email);
                return string.Equals(mailAddress.Address, email, StringComparison.OrdinalIgnoreCase);
            }
            catch
            {
                return false;
            }
        }

        private static bool UserExists(SqlConnection connection, string email)
        {
            // Removed LOWER() to allow SQL Server to utilize database indexes properly
            using (SqlCommand command = new SqlCommand("SELECT COUNT(1) FROM Users WHERE Email = @Email", connection))
            {
                command.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                return Convert.ToInt32(command.ExecuteScalar()) > 0;
            }
        }

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
                // String interpolation is cleaner than string.Format
                return $"QKDF2$100000${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Visible = true;
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = isSuccess ? "form-message form-message--success" : "form-message form-message--error";

            if (!isSuccess)
            {
                string safeMessage = HttpUtility.JavaScriptStringEncode(message);
                ClientScript.RegisterStartupScript(GetType(), "signup_error", $"alert('{safeMessage}');", true);
            }
        }
    }
}