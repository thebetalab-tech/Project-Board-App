using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Member
{
    public partial class MyRequests : System.Web.UI.Page
    {
        private string _userInitials = "SM";
        protected string UserInitials
        {
            get { return _userInitials; }
            set { _userInitials = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"] != null ? Session["FullName"].ToString() : "Student Member";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadMyRequests();
            }
        }

        private void LoadMyRequests()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT
                        gm.GroupId, gm.UserId, gm.JoinStatus, gm.RequestedAt,
                        g.GroupName, t.TechName, g.Status AS GroupStatus,
                        l.FullName AS LeaderName, l.Email AS LeaderEmail
                    FROM GroupMembers gm
                    INNER JOIN (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g ON gm.GroupId = g.GroupId
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    INNER JOIN Users l ON g.LeaderId = l.UserId
                    WHERE gm.UserId = @UserId
                    ORDER BY gm.RequestedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptRequests.DataSource = dt;
                        rptRequests.DataBind();
                    }
                }
            }
        }

        protected string GetStatusClass(string status)
        {
            switch (status != null ? status.ToLower() : null)
            {
                case "pending":
                    return "badge-pending";
                case "requested":
                    return "badge-requested";
                case "accepted":
                    return "badge-accepted";
                case "rejected":
                    return "badge-rejected";
                default:
                    return "badge-pending";
            }
        }

        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "CancelRequest")
            {
                int groupId = Convert.ToInt32(e.CommandArgument);
                int userId = Convert.ToInt32(Session["UserId"]);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string sql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus IN ('Requested', 'Pending')";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            ShowMessage("Request cancelled successfully.", true);
                        }
                        else
                        {
                            ShowMessage("Could not cancel request. It may have already been processed.", false);
                        }
                    }
                }
                LoadMyRequests();
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";

            string icon = isSuccess ? "<i class='fa-solid fa-check-circle' style='margin-right:0.5rem;'></i>" : "<i class='fa-solid fa-exclamation-circle' style='margin-right:0.5rem;'></i>";
            string bgColor = isSuccess ? "rgba(34,197,94,0.15)" : "rgba(239,68,68,0.15)";
            string color = isSuccess ? "#22c55e" : "#ef4444";

            pnlMessage.Style["background"] = bgColor;
            pnlMessage.Style["color"] = color;
            pnlMessage.Style["border"] = "1px solid " + color;
            pnlMessage.Style["display"] = "block";

            litMessage.Text = icon + message;
        }
    }
}
