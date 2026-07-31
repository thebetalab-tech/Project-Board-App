using System;
using System.Configuration;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace Project_Board.Services
{
    public static class EmailService
    {
        private const string DEFAULT_SMTP_EMAIL = "thebetalab.net@gmail.com";
        private const string DEFAULT_SMTP_PASS = "sfmapkyjnitwbnvn";

        private static string SmtpHost => ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
        private static int SmtpPort => int.TryParse(ConfigurationManager.AppSettings["SmtpPort"], out int p) ? p : 587;
        
        private static string SmtpUsername
        {
            get
            {
                string user = ConfigurationManager.AppSettings["SmtpUsername"];
                return (string.IsNullOrWhiteSpace(user) || user.Contains("your-email")) ? DEFAULT_SMTP_EMAIL : user.Trim();
            }
        }

        private static string SmtpPassword
        {
            get
            {
                string pass = ConfigurationManager.AppSettings["SmtpPassword"];
                if (string.IsNullOrWhiteSpace(pass) || pass.Contains("your-app-password")) return DEFAULT_SMTP_PASS;
                return pass.Replace("_", "").Replace(" ", "").Trim();
            }
        }

        private static string SenderEmail => ConfigurationManager.AppSettings["SenderEmail"] ?? DEFAULT_SMTP_EMAIL;
        private static string SenderName => ConfigurationManager.AppSettings["SenderName"] ?? "Project Board Platform";
        private static bool EmailEnabled => bool.TryParse(ConfigurationManager.AppSettings["EmailNotificationsEnabled"], out bool enabled) ? enabled : true;

        /// <summary>
        /// Sends an email synchronously via MailKit.
        /// </summary>
        public static void SendEmail(string toEmail, string subject, string htmlBody)
        {
            if (!EmailEnabled || string.IsNullOrWhiteSpace(toEmail)) return;

            try
            {
                var message = new MimeMessage();
                message.From.Add(new MailboxAddress(SenderName, SenderEmail));
                message.To.Add(MailboxAddress.Parse(toEmail.Trim()));
                message.Subject = subject;

                var bodyBuilder = new BodyBuilder();
                bodyBuilder.HtmlBody = htmlBody;
                message.Body = bodyBuilder.ToMessageBody();

                using (var client = new SmtpClient())
                {
                    client.Connect(SmtpHost, SmtpPort, SecureSocketOptions.StartTls);
                    client.Authenticate(SmtpUsername, SmtpPassword);
                    client.Send(message);
                    client.Disconnect(true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EmailService Error] Failed to send email to {toEmail}: {ex.Message}");
            }
        }

        /// <summary>
        /// Sends an email asynchronously using HostingEnvironment or Task.Run without blocking the UI thread.
        /// </summary>
        public static void SendEmailAsync(string toEmail, string subject, string htmlBody)
        {
            if (!EmailEnabled || string.IsNullOrWhiteSpace(toEmail)) return;

            try
            {
                System.Web.Hosting.HostingEnvironment.QueueBackgroundWorkItem(ct =>
                {
                    SendEmail(toEmail, subject, htmlBody);
                });
            }
            catch
            {
                Task.Run(() => SendEmail(toEmail, subject, htmlBody));
            }
        }

        #region Email HTML Wrapper Template
        private static string WrapTemplate(string title, string badgeText, string badgeColor, string bodyContent)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<!DOCTYPE html>");
            sb.Append("<html><head><meta charset='utf-8'/><meta name='viewport' content='width=device-width, initial-scale=1.0'/>");
            sb.Append("<style>");
            sb.Append("body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f1f5f9; margin: 0; padding: 20px; color: #334155; }");
            sb.Append(".email-card { max-width: 600px; margin: 20px auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.08); border: 1px solid #e2e8f0; }");
            sb.Append(".email-header { background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); padding: 30px 25px; text-align: center; color: #ffffff; }");
            sb.Append(".email-header h1 { margin: 0; font-size: 22px; font-weight: 700; letter-spacing: -0.5px; }");
            sb.Append(".email-header p { margin: 6px 0 0; font-size: 13px; color: #94a3b8; }");
            sb.Append(".badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; text-transform: uppercase; margin-bottom: 12px; }");
            sb.Append(".email-body { padding: 30px 25px; font-size: 15px; line-height: 1.6; color: #334155; }");
            sb.Append(".info-box { background: #f8fafc; border-left: 4px solid #3b82f6; border-radius: 8px; padding: 16px; margin: 20px 0; }");
            sb.Append(".info-row { display: flex; margin-bottom: 8px; }");
            sb.Append(".info-row:last-child { margin-bottom: 0; }");
            sb.Append(".info-label { font-weight: 600; width: 140px; color: #64748b; }");
            sb.Append(".info-value { color: #0f172a; font-weight: 500; }");
            sb.Append(".btn { display: inline-block; padding: 12px 28px; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); color: #ffffff !important; text-decoration: none; font-weight: 600; border-radius: 8px; margin-top: 20px; box-shadow: 0 4px 12px rgba(37,99,235,0.25); }");
            sb.Append(".email-footer { background: #f8fafc; padding: 20px 25px; text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #e2e8f0; }");
            sb.Append("</style></head><body>");

            sb.Append("<div class='email-card'>");
            sb.Append("<div class='email-header'>");
            sb.Append($"<div class='badge' style='background:{badgeColor}; color:#ffffff;'>{badgeText}</div>");
            sb.Append($"<h1>{title}</h1>");
            sb.Append("<p>Project Board Collaboration Platform</p>");
            sb.Append("</div>");
            sb.Append("<div class='email-body'>");
            sb.Append(bodyContent);
            sb.Append("</div>");
            sb.Append("<div class='email-footer'>");
            sb.Append("<p>&copy; " + DateTime.Now.Year + " Project Board System. All rights reserved.<br/>This is an automated notification, please do not reply to this email.</p>");
            sb.Append("</div></div></body></html>");

            return sb.ToString();
        }
        #endregion

        #region 1. User Signed In
        public static void SendSignInNotification(string toEmail, string userName, string role)
        {
            string title = "Sign-In Alert";
            string badgeText = "Security Alert";
            string badgeColor = "#3b82f6";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(userName)}</strong>,</p>");
            body.Append("<p>We detected a successful sign-in to your <strong>Project Board</strong> account.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Account:</span><span class='info-value'>{WebUtility.HtmlEncode(toEmail)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Role:</span><span class='info-value'>{WebUtility.HtmlEncode(role)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Time:</span><span class='info-value'>{DateTime.Now.ToString("dd MMM yyyy, hh:mm tt")}</span></div>");
            body.Append("</div>");
            body.Append("<p>If this was you, no action is needed. If you did not sign in, please secure your password immediately.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmail(toEmail, "Successful Sign-In to Project Board", html);
        }
        #endregion

        #region 2 & 10. Leader Invites / Requests Member
        public static void SendLeaderRequestToMember(string toEmail, string memberName, string leaderName, string groupName)
        {
            string title = "Group Invitation Received";
            string badgeText = "Team Invite";
            string badgeColor = "#8b5cf6";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(memberName)}</strong>,</p>");
            body.Append($"<p>You have received an invitation from team leader <strong>{WebUtility.HtmlEncode(leaderName)}</strong> to join their project team.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Group Name:</span><span class='info-value'>{WebUtility.HtmlEncode(groupName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Invited By:</span><span class='info-value'>{WebUtility.HtmlEncode(leaderName)}</span></div>");
            body.Append("</div>");
            body.Append("<p>Please log in to your dashboard to review and accept or reject this invitation.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Group Invitation from {leaderName} ({groupName})", html);
        }
        #endregion

        #region 3. Leader Sets Task for User
        public static void SendTaskAssignedToMember(string toEmail, string memberName, string leaderName, string taskTitle, string description, string dueDate)
        {
            string title = "New Task Assigned";
            string badgeText = "Task Assignment";
            string badgeColor = "#06b6d4";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(memberName)}</strong>,</p>");
            body.Append($"<p>Team leader <strong>{WebUtility.HtmlEncode(leaderName)}</strong> has assigned a new task to you.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            if (!string.IsNullOrEmpty(description))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Description:</span><span class='info-value'>{WebUtility.HtmlEncode(description)}</span></div>");
            }
            body.Append($"<div class='info-row'><span class='info-label'>Due Date:</span><span class='info-value'>{(string.IsNullOrEmpty(dueDate) ? "Not Specified" : WebUtility.HtmlEncode(dueDate))}</span></div>");
            body.Append("</div>");
            body.Append("<p>Please review your task details and submit your progress report upon completion.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"New Task Assigned: {taskTitle}", html);
        }
        #endregion

        #region 4. Member Submits Report -> Leader Gets Mail
        public static void SendMemberReportSubmitted(string toEmail, string leaderName, string memberName, string taskTitle, string reportText)
        {
            string title = "Member Task Report Submitted";
            string badgeText = "Report Submitted";
            string badgeColor = "#10b981";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(leaderName)}</strong>,</p>");
            body.Append($"<p>Team member <strong>{WebUtility.HtmlEncode(memberName)}</strong> has submitted a task progress report.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Member:</span><span class='info-value'>{WebUtility.HtmlEncode(memberName)}</span></div>");
            if (!string.IsNullOrEmpty(reportText))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Report Details:</span><span class='info-value'>{WebUtility.HtmlEncode(reportText)}</span></div>");
            }
            body.Append("</div>");
            body.Append("<p>Log in to your leader dashboard to review the report submission.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Task Report Submitted by {memberName} - {taskTitle}", html);
        }
        #endregion

        #region 5. Faculty Assigns Task -> Leader Gets Mail
        public static void SendFacultyTaskAssignedToLeader(string toEmail, string leaderName, string facultyName, string groupName, string taskTitle, string description, string pointsToCover, string dueDate)
        {
            string title = "New Task Assigned by Faculty";
            string badgeText = "Faculty Task";
            string badgeColor = "#6366f1";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(leaderName)}</strong>,</p>");
            body.Append($"<p>Faculty mentor <strong>{WebUtility.HtmlEncode(facultyName)}</strong> has assigned a new project task for group <strong>{WebUtility.HtmlEncode(groupName)}</strong>.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            if (!string.IsNullOrEmpty(description))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Description:</span><span class='info-value'>{WebUtility.HtmlEncode(description)}</span></div>");
            }
            if (!string.IsNullOrEmpty(pointsToCover))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Points to Cover:</span><span class='info-value'>{WebUtility.HtmlEncode(pointsToCover)}</span></div>");
            }
            body.Append($"<div class='info-row'><span class='info-label'>Due Date:</span><span class='info-value'>{(string.IsNullOrEmpty(dueDate) ? "Not Specified" : WebUtility.HtmlEncode(dueDate))}</span></div>");
            body.Append("</div>");
            body.Append("<p>Please review and delegate sub-tasks to your group members as needed.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Faculty Task Assigned: {taskTitle}", html);
        }
        #endregion

        #region 6. Leader Submits Report -> Faculty Gets Mail
        public static void SendLeaderReportSubmitted(string toEmail, string facultyName, string leaderName, string groupName, string taskTitle, string reportText)
        {
            string title = "Leader Milestone Report Submitted";
            string badgeText = "Faculty Review";
            string badgeColor = "#ec4899";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(facultyName)}</strong>,</p>");
            body.Append($"<p>Group Leader <strong>{WebUtility.HtmlEncode(leaderName)}</strong> from group <strong>{WebUtility.HtmlEncode(groupName)}</strong> has submitted a task report for your review.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Group Name:</span><span class='info-value'>{WebUtility.HtmlEncode(groupName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            if (!string.IsNullOrEmpty(reportText))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Leader Report:</span><span class='info-value'>{WebUtility.HtmlEncode(reportText)}</span></div>");
            }
            body.Append("</div>");
            body.Append("<p>Please log in to your faculty dashboard to assess the report and provide feedback.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Group Report Submitted by {leaderName} ({groupName})", html);
        }
        #endregion

        #region 7. Leader Chooses Faculty Mentor -> Mentor Gets Mail
        public static void SendMentorSelectionRequest(string toEmail, string facultyName, string leaderName, string groupName, string techName)
        {
            string title = "Mentorship Request Received";
            string badgeText = "Mentor Request";
            string badgeColor = "#f59e0b";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(facultyName)}</strong>,</p>");
            body.Append($"<p>Group Leader <strong>{WebUtility.HtmlEncode(leaderName)}</strong> has selected you as the faculty mentor for their project team.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Group Name:</span><span class='info-value'>{WebUtility.HtmlEncode(groupName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Technology:</span><span class='info-value'>{WebUtility.HtmlEncode(techName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Group Leader:</span><span class='info-value'>{WebUtility.HtmlEncode(leaderName)}</span></div>");
            body.Append("</div>");
            body.Append("<p>Please log in to your faculty portal to accept or decline this mentorship request.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Mentorship Request from {groupName}", html);
        }
        #endregion

        #region 8. Leader Gets Mail When Mentor Accepts / Declines
        public static void SendMentorDecisionNotification(string toEmail, string leaderName, string facultyName, string groupName, bool isAccepted)
        {
            string title = isAccepted ? "Mentorship Request Approved!" : "Mentorship Request Declined";
            string badgeText = isAccepted ? "Request Accepted" : "Request Declined";
            string badgeColor = isAccepted ? "#10b981" : "#ef4444";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(leaderName)}</strong>,</p>");
            if (isAccepted)
            {
                body.Append($"<p>Great news! Faculty member <strong>{WebUtility.HtmlEncode(facultyName)}</strong> has accepted to mentor your group <strong>{WebUtility.HtmlEncode(groupName)}</strong>.</p>");
            }
            else
            {
                body.Append($"<p>Faculty member <strong>{WebUtility.HtmlEncode(facultyName)}</strong> has declined the mentorship request for group <strong>{WebUtility.HtmlEncode(groupName)}</strong>.</p>");
                body.Append("<p>You can choose another available faculty mentor from your mentor selection dashboard.</p>");
            }
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Faculty Mentor:</span><span class='info-value'>{WebUtility.HtmlEncode(facultyName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Status:</span><span class='info-value'>{(isAccepted ? "Accepted & Active" : "Declined")}</span></div>");
            body.Append("</div>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Mentorship Request Update - {groupName}", html);
        }
        #endregion

        #region 9. Leader Gets Mail When Member Joins Group
        public static void SendMemberJoinedNotification(string toEmail, string leaderName, string memberName, string groupName)
        {
            string title = "New Member Joined Team";
            string badgeText = "Member Joined";
            string badgeColor = "#10b981";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(leaderName)}</strong>,</p>");
            body.Append($"<p>Student <strong>{WebUtility.HtmlEncode(memberName)}</strong> has officially joined your project group <strong>{WebUtility.HtmlEncode(groupName)}</strong>.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Group Name:</span><span class='info-value'>{WebUtility.HtmlEncode(groupName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Member Name:</span><span class='info-value'>{WebUtility.HtmlEncode(memberName)}</span></div>");
            body.Append("</div>");
            body.Append("<p>You can now assign project tasks to this member through your team management dashboard.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"{memberName} Joined Your Group {groupName}", html);
        }
        #endregion

        #region 11. Leader Gets Mail Back That Member Joins Or Rejects
        public static void SendMemberResponseToLeader(string toEmail, string leaderName, string memberName, string groupName, bool isAccepted)
        {
            string title = isAccepted ? "Member Accepted Invitation" : "Member Declined Invitation";
            string badgeText = isAccepted ? "Invite Accepted" : "Invite Declined";
            string badgeColor = isAccepted ? "#10b981" : "#ef4444";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(leaderName)}</strong>,</p>");
            if (isAccepted)
            {
                body.Append($"<p>Student <strong>{WebUtility.HtmlEncode(memberName)}</strong> has accepted your invitation and joined group <strong>{WebUtility.HtmlEncode(groupName)}</strong>!</p>");
            }
            else
            {
                body.Append($"<p>Student <strong>{WebUtility.HtmlEncode(memberName)}</strong> has declined the invitation to join group <strong>{WebUtility.HtmlEncode(groupName)}</strong>.</p>");
            }
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Student:</span><span class='info-value'>{WebUtility.HtmlEncode(memberName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Decision:</span><span class='info-value'>{(isAccepted ? "Accepted & Joined" : "Declined")}</span></div>");
            body.Append("</div>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Invitation Response from {memberName} ({groupName})", html);
        }
        #endregion

        #region 12. Account Deletion Notification by Admin
        public static void SendAccountDeletedNotification(string toEmail, string userName, string role)
        {
            string title = "Account Deletion Notice";
            string badgeText = "Account Removed";
            string badgeColor = "#ef4444";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(userName)}</strong>,</p>");
            body.Append("<p>This email is to notify you that your <strong>Project Board</strong> account has been removed by an Administrator.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Account:</span><span class='info-value'>{WebUtility.HtmlEncode(toEmail)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Role:</span><span class='info-value'>{WebUtility.HtmlEncode(role)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Removed At:</span><span class='info-value'>{DateTime.Now.ToString("dd MMM yyyy, hh:mm tt")}</span></div>");
            body.Append("</div>");
            body.Append("<p>All data associated with your account has been removed from our active system. If you believe this was done in error, please contact your System Administrator.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, "Project Board Account Deletion Notice", html);
        }
        #endregion

        #region 13. Account Created Notification by Admin
        public static void SendAdminCreatedUserNotification(string toEmail, string userName, string role, string enrollmentNo, string rawPassword)
        {
            string title = "Welcome to Project Board!";
            string badgeText = "Account Created";
            string badgeColor = "#10b981";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(userName)}</strong>,</p>");
            body.Append("<p>An Administrator has created a <strong>Project Board</strong> account for you. Here are your account credentials:</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Email / Login ID:</span><span class='info-value'>{WebUtility.HtmlEncode(toEmail)}</span></div>");
            if (!string.IsNullOrEmpty(enrollmentNo))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Enrollment No:</span><span class='info-value'>{WebUtility.HtmlEncode(enrollmentNo)}</span></div>");
            }
            body.Append($"<div class='info-row'><span class='info-label'>Role:</span><span class='info-value'>{WebUtility.HtmlEncode(role)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Password:</span><span class='info-value'>{WebUtility.HtmlEncode(rawPassword)}</span></div>");
            body.Append("</div>");
            body.Append("<p>Please log in using your credentials. We recommend updating your profile or password after your first sign-in.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, "Welcome to Project Board - Account Credentials", html);
        }
        #endregion

        #region 14. Task Status Updated Notification (Completed / Revision Needed)
        public static void SendTaskStatusUpdatedNotification(string toEmail, string recipientName, string reviewerName, string taskTitle, string status, string feedbackText)
        {
            bool isCompleted = status.Equals("Completed", StringComparison.OrdinalIgnoreCase);
            string title = isCompleted ? "Task Approved & Marked Completed" : "Task Revision Requested";
            string badgeText = isCompleted ? "Task Completed" : "Revision Needed";
            string badgeColor = isCompleted ? "#10b981" : "#ef4444";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(recipientName)}</strong>,</p>");
            if (isCompleted)
            {
                body.Append($"<p>Your task report for <strong>{WebUtility.HtmlEncode(taskTitle)}</strong> has been reviewed and <strong style='color:#10b981;'>Approved</strong> by <strong>{WebUtility.HtmlEncode(reviewerName)}</strong>!</p>");
            }
            else
            {
                body.Append($"<p>Your task <strong>{WebUtility.HtmlEncode(taskTitle)}</strong> was reviewed by <strong>{WebUtility.HtmlEncode(reviewerName)}</strong> and requires <strong style='color:#ef4444;'>Revision</strong>.</p>");
            }

            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Reviewed By:</span><span class='info-value'>{WebUtility.HtmlEncode(reviewerName)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Status:</span><span class='info-value'>{WebUtility.HtmlEncode(status)}</span></div>");
            if (!string.IsNullOrEmpty(feedbackText))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Feedback Remarks:</span><span class='info-value'>{WebUtility.HtmlEncode(feedbackText)}</span></div>");
            }
            body.Append("</div>");
            body.Append("<p>Please log in to your Project Board dashboard to view full details.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Task Status Update: {taskTitle} ({status})", html);
        }
        #endregion

        #region 15. Leader Submits Project Proposal -> Faculty Gets Mail
        public static void SendProjectProposalToFaculty(string toEmail, string facultyName, string leaderName, string groupName, string projectTitle, string projectType, string keywords, string functionality)
        {
            string title = "New Project Proposal Submitted";
            string badgeText = "Project Proposal";
            string badgeColor = "#3b82f6";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(facultyName)}</strong>,</p>");
            body.Append($"<p>Group Leader <strong>{WebUtility.HtmlEncode(leaderName)}</strong> from group <strong>{WebUtility.HtmlEncode(groupName)}</strong> has submitted a new project proposal for your review.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Project Title:</span><span class='info-value'>{WebUtility.HtmlEncode(projectTitle)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Project Type:</span><span class='info-value'>{WebUtility.HtmlEncode(projectType)}</span></div>");
            if (!string.IsNullOrWhiteSpace(keywords))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Keywords:</span><span class='info-value'>{WebUtility.HtmlEncode(keywords)}</span></div>");
            }
            body.Append($"<div class='info-row'><span class='info-label'>Group Name:</span><span class='info-value'>{WebUtility.HtmlEncode(groupName)}</span></div>");
            if (!string.IsNullOrWhiteSpace(functionality))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Overview:</span><span class='info-value'>{WebUtility.HtmlEncode(functionality)}</span></div>");
            }
            body.Append("</div>");
            body.Append("<p>Please log in to your faculty portal to review and approve or reject this proposal.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"New Project Proposal: {projectTitle} ({groupName})", html);
        }
        #endregion

        #region 16. Faculty Approves / Rejects Proposal -> Leader Gets Mail
        public static void SendProjectStatusNotificationToLeader(string toEmail, string leaderName, string facultyName, string groupName, string projectTitle, string status)
        {
            bool isApproved = status.Equals("Approved", StringComparison.OrdinalIgnoreCase);
            string title = isApproved ? "Project Proposal Approved!" : "Project Proposal Update";
            string badgeText = isApproved ? "Approved" : status;
            string badgeColor = isApproved ? "#10b981" : (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase) ? "#ef4444" : "#f59e0b");

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(leaderName)}</strong>,</p>");
            if (isApproved)
            {
                body.Append($"<p>Great news! Faculty mentor <strong>{WebUtility.HtmlEncode(facultyName)}</strong> has <strong style='color:#10b981;'>Approved</strong> your project proposal <strong>{WebUtility.HtmlEncode(projectTitle)}</strong> for group <strong>{WebUtility.HtmlEncode(groupName)}</strong>.</p>");
            }
            else
            {
                body.Append($"<p>Faculty mentor <strong>{WebUtility.HtmlEncode(facultyName)}</strong> has updated the status of your project proposal <strong>{WebUtility.HtmlEncode(projectTitle)}</strong> to <strong>{WebUtility.HtmlEncode(status)}</strong>.</p>");
            }

            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Project Title:</span><span class='info-value'>{WebUtility.HtmlEncode(projectTitle)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Status:</span><span class='info-value'>{WebUtility.HtmlEncode(status)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Faculty Mentor:</span><span class='info-value'>{WebUtility.HtmlEncode(facultyName)}</span></div>");
            body.Append("</div>");
            body.Append("<p>Log in to your leader dashboard to view your active projects and details.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Project Proposal Update: {projectTitle} ({status})", html);
        }
        #endregion
        #region 17. Task Appeal Submitted Notification -> Mentor / Leader Gets Mail
        public static void SendTaskAppealSubmittedEmail(string toEmail, string reviewerName, string submitterName, string groupName, string taskTitle)
        {
            string title = "Task Completion Appeal Submitted";
            string badgeText = "Appeal Submitted";
            string badgeColor = "#f59e0b";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(reviewerName)}</strong>,</p>");
            body.Append($"<p><strong>{WebUtility.HtmlEncode(submitterName)}</strong> from group <strong>{WebUtility.HtmlEncode(groupName)}</strong> has submitted an appeal for task completion.</p>");
            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Group Name:</span><span class='info-value'>{WebUtility.HtmlEncode(groupName)}</span></div>");
            body.Append("</div>");
            body.Append("<p>Please log in to your dashboard to review the changes and accept or reject the appeal.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Task Appeal Submitted by {submitterName} - {taskTitle}", html);
        }
        #endregion

        #region 18. Task Appeal Reviewed Notification -> Submitter Gets Mail
        public static void SendTaskAppealReviewedEmail(string toEmail, string submitterName, string reviewerName, string taskTitle, string status, string dueDate)
        {
            bool isAccepted = status.Equals("Accepted", StringComparison.OrdinalIgnoreCase);
            string title = isAccepted ? "Task Appeal Accepted!" : "Task Appeal Rejected";
            string badgeText = isAccepted ? "Task Complete" : "Task Pending";
            string badgeColor = isAccepted ? "#10b981" : "#ef4444";

            StringBuilder body = new StringBuilder();
            body.Append($"<p>Hello <strong>{WebUtility.HtmlEncode(submitterName)}</strong>,</p>");
            if (isAccepted)
            {
                body.Append($"<p>Great news! Reviewer <strong>{WebUtility.HtmlEncode(reviewerName)}</strong> has <strong style='color:#10b981;'>Accepted</strong> your appeal. The task is now marked as complete.</p>");
            }
            else
            {
                body.Append($"<p>Reviewer <strong>{WebUtility.HtmlEncode(reviewerName)}</strong> has <strong style='color:#ef4444;'>Rejected</strong> your appeal. The task is still pending.</p>");
            }

            body.Append("<div class='info-box'>");
            body.Append($"<div class='info-row'><span class='info-label'>Task Title:</span><span class='info-value'>{WebUtility.HtmlEncode(taskTitle)}</span></div>");
            body.Append($"<div class='info-row'><span class='info-label'>Status:</span><span class='info-value'>{(isAccepted ? "Task Completed" : "Task Pending")}</span></div>");
            if (!isAccepted && !string.IsNullOrEmpty(dueDate))
            {
                body.Append($"<div class='info-row'><span class='info-label'>Due Date:</span><span class='info-value'>{WebUtility.HtmlEncode(dueDate)}</span></div>");
            }
            body.Append("</div>");
            body.Append("<p>Log in to your dashboard to view the feedback and details.</p>");

            string html = WrapTemplate(title, badgeText, badgeColor, body.ToString());
            SendEmailAsync(toEmail, $"Task Appeal Update: {taskTitle} ({status})", html);
        }
        #endregion
    }
}
