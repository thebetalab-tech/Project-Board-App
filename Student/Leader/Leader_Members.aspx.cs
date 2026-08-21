using System.Collections.Generic;
using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Student.Leader
{
    public partial class Leader_Members : Page
    {
        protected global::System.Web.UI.WebControls.Repeater rptGroups;
        protected global::System.Web.UI.WebControls.Repeater rptPending;
        protected global::System.Web.UI.WebControls.Repeater rptEligible;
        protected global::System.Web.UI.WebControls.Repeater rptRequests;
        protected global::System.Web.UI.WebControls.Panel pnlInviteSection;
        protected global::System.Web.UI.WebControls.Panel pnlRequests;
        protected global::System.Web.UI.WebControls.Button btnToggleStatus;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        
        protected global::System.Web.UI.WebControls.CheckBox chkColMemberId;
        protected global::System.Web.UI.WebControls.CheckBox chkColMemberName;
        protected global::System.Web.UI.WebControls.CheckBox chkColEnrollmentNo;
        protected global::System.Web.UI.WebControls.CheckBox chkColEmail;
        protected global::System.Web.UI.WebControls.CheckBox chkColStatus;

        protected string UserInitials { get; set; } = "TL";
        protected bool MemberNeeded { get; set; } = true;
        protected int CurrentLeaderId { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            CurrentLeaderId = Convert.ToInt32(Session["UserId"]);

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Student Leader";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadMembers();
            }
        }

        private int GetGroupId(SqlConnection conn)
        {
            string query = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@LeaderId", Session["UserId"]);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 0;
            }
        }

        private void LoadMembers()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                // Fetch MemberNeeded status
                string groupInfoSql = "SELECT MemberNeeded FROM Groups WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(groupInfoSql, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                    {
                        MemberNeeded = Convert.ToBoolean(result);
                    }
                }
                
                btnToggleStatus.Text = MemberNeeded ? "Mark Team Completed" : "Mark Team Forming";
                pnlInviteSection.Visible = MemberNeeded;

                string query = @"
                    SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, gm.JoinStatus, u.Role
                    FROM GroupMembers gm 
                    INNER JOIN Users u ON gm.UserId = u.UserId 
                    WHERE gm.GroupId = @GroupId AND u.IsActive = 1";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dvAccepted = new DataView(dt);
                        dvAccepted.RowFilter = "JoinStatus = 'Accepted'";
                        rptGroups.DataSource = dvAccepted;
                        rptGroups.DataBind();
                    }
                }
                
                if (MemberNeeded)
                {
                    string eligibleQuery = @"
                        SELECT UserId, FullName, Email, EnrollmentNo 
                        FROM Users 
                        WHERE Role = 'Student' AND IsLeader = 0 AND IsActive = 1 
                        AND UserId NOT IN (SELECT UserId FROM GroupMembers WHERE JoinStatus = 'Accepted')
                        AND UserId NOT IN (SELECT UserId FROM GroupMembers WHERE GroupId = @GroupId)";
                    using (SqlCommand cmd = new SqlCommand(eligibleQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dtEligible = new DataTable();
                            da.Fill(dtEligible);
                            rptEligible.DataSource = dtEligible;
                            rptEligible.DataBind();
                        }
                    }
                }
            }
        }

        protected void btnToggleStatus_Click(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;
                
                string groupInfoSql = "SELECT MemberNeeded FROM Groups WHERE GroupId = @GroupId";
                bool currentStatus = true;
                using (SqlCommand cmd = new SqlCommand(groupInfoSql, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null) currentStatus = Convert.ToBoolean(result);
                }
                
                string updateSql = "UPDATE Groups SET MemberNeeded = @NewStatus WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@NewStatus", !currentStatus);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.ExecuteNonQuery();
                }
            }
            LoadMembers();
        }

        protected void rptEligible_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Invite")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    int groupId = GetGroupId(conn);
                    if (groupId == 0) return;

                    string checkSql = "SELECT COUNT(1) FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count == 0)
                        {
                            string insertSql = "INSERT INTO GroupMembers (GroupId, UserId, JoinStatus) VALUES (@GroupId, @UserId, 'Pending')";
                            using (SqlCommand insCmd = new SqlCommand(insertSql, conn))
                            {
                                insCmd.Parameters.AddWithValue("@GroupId", groupId);
                                insCmd.Parameters.AddWithValue("@UserId", targetUserId);
                                insCmd.ExecuteNonQuery();
                            }

                            // Fetch target user & group details for email notification
                            string detailsSql = @"
                                SELECT u.FullName AS MemberName, u.Email AS MemberEmail, g.GroupName
                                FROM Users u, Groups g
                                WHERE u.UserId = @UserId AND g.GroupId = @GroupId";
                            using (SqlCommand detCmd = new SqlCommand(detailsSql, conn))
                            {
                                detCmd.Parameters.AddWithValue("@UserId", targetUserId);
                                detCmd.Parameters.AddWithValue("@GroupId", groupId);
                                using (SqlDataReader rdr = detCmd.ExecuteReader())
                                {
                                    if (rdr.Read())
                                    {
                                        string memberName = rdr["MemberName"].ToString();
                                        string memberEmail = rdr["MemberEmail"].ToString();
                                        string groupName = rdr["GroupName"].ToString();
                                        string leaderName = Session["FullName"]?.ToString() ?? "Student Leader";

                                        Project_Board.Services.EmailService.SendLeaderRequestToMember(memberEmail, memberName, leaderName, groupName);
                                    }
                                }
                            }
                        }
                    }
                }
                LoadMembers();
            }
        }

        protected void rptGroups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DropMember")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                int leaderId = Convert.ToInt32(Session["UserId"]);

                if (targetUserId == leaderId)
                {
                    lblMessage.Text = "Group Leaders cannot drop themselves from the group.";
                    lblMessage.CssClass = "error-message";
                    lblMessage.Style["display"] = "block";
                    lblMessage.Style["background-color"] = "#fee2e2";
                    lblMessage.Style["color"] = "#991b1b";
                    lblMessage.Style["border"] = "1px solid #fecaca";
                    return;
                }

                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    int groupId = GetGroupId(conn);
                    if (groupId == 0) return;

                    string verifyMemberSql = "SELECT COUNT(1) FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId";
                    using (SqlCommand verifyCmd = new SqlCommand(verifyMemberSql, conn))
                    {
                        verifyCmd.Parameters.AddWithValue("@GroupId", groupId);
                        verifyCmd.Parameters.AddWithValue("@UserId", targetUserId);
                        int count = Convert.ToInt32(verifyCmd.ExecuteScalar());
                        if (count == 0)
                        {
                            lblMessage.Text = "The specified user is not a member of your group.";
                            lblMessage.CssClass = "error-message";
                            lblMessage.Style["display"] = "block";
                            lblMessage.Style["background-color"] = "#fee2e2";
                            lblMessage.Style["color"] = "#991b1b";
                            lblMessage.Style["border"] = "1px solid #fecaca";
                            return;
                        }
                    }

                    string memberName = "";
                    string memberEmail = "";
                    string groupName = "";
                    string detailsSql = @"
                        SELECT u.FullName, u.Email, g.GroupName 
                        FROM Users u, Groups g 
                        WHERE u.UserId = @UserId AND g.GroupId = @GroupId";
                    using (SqlCommand detCmd = new SqlCommand(detailsSql, conn))
                    {
                        detCmd.Parameters.AddWithValue("@UserId", targetUserId);
                        detCmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataReader rdr = detCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                memberName = rdr["FullName"].ToString();
                                memberEmail = rdr["Email"].ToString();
                                groupName = rdr["GroupName"].ToString();
                            }
                        }
                    }

                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // 1. Remove user from GroupMembers
                            string deleteMemberSql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId";
                            using (SqlCommand delCmd = new SqlCommand(deleteMemberSql, conn, trans))
                            {
                                delCmd.Parameters.AddWithValue("@GroupId", groupId);
                                delCmd.Parameters.AddWithValue("@UserId", targetUserId);
                                delCmd.ExecuteNonQuery();
                            }

                            // 2. Reassign non-completed tasks assigned to this dropped member back to Leader
                            string reassignTaskSql = @"
                                UPDATE Task 
                                SET AssignedTo = @LeaderId, UpdatedAt = GETDATE() 
                                WHERE GroupId = @GroupId AND AssignedTo = @UserId AND Status != 'Completed'";
                            using (SqlCommand taskCmd = new SqlCommand(reassignTaskSql, conn, trans))
                            {
                                taskCmd.Parameters.AddWithValue("@GroupId", groupId);
                                taskCmd.Parameters.AddWithValue("@UserId", targetUserId);
                                taskCmd.Parameters.AddWithValue("@LeaderId", leaderId);
                                taskCmd.ExecuteNonQuery();
                            }

                            // 3. Insert In-App Notification for dropped member
                            string notifySql = @"
                                INSERT INTO Notifications (UserId, Message, Link) 
                                VALUES (@UserId, @Message, '~/Student/Member/Dashboard.aspx')";
                            using (SqlCommand notifCmd = new SqlCommand(notifySql, conn, trans))
                            {
                                notifCmd.Parameters.AddWithValue("@UserId", targetUserId);
                                notifCmd.Parameters.AddWithValue("@Message", $"You have been removed from group '{groupName}' by the team leader.");
                                notifCmd.ExecuteNonQuery();
                            }

                            // 4. Update MemberNeeded = 1 in Groups table so leader can invite a replacement
                            string updateGroupSql = "UPDATE Groups SET MemberNeeded = 1 WHERE GroupId = @GroupId";
                            using (SqlCommand updateGroupCmd = new SqlCommand(updateGroupSql, conn, trans))
                            {
                                updateGroupCmd.Parameters.AddWithValue("@GroupId", groupId);
                                updateGroupCmd.ExecuteNonQuery();
                            }

                            trans.Commit();

                            if (!string.IsNullOrEmpty(memberEmail))
                            {
                                string leaderName = Session["FullName"]?.ToString() ?? "Student Leader";
                                Project_Board.Services.EmailService.SendMemberDroppedNotification(memberEmail, memberName, leaderName, groupName);
                            }

                            lblMessage.Text = $"Member <strong>{System.Web.HttpUtility.HtmlEncode(memberName)}</strong> has been successfully removed from your group.";
                            lblMessage.CssClass = "success-message";
                            lblMessage.Style["display"] = "block";
                            lblMessage.Style["background-color"] = "#dcfce7";
                            lblMessage.Style["color"] = "#166534";
                            lblMessage.Style["border"] = "1px solid #bbf7d0";
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            lblMessage.Text = "An error occurred while dropping member: " + ex.Message;
                            lblMessage.CssClass = "error-message";
                            lblMessage.Style["display"] = "block";
                            lblMessage.Style["background-color"] = "#fee2e2";
                            lblMessage.Style["color"] = "#991b1b";
                            lblMessage.Style["border"] = "1px solid #fecaca";
                        }
                    }
                }
                LoadMembers();
            }
        }

        protected void btnGeneratePdf_Click(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                string query = @"
                    SELECT 
                        u.UserId AS [Member ID], 
                        u.FullName AS [Member Name], 
                        u.EnrollmentNo AS [Enrollment No.], 
                        u.Email AS [Email Address], 
                        gm.JoinStatus AS [Status]
                    FROM GroupMembers gm 
                    INNER JOIN Users u ON gm.UserId = u.UserId 
                    WHERE gm.GroupId = @GroupId AND gm.JoinStatus = 'Accepted' AND u.IsActive = 1";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        List<string> selectedCols = new List<string>();
                        if (chkColMemberId.Checked) selectedCols.Add("Member ID");
                        if (chkColMemberName.Checked) selectedCols.Add("Member Name");
                        if (chkColEnrollmentNo.Checked) selectedCols.Add("Enrollment No.");
                        if (chkColEmail.Checked) selectedCols.Add("Email Address");
                        if (chkColStatus.Checked) selectedCols.Add("Status");

                        string userName = Session["FullName"]?.ToString() ?? "Student Leader";
                        string userEmail = Session["Email"]?.ToString() ?? "leader@example.com";
                        
                        byte[] pdfBytes = Project_Board.Utils.ReportService.GeneratePdfReport("My Team Members Report", dt, userName, userEmail, selectedCols);
                        
                        Response.Clear();
                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition", "attachment;filename=Leader_TeamMembersReport.pdf");
                        Response.BinaryWrite(pdfBytes);
                        Response.End();
                    }
                }
            }
        }

    }
}
