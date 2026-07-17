using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Web.UI;

namespace Project_Board.User
{
    public partial class forget_password : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Visible = false;
                pnlEmailStep.Visible = true;
                pnlVerificationStep.Visible = false;
            }
        }

        protected void btnSendCode_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            lblMessage.Text = string.Empty;

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
                                isLeader = Convert.ToBoolean(reader["IsLeader"]);
                                userFound = true;
                            }
                        }
                    }

                    if (!userFound)
                    {
                        ShowError("No active account found with that email address.");
                        return;
                    }

                    // Store user details in temporary Session variables
                    Session["ResetUserId"] = userId.ToString();
                    Session["ResetUserEmail"] = email;
                    Session["ResetUserFullName"] = fullName;
                    Session["ResetUserRole"] = role;
                    Session["ResetUserIsLeader"] = isLeader.ToString();

                    // Generate a 6-digit random code
                    Random rand = new Random();
                    string code = rand.Next(100000, 999999).ToString();
                    Session["ResetCode"] = code;

                    // Send the email with the code
                    try
                    {
                        using (MailMessage mail = new MailMessage())
                        {
                            mail.From = new MailAddress("projectboard.noreply@gmail.com", "Project Board");
                            mail.To.Add(email);
                            mail.Subject = "Reset Your Password - Verification Code";
                            mail.Body = $"Hello {fullName},\n\nYour 6-digit password reset verification code is: {code}\n\nIf you did not request this, please ignore this email.\n\nThank you,\nProject Board Team";

                            using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
                            {
                                smtp.Credentials = new System.Net.NetworkCredential("projectboard.noreply@gmail.com", "dummy_password");
                                smtp.EnableSsl = true;
                                smtp.Send(mail);
                            }
                        }
                        ShowSuccess("A 6-digit verification code has been sent to your email address.");
                    }
                    catch (Exception mailEx)
                    {
                        // Fallback in case local development environment has no internet or SMTP setup
                        System.Diagnostics.Debug.WriteLine("Mail sending failed: " + mailEx.Message);
                        ShowSuccess($"Verification code generated! (Testing Bypass: Code is {code})");
                    }

                    // Move to Step 2
                    pnlEmailStep.Visible = false;
                    pnlVerificationStep.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowError("An error occurred: " + ex.Message);
                System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            lblMessage.Text = string.Empty;

            string enteredCode = txtCode.Text.Trim();
            string newPassword = txtNewPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(enteredCode) || string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword))
            {
                ShowError("All fields are required.");
                return;
            }

            // Verify Code
            string expectedCode = Session["ResetCode"]?.ToString();
            if (string.IsNullOrEmpty(expectedCode) || enteredCode != expectedCode)
            {
                ShowError("Invalid verification code. Please check the code sent to your email.");
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

            string userIdStr = Session["ResetUserId"]?.ToString();
            if (string.IsNullOrEmpty(userIdStr))
            {
                ShowError("Session expired. Please restart the forgot password process.");
                pnlEmailStep.Visible = true;
                pnlVerificationStep.Visible = false;
                return;
            }

            int userId = Convert.ToInt32(userIdStr);

            // Reset Password & Log In User
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    string passwordHash = HashPassword(newPassword);
                    string updateQuery = "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserId = @UserId";

                    using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                    {
                        updateCmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        updateCmd.Parameters.AddWithValue("@UserId", userId);
                        updateCmd.ExecuteNonQuery();
                    }

                    // SUCCESS: Initialize User Session details (Auto Log In)
                    Session["UserId"] = Session["ResetUserId"];
                    Session["FullName"] = Session["ResetUserFullName"];
                    Session["Role"] = Session["ResetUserRole"];
                    Session["Email"] = Session["ResetUserEmail"];
                    Session["IsLeader"] = Session["ResetUserIsLeader"];

                    // Clear reset session variables
                    Session.Remove("ResetUserId");
                    Session.Remove("ResetUserEmail");
                    Session.Remove("ResetUserFullName");
                    Session.Remove("ResetUserRole");
                    Session.Remove("ResetUserIsLeader");
                    Session.Remove("ResetCode");

                    // Redirect based on role and leader status
                    string role = Session["Role"]?.ToString() ?? string.Empty;
                    string isLeaderStr = Session["IsLeader"]?.ToString() ?? string.Empty;

                    if (string.Equals(role, "Student", StringComparison.OrdinalIgnoreCase))
                    {
                        if (string.Equals(isLeaderStr, "True", StringComparison.OrdinalIgnoreCase))
                        {
                            Response.Redirect("~/Student/Leader/Leader_Members.aspx", false);
                        }
                        else
                        {
                            Response.Redirect("~/Student/Member/Member_Team.aspx", false);
                        }
                    }
                    else if (string.Equals(role, "Faculty", StringComparison.OrdinalIgnoreCase))
                    {
                        Response.Redirect("~/Faculty/Faculty_Dashboard.aspx", false);
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
            }
            catch (Exception ex)
            {
                ShowError("An error occurred during password update: " + ex.Message);
                System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        protected void btnBackToEmail_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            pnlEmailStep.Visible = true;
            pnlVerificationStep.Visible = false;
        }

        // --- Helper Methods ---

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