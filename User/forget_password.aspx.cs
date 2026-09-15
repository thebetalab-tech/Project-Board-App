using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web.UI;
using MailKit.Net.Smtp;
using MimeKit;

namespace Project_Board.User
{
    public partial class forget_password : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        // Gmail credentials for sending verification emails
        private static string SMTP_EMAIL => ConfigurationManager.AppSettings["SmtpEmail"];
        private static string SMTP_APP_PASSWORD => ConfigurationManager.AppSettings["SmtpPassword"];
        private const string SMTP_DISPLAY_NAME = "Project Board";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Visible = false;

                // Check if the user is already logged in
                if (Session["UserId"] != null)
                {
                    // Logged-in user: Skip email & code steps, go directly to password change
                    ShowPasswordStep(isLoggedIn: true);
                }
                else
                {
                    // Not logged in: Start from email step
                    ShowEmailStep();
                }
            }
        }

        // ===== STEP 1: Send Code to Email =====
        protected void btnSendCode_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            lblMessage.Text = string.Empty;

            // Start every code request from a clean slate. Without this, a code (and the
            // "already verified" flag) from a previous attempt would stay in Session and
            // could be replayed against a different email entered afterwards.
            ClearResetSession();

            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                ShowError("Email address is required.");
                return;
            }

            if (string.IsNullOrEmpty(connString))
            {
                ShowError("Database connection is not configured.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    string selectQuery = "SELECT UserId, FullName, Email, Role, IsLeader FROM Users WHERE Email = @Email AND IsActive = 1";
                    int userId = -1;
                    string fullName = string.Empty;
                    string role = string.Empty;
                    bool isLeader = false;
                    bool userFound = false;

                    using (SqlCommand cmd = new SqlCommand(selectQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                userId = Convert.ToInt32(reader["UserId"]);
                                fullName = reader["FullName"]?.ToString() ?? string.Empty;
                                role = reader["Role"]?.ToString() ?? string.Empty;
                                isLeader = reader["IsLeader"] != DBNull.Value && Convert.ToBoolean(reader["IsLeader"]);
                                userFound = true;
                            }
                        }
                    }

                    // Always show the same response whether or not the account exists, so the
                    // form cannot be used to enumerate registered email addresses.
                    const string genericMessage = "If an account with that email address exists, a 6-digit verification code has been sent to it.";

                    if (!userFound)
                    {
                        // Advance to the same code-entry step as a real account so the UI
                        // gives no observable signal about whether the email is registered.
                        ShowSuccess(genericMessage);
                        ShowCodeStep(email);
                        return;
                    }

                    // Store user details in temporary Session variables
                    Session["ResetUserId"] = userId.ToString();
                    Session["ResetUserEmail"] = email;
                    Session["ResetUserFullName"] = fullName;
                    Session["ResetUserRole"] = role;
                    Session["ResetUserIsLeader"] = isLeader.ToString();

                    // Generate a random 6-digit verification code
                    string code = Project_Board.Utils.AuthHelper.GenerateRandomCode();
                    Session["ResetCode"] = code;

                    // Send the verification code via MailKit
                    try
                    {
                        SendVerificationEmail(email, fullName, code);
                        ShowSuccess(genericMessage);
                    }
                    catch (Exception mailEx)
                    {
                        System.Diagnostics.Trace.TraceError("[ForgotPassword] Mail sending failed: " + mailEx);
                        ShowError("Failed to send verification email. Please try again.");
                        return;
                    }

                    // Move to Step 2 (Code Verification)
                    ShowCodeStep(email);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("[ForgotPassword] " + ex);
                ShowError("An error occurred. Please try again.");
            }
        }

        // ===== STEP 2: Verify the Code =====
        protected void btnVerifyCode_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            lblMessage.Text = string.Empty;

            string enteredCode = txtCode.Text.Trim();

            if (string.IsNullOrEmpty(enteredCode))
            {
                ShowError("Please enter the verification code.");
                return;
            }

            // Verify Code
            string expectedCode = Session["ResetCode"]?.ToString();
            if (string.IsNullOrEmpty(expectedCode) || enteredCode != expectedCode)
            {
                ShowError("Invalid verification code. Please check the code sent to your email.");
                return;
            }

            // Code is correct — mark as verified and move to Step 3 (Password)
            Session["ResetCodeVerified"] = "true";
            ShowPasswordStep(isLoggedIn: false);
            ShowSuccess("Code verified successfully! Now set your new password.");
        }

        // ===== STEP 3: Reset Password =====
        protected void btnReset_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            lblMessage.Text = string.Empty;

            string newPassword = txtNewPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword))
            {
                ShowError("Both password fields are required.");
                return;
            }

            // Validate Passwords
            if (newPassword.Length < 8)
            {
                ShowError("Password must be at least 8 characters long.");
                return;
            }

            if (newPassword != confirmPassword)
            {
                ShowError("Passwords do not match.");
                return;
            }

            bool isLoggedIn = (Session["UserId"] != null);

            // Determine the UserId to update
            string userIdStr;
            if (isLoggedIn)
            {
                userIdStr = Session["UserId"]?.ToString();
            }
            else
            {
                // Non-logged-in user: must have completed code verification
                string codeVerified = Session["ResetCodeVerified"]?.ToString();
                if (string.IsNullOrEmpty(codeVerified) || codeVerified != "true")
                {
                    ShowError("Session expired. Please restart the forgot password process.");
                    ShowEmailStep();
                    return;
                }
                userIdStr = Session["ResetUserId"]?.ToString();
            }

            if (string.IsNullOrEmpty(userIdStr))
            {
                ShowError("Session expired. Please restart the forgot password process.");
                ShowEmailStep();
                return;
            }

            if (!int.TryParse(userIdStr, out int userId))
            {
                ShowError("Session expired. Please restart the forgot password process.");
                ShowEmailStep();
                return;
            }

            // Update Password in the Database
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    string passwordHash = Project_Board.Utils.AuthHelper.HashPassword(newPassword);
                    string updateQuery = "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserId = @UserId";

                    using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                    {
                        updateCmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        updateCmd.Parameters.AddWithValue("@UserId", userId);
                        updateCmd.ExecuteNonQuery();
                    }

                    if (isLoggedIn)
                    {
                        // Already logged in — just redirect to appropriate dashboard
                        ClearResetSession();
                        RedirectToDashboard();
                    }
                    else
                    {
                        // Not logged in — set up session from reset data and redirect
                        Session["UserId"] = Session["ResetUserId"];
                        Session["FullName"] = Session["ResetUserFullName"];
                        Session["Role"] = Session["ResetUserRole"];
                        Session["Email"] = Session["ResetUserEmail"];
                        Session["IsLeader"] = Session["ResetUserIsLeader"];

                        ClearResetSession();
                        RedirectToDashboard();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("[ForgotPassword] Password update failed: " + ex);
                ShowError("An error occurred while updating your password. Please try again.");
            }
        }

        // ===== Navigation Buttons =====
        protected void btnBackToEmail_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            // Starting over must also drop any code/verified flag from the abandoned attempt.
            ClearResetSession();
            ShowEmailStep();
        }

        protected void btnBackFromPassword_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            if (Session["UserId"] != null)
            {
                // Logged-in user cancels — redirect back to their dashboard
                RedirectToDashboard();
            }
            else
            {
                // Non-logged-in user — go back to email step
                ShowEmailStep();
            }
        }

        // ===== Step Visibility Helpers =====
        private void ShowEmailStep()
        {
            pnlEmailStep.Visible = true;
            pnlCodeStep.Visible = false;
            pnlPasswordStep.Visible = false;
            pnlProgress.Visible = true;

            litTitle.Text = "Reset Password";
            litSubtitle.Text = "Identify your account and verify with email code";

            dot1.Attributes["class"] = "dot active";
            dot2.Attributes["class"] = "dot";
            dot3.Attributes["class"] = "dot";
        }

        private void ShowCodeStep(string email)
        {
            pnlEmailStep.Visible = false;
            pnlCodeStep.Visible = true;
            pnlPasswordStep.Visible = false;
            pnlProgress.Visible = true;

            litTitle.Text = "Verify Your Email";
            litSubtitle.Text = "Enter the verification code to continue";
            litEmailDisplay.Text = MaskEmail(email);

            dot1.Attributes["class"] = "dot completed";
            dot2.Attributes["class"] = "dot active";
            dot3.Attributes["class"] = "dot";
        }

        private void ShowPasswordStep(bool isLoggedIn)
        {
            pnlEmailStep.Visible = false;
            pnlCodeStep.Visible = false;
            pnlPasswordStep.Visible = true;

            if (isLoggedIn)
            {
                litTitle.Text = "Change Password";
                litSubtitle.Text = "Set a new password for your account";
                litPasswordStepInfo.Text = "Enter and confirm your new password below.";
                litBackText.Text = "Cancel";
                pnlProgress.Visible = false; // No progress dots for logged-in users
            }
            else
            {
                litTitle.Text = "Set New Password";
                litSubtitle.Text = "Create a strong password for your account";
                litPasswordStepInfo.Text = "Email verified! Now set your new password.";
                litBackText.Text = "Start Over";
                pnlProgress.Visible = true;

                dot1.Attributes["class"] = "dot completed";
                dot2.Attributes["class"] = "dot completed";
                dot3.Attributes["class"] = "dot active";
            }
        }

        // ===== Redirect Helper =====
        private void RedirectToDashboard()
        {
            string role = Session["Role"]?.ToString() ?? string.Empty;
            string isLeaderStr = Session["IsLeader"]?.ToString() ?? string.Empty;

            if (string.Equals(role, "Student", StringComparison.OrdinalIgnoreCase))
            {
                if (string.Equals(isLeaderStr, "True", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/Student/Leader/Dashboard.aspx", false);
                }
                else
                {
                    Response.Redirect("~/Student/Member/Dashboard.aspx", false);
                }
            }
            else if (string.Equals(role, "Faculty", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Faculty/Dashboard.aspx", false);
            }
            else if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Admin/Admin_Dashboard.aspx", false);
            }
            else
            {
                Response.Redirect("~/Default.aspx", false);
            }

            Context.ApplicationInstance.CompleteRequest();
        }

        // ===== Session Cleanup =====
        private void ClearResetSession()
        {
            Session.Remove("ResetUserId");
            Session.Remove("ResetUserEmail");
            Session.Remove("ResetUserFullName");
            Session.Remove("ResetUserRole");
            Session.Remove("ResetUserIsLeader");
            Session.Remove("ResetCode");
            Session.Remove("ResetCodeVerified");
        }

        // ===== Helper: Mask email for display =====
        private string MaskEmail(string email)
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

        // --- Helper Methods ---

        /// <summary>
        /// Sends a verification email using MailKit via Gmail SMTP.
        /// </summary>
        private static void SendVerificationEmail(string recipientEmail, string recipientName, string code)
        {
            // Fail closed (and with a clear reason) when SMTP credentials are not configured
            // in Web.config, instead of throwing a NullReferenceException at Authenticate().
            if (string.IsNullOrWhiteSpace(SMTP_EMAIL) || string.IsNullOrWhiteSpace(SMTP_APP_PASSWORD))
            {
                throw new InvalidOperationException(
                    "SmtpEmail/SmtpPassword are not configured in Web.config — cannot send the verification email.");
            }

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(SMTP_DISPLAY_NAME, SMTP_EMAIL));
            message.To.Add(new MailboxAddress(recipientName, recipientEmail));
            message.Subject = "Reset Your Password - Verification Code";

            var bodyBuilder = new BodyBuilder();
            bodyBuilder.HtmlBody = $@"
                <div style='font-family: Inter, Arial, sans-serif; max-width: 520px; margin: 0 auto; padding: 32px; background: #f9fafb; border-radius: 12px;'>
                    <div style='text-align: center; margin-bottom: 24px;'>
                        <h2 style='color: #1a1a2e; font-size: 22px; margin: 0 0 8px;'>Password Reset</h2>
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
            bodyBuilder.TextBody = $"Hello {recipientName},\n\nYour 6-digit password reset verification code is: {code}\n\nIf you did not request this, please ignore this email.\n\nThank you,\nProject Board Team";

            message.Body = bodyBuilder.ToMessageBody();

            using (var client = new MailKit.Net.Smtp.SmtpClient())
            {
                client.Connect("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
                client.Authenticate(SMTP_EMAIL, SMTP_APP_PASSWORD.Replace("_", "").Replace(" ", ""));
                client.Send(message);
                client.Disconnect(true);
            }
        }

        private void ShowError(string message)
        {
            lblMessage.Visible = true;
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = "form-message form-message--error";
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Visible = true;
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = "form-message form-message--success";
        }
    }
}