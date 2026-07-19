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
        
        protected string UserInitials { get; set; } = "TL";
        protected bool MemberNeeded { get; set; } = true;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

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
                        }
                    }
                }
                LoadMembers();
            }
        }

    }
}