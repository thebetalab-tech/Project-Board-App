using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using MailKit.Net.Smtp;
using MimeKit;

namespace Project_Board
{
    public partial class SignUp : Page
    {
        // Gmail credentials for sending verification emails (same as forget_password)
        private const string SMTP_EMAIL = "thebetalab.net@gmail.com";
        private const string SMTP_APP_PASSWORD = "sfma_pkyj_nitw_bnvn";
        private const string SMTP_DISPLAY_NAME = "Project Board";

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // Step 1: Validate form and send verification code
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

            // --- 3. Check if user already exists ---
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
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"Database error: {ex.Message}", false);
                return;
            }

            // --- 4. Generate verification code and send email ---
            string code = GenerateRandomCode();

            // Store form data and code in session for Step 2
            Session["SignupFullName"] = fullNameValue;
            Session["SignupEmail"] = emailValue;
            Session["SignupEnrollment"] = enrollmentNoValue;
            Session["SignupPasswordHash"] = HashPassword(passwordValue);
            Session["SignupVerifyCode"] = code;

            try
            {
                SendVerificationEmail(emailValue, fullNameValue, code);
                ShowMessage("A 6-digit verification code has been sent to your email.", true);
            }
            catch (Exception mailEx)
            {
                System.Diagnostics.Debug.WriteLine("Mail sending failed: " + mailEx.Message);
                ShowMessage("Failed to send verification email: " + mailEx.Message, false);
                return;
            }

            // Switch to verification code panel
            litVerifyEmail.Text = MaskEmail(emailValue);
            pnlSignupForm.Visible = false;
            pnlVerifyCode.Visible = true;
        }

        // Step 2: Verify code and create account
        protected void btnVerifyAndRegister_Click(object sender, EventArgs e)
        {
            lblMessage.Text = string.Empty;
            lblMessage.CssClass = "form-message";

            string enteredCode = txtVerifyCode.Text.Trim();

            if (string.IsNullOrEmpty(enteredCode))
            {
                ShowMessage("Please enter the verification code.", false);
                return;
            }

            // Verify the code
            string expectedCode = Session["SignupVerifyCode"]?.ToString();
            if (string.IsNullOrEmpty(expectedCode) || enteredCode != expectedCode)
            {
                ShowMessage("Invalid verification code. Please check the code sent to your email.", false);
                return;
            }

            // Retrieve stored signup data
            string fullNameValue = Session["SignupFullName"]?.ToString();
            string emailValue = Session["SignupEmail"]?.ToString();
            string enrollmentNoValue = Session["SignupEnrollment"]?.ToString();
            string passwordHash = Session["SignupPasswordHash"]?.ToString();

            if (string.IsNullOrEmpty(fullNameValue) || string.IsNullOrEmpty(emailValue) || string.IsNullOrEmpty(passwordHash))
            {
                ShowMessage("Session expired. Please fill in the signup form again.", false);
                pnlSignupForm.Visible = true;
                pnlVerifyCode.Visible = false;
                return;
            }

            // --- Insert into database ---
            string connectionString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    // Double-check user doesn't exist (race condition guard)
                    if (UserExists(connection, emailValue))
                    {
                        ShowMessage("An account with this email already exists.", false);
                        ClearSignupSession();
                        return;
                    }

                    string query = @"INSERT INTO Users (FullName, Email, PasswordHash, EnrollmentNo, Role, IsLeader, IsActive, CreatedAt) 
                                     VALUES (@FullName, @Email, @PasswordHash, @EnrollmentNo, @Role, @IsLeader, 1, GETDATE())";
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.CommandType = CommandType.Text;
                        
                        command.Parameters.Add("@FullName", SqlDbType.NVarChar, 100).Value = fullNameValue;
                        command.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = emailValue;
                        command.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 256).Value = passwordHash;
                        command.Parameters.Add("@EnrollmentNo", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(enrollmentNoValue) ? (object)DBNull.Value : enrollmentNoValue;
                        command.Parameters.Add("@Role", SqlDbType.NVarChar, 10).Value = "Student";
                        command.Parameters.Add("@IsLeader", SqlDbType.Bit).Value = false;

                        command.ExecuteNonQuery();
                    }

                    // Fetch the new user's ID
                    using (SqlCommand idCommand = new SqlCommand("SELECT UserId FROM Users WHERE Email = @Email", connection))
                    {
                        idCommand.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = emailValue;
                        object userIdObj = idCommand.ExecuteScalar();
                        if (userIdObj != null)
                        {
                            Session["UserId"] = userIdObj.ToString();
                        }
                    }
                    connection.Close();
                }

                // Clear signup session data
                ClearSignupSession();

                ShowMessage("Account created successfully. You can log in now.", true);

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

        // Back button: return to signup form
        protected void btnBackToSignup_Click(object sender, EventArgs e)
        {
            lblMessage.Text = string.Empty;
            lblMessage.CssClass = "form-message";
            pnlSignupForm.Visible = true;
            pnlVerifyCode.Visible = false;
        }

        // --- Helper Methods ---

        /// <summary>
        /// Generates a cryptographically secure random 6-digit code.
        /// </summary>
        private static string GenerateRandomCode()
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] bytes = new byte[4];
                rng.GetBytes(bytes);
                int value = Math.Abs(BitConverter.ToInt32(bytes, 0)) % 900000 + 100000;
                return value.ToString();
            }
        }

        /// <summary>
        /// Sends a verification email using MailKit via Gmail SMTP.
        /// </summary>
        private static void SendVerificationEmail(string recipientEmail, string recipientName, string code)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(SMTP_DISPLAY_NAME, SMTP_EMAIL));
            message.To.Add(new MailboxAddress(recipientName, recipientEmail));
            message.Subject = "Verify Your Email - Project Board";

            var bodyBuilder = new BodyBuilder();
            bodyBuilder.HtmlBody = $@"
                <div style='font-family: Inter, Arial, sans-serif; max-width: 520px; margin: 0 auto; padding: 32px; background: #f9fafb; border-radius: 12px;'>
                    <div style='text-align: center; margin-bottom: 24px;'>
                        <h2 style='color: #1a1a2e; font-size: 22px; margin: 0 0 8px;'>Email Verification</h2>
                        <p style='color: #6b7280; font-size: 14px; margin: 0;'>Hello {System.Net.WebUtility.HtmlEncode(recipientName)},</p>
                    </div>
                    <div style='background: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 28px; text-align: center;'>
                        <p style='color: #374151; font-size: 14px; margin: 0 0 16px;'>Your 6-digit verification code is:</p>
                        <div style='background: linear-gradient(135deg, #4f46e5, #6366f1); color: #ffffff; font-size: 32px; font-weight: 700; letter-spacing: 0.4em; padding: 16px 24px; border-radius: 8px; display: inline-block;'>{code}</div>
                        <p style='color: #9ca3af; font-size: 12px; margin: 20px 0 0;'>This code will expire when you close the page.</p>
                    </div>
                    <p style='color: #9ca3af; font-size: 12px; text-align: center; margin: 20px 0 0;'>If you did not request this, please ignore this email.</p>
                    <p style='color: #9ca3af; font-size: 12px; text-align: center; margin: 8px 0 0;'>— Project Board Team</p>
                </div>";
            bodyBuilder.TextBody = $"Hello {recipientName},\n\nYour 6-digit email verification code is: {code}\n\nIf you did not request this, please ignore this email.\n\nThank you,\nProject Board Team";

            message.Body = bodyBuilder.ToMessageBody();

            using (var client = new SmtpClient())
            {
                client.Connect("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
                client.Authenticate(SMTP_EMAIL, SMTP_APP_PASSWORD.Replace("_", "").Replace(" ", ""));
                client.Send(message);
                client.Disconnect(true);
            }
        }

        /// <summary>
        /// Masks an email for display (e.g. ru***@gmail.com)
        /// </summary>
        private static string MaskEmail(string email)
        {
            if (string.IsNullOrEmpty(email) || !email.Contains("@"))
                return email;

            string[] parts = email.Split('@');
            string name = parts[0];
            string domain = parts[1];

            if (name.Length <= 2)
                return name + "***@" + domain;

            return name.Substring(0, 2) + new string('*', Math.Min(name.Length - 2, 5)) + "@" + domain;
        }

        private void ClearSignupSession()
        {
            Session.Remove("SignupFullName");
            Session.Remove("SignupEmail");
            Session.Remove("SignupEnrollment");
            Session.Remove("SignupPasswordHash");
            Session.Remove("SignupVerifyCode");
        }

        private static bool IsValidEmail(string email)
        {
            try
            {
                var mailAddress = new System.Net.Mail.MailAddress(email);
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