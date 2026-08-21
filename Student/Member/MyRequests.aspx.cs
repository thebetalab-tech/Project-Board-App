using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Member
{
    public partial class MyRequests : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "SM";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Student Member";
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
                    INNER JOIN Groups g ON gm.GroupId = g.GroupId
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
            switch (status?.ToLower())
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
    }
}
