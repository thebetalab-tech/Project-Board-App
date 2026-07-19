using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Leader
{
    public partial class InvitationManager : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "TL";

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
                LoadInvitations();
            }
        }

        private int GetGroupId(SqlConnection conn)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string sql = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@LeaderId", userId);
                object result = cmd.ExecuteScalar();
                if (result != null) return Convert.ToInt32(result);
            }
            return 0;
        }

        private void LoadInvitations()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                string query = @"
                    SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, gm.JoinStatus
                    FROM GroupMembers gm 
                    INNER JOIN Users u ON gm.UserId = u.UserId 
                    WHERE gm.GroupId = @GroupId AND u.IsActive = 1 AND gm.JoinStatus IN ('Pending', 'Requested')";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dvRequested = new DataView(dt);
                        dvRequested.RowFilter = "JoinStatus = 'Requested'";
                        rptRequests.DataSource = dvRequested;
                        rptRequests.DataBind();
                        pnlRequests.Visible = dvRequested.Count > 0;

                        DataView dvPending = new DataView(dt);
                        dvPending.RowFilter = "JoinStatus = 'Pending'";
                        rptPending.DataSource = dvPending;
                        rptPending.DataBind();
                        pnlPending.Visible = dvPending.Count > 0;
                        
                        pnlEmptyState.Visible = dvRequested.Count == 0 && dvPending.Count == 0;
                    }
                }
            }
        }

        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int targetUserId = Convert.ToInt32(e.CommandArgument);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                if (e.CommandName == "Accept")
                {
                    string acceptSql = "UPDATE GroupMembers SET JoinStatus = 'Accepted' WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Requested'";
                    using (SqlCommand cmd = new SqlCommand(acceptSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }

                    string deleteOthersSql = "DELETE FROM GroupMembers WHERE UserId = @UserId AND JoinStatus != 'Accepted'";
                    using (SqlCommand cmd = new SqlCommand(deleteOthersSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else if (e.CommandName == "Reject")
                {
                    string rejectSql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Requested'";
                    using (SqlCommand cmd = new SqlCommand(rejectSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            LoadInvitations();
        }

        protected void rptPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Revoke")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    int groupId = GetGroupId(conn);
                    if (groupId == 0) return;

                    string deleteSql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Pending'";
                    using (SqlCommand cmd = new SqlCommand(deleteSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadInvitations();
            }
        }
    }
}