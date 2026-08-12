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
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Fetch user information from session
                string userName = Session["FullName"]?.ToString() ?? "Guest";
                string userEmail = Session["Email"]?.ToString() ?? "No email provided";
                string intial = userName.Substring(0, 1).ToUpper();
                userNameLabel.Text = userName;
                userEmailLabel.Text = userEmail;
                userintial.Text = intial;

                LoadUsers();
            }
        }

        private void LoadUsers()
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT UserId, FullName, Email, EnrollmentNo, Role, IsLeader FROM Users WHERE IsActive = 1";
                if (filter != "All")
                {
                    query += " AND Role = @Role";
                }
                query += " ORDER BY CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.CommandType = CommandType.Text;
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Role", filter);
                    }

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

        protected void ddlReportFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsers();
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
                ShowModalWithMessage("Name, Email, and Password are required.", true);
                return;
            }

            string passwordHash = HashPassword(password);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // Check if active user exists
                    string checkSql = "SELECT COUNT(1) FROM Users WHERE Email = @Email AND IsActive = 1";
                    using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                        {
                            ShowModalWithMessage("A user with this email already exists.", true);
                            return;
                        }
                    }

                    // Clean up any old soft-deleted user record with the same email
                    string cleanupSql = "DELETE FROM Users WHERE Email = @Email AND IsActive = 0";
                    using (SqlCommand cleanupCmd = new SqlCommand(cleanupSql, conn))
                    {
                        cleanupCmd.Parameters.AddWithValue("@Email", email);
                        cleanupCmd.ExecuteNonQuery();
                    }

                    string query = @"INSERT INTO Users (FullName, Email, PasswordHash, EnrollmentNo, Role, IsLeader, IsActive, CreatedAt) 
                                     VALUES (@FullName, @Email, @PasswordHash, @EnrollmentNo, @Role, @IsLeader, 1, GETDATE())";
                    using (SqlCommand insertCmd = new SqlCommand(query, conn))
                    {
                        insertCmd.CommandType = CommandType.Text;
                        
                        insertCmd.Parameters.AddWithValue("@FullName", fullName);
                        insertCmd.Parameters.AddWithValue("@Email", email);
                        insertCmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        insertCmd.Parameters.AddWithValue("@EnrollmentNo", string.IsNullOrEmpty(enrollment) ? (object)DBNull.Value : enrollment);
                        insertCmd.Parameters.AddWithValue("@Role", role);
                        insertCmd.Parameters.AddWithValue("@IsLeader", 0);

                        insertCmd.ExecuteNonQuery();
                        
                        // Send email notification with login credentials to new user
                        Project_Board.Services.EmailService.SendAdminCreatedUserNotification(
                            email,
                            fullName,
                            role,
                            enrollment,
                            password
                        );

                        // Reset form and reload data
                        txtFullName.Text = string.Empty;
                        txtEmail.Text = string.Empty;
                        txtPassword.Text = string.Empty; // Clear password field
                        txtEnrollment.Text = string.Empty;
                        ddlRole.SelectedIndex = 0;
                        
                        LoadUsers();
                        ShowModalWithMessage("User added successfully.", false);
                    }
                }
                catch (SqlException ex) when (ex.Number == 2601 || ex.Number == 2627)
                {
                    // This catches the UNIQUE constraint violation from SQL Server if the email exists
                    ShowModalWithMessage("A user with this email already exists.", true);
                }
                catch (Exception ex)
                {
                    ShowModalWithMessage("Error: " + ex.Message, true);
                }
            }
        }

        private void ShowModalWithMessage(string message, bool isError)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.ColorTranslator.FromHtml("#ff4d4d") : System.Drawing.Color.Green;
            ClientScript.RegisterStartupScript(this.GetType(), "KeepModalOpen", "<script>window.onload = function() { openModal('userModal'); };</script>");
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteUser")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Fetch target user details before deletion for email notification
                    string targetName = string.Empty;
                    string targetEmail = string.Empty;
                    string targetRole = string.Empty;

                    string getUserSql = "SELECT FullName, Email, Role FROM Users WHERE UserId = @UserId";
                    using (SqlCommand getCmd = new SqlCommand(getUserSql, conn))
                    {
                        getCmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader rdr = getCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                targetName = rdr["FullName"]?.ToString() ?? "User";
                                targetEmail = rdr["Email"]?.ToString() ?? string.Empty;
                                targetRole = rdr["Role"]?.ToString() ?? "User";
                            }
                        }
                    }

                    string deleteCascadeQuery = @"
                        IF OBJECT_ID('Task', 'U') IS NOT NULL
                        BEGIN
                            DELETE FROM Task WHERE ParentTaskId IN (SELECT TaskId FROM Task WHERE AssignedTo = @UserId OR AssignedBy = @UserId);
                            DELETE FROM Task WHERE AssignedTo = @UserId OR AssignedBy = @UserId;
                        END;
                        IF OBJECT_ID('Tasks', 'U') IS NOT NULL
                        BEGIN
                            DELETE FROM Tasks WHERE ParentTaskId IN (SELECT TaskId FROM Tasks WHERE AssignedTo = @UserId OR AssignedBy = @UserId);
                            DELETE FROM Tasks WHERE AssignedTo = @UserId OR AssignedBy = @UserId;
                        END;

                        DELETE FROM GroupMembers WHERE UserId = @UserId;
                        DELETE FROM GroupMentorRejections WHERE FacultyId = @UserId;
                        DELETE FROM Faculty WHERE FacultyId = @UserId;
                        UPDATE Groups SET MentorId = NULL, Status = 'Forming' WHERE MentorId = @UserId;

                        DECLARE @GroupIds TABLE (GroupId INT);
                        INSERT INTO @GroupIds SELECT GroupId FROM Groups WHERE LeaderId = @UserId;

                        IF OBJECT_ID('ProjectKeywords', 'U') IS NOT NULL
                            DELETE FROM ProjectKeywords WHERE ProjectId IN (SELECT ProjectId FROM Projects WHERE GroupId IN (SELECT GroupId FROM @GroupIds));

                        IF OBJECT_ID('Projects', 'U') IS NOT NULL
                            DELETE FROM Projects WHERE GroupId IN (SELECT GroupId FROM @GroupIds);

                        IF OBJECT_ID('Task', 'U') IS NOT NULL
                            DELETE FROM Task WHERE GroupId IN (SELECT GroupId FROM @GroupIds);

                        IF OBJECT_ID('Tasks', 'U') IS NOT NULL
                            DELETE FROM Tasks WHERE GroupId IN (SELECT GroupId FROM @GroupIds);

                        DELETE FROM GroupMentorRejections WHERE GroupId IN (SELECT GroupId FROM @GroupIds);
                        DELETE FROM GroupMembers WHERE GroupId IN (SELECT GroupId FROM @GroupIds);
                        DELETE FROM Groups WHERE LeaderId = @UserId;

                        DELETE FROM Users WHERE UserId = @UserId;";

                    using (SqlCommand cmd = new SqlCommand(deleteCascadeQuery, conn))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        try
                        {
                            cmd.ExecuteNonQuery();

                            // Send email notification to deleted user
                            if (!string.IsNullOrEmpty(targetEmail))
                            {
                                Project_Board.Services.EmailService.SendAccountDeletedNotification(targetEmail, targetName, targetRole);
                            }

                            LoadUsers();
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine("Error deleting user completely: " + ex.Message);
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

        protected void btnExportReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;
            
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        FullName AS [Name],
                        Email AS [Email Address],
                        ISNULL(EnrollmentNo, 'N/A') AS [Enrollment / ID],
                        Role AS [Role],
                        CASE WHEN IsLeader = 1 THEN 'Yes' ELSE 'No' END AS [Group Leader],
                        CreatedAt AS [Joined On]
                    FROM Users
                    WHERE IsActive = 1";

                if (filter != "All")
                {
                    query += " AND Role = @Role";
                }
                
                query += " ORDER BY Role, FullName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Role", filter);
                    }
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        string userName = Session["FullName"]?.ToString() ?? "Admin";
                        string userEmail = Session["Email"]?.ToString() ?? "admin@example.com";
                        
                        Project_Board.Services.ReportService.GeneratePdfReport("System Users Report", dt, userName, userEmail, "Role: " + filter, Response);
                    }
                }
            }
        }
    }
}