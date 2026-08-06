using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Project_Board.User
{
    public partial class Notifications : System.Web.UI.Page
    {
        protected global::System.Web.UI.HtmlControls.HtmlForm form1;
        protected global::System.Web.UI.WebControls.LinkButton btnBack;
        protected global::System.Web.UI.WebControls.LinkButton btnMarkAllRead;
        protected global::System.Web.UI.WebControls.Repeater rptNotifications;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadNotifications();
            }
        }

        private void LoadNotifications()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_select_notifications", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "BY_USER");
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        rptNotifications.DataSource = dt;
                        rptNotifications.DataBind();
                    }
                }
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead")
            {
                int notificationId = Convert.ToInt32(e.CommandArgument);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("sp_crud_notifications", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "MARK_READ");
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadNotifications();
            }
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_crud_notifications", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "MARK_ALL_READ");
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }
            }
            LoadNotifications();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            string role = Session["Role"]?.ToString();
            string isLeaderStr = Session["IsLeader"]?.ToString();
            bool isLeader = false;
            if (!string.IsNullOrEmpty(isLeaderStr))
                isLeader = Convert.ToBoolean(isLeaderStr);

            if (role == "Admin") Response.Redirect("~/Admin/Admin_Dashboard.aspx");
            else if (role == "Faculty") Response.Redirect("~/Faculty/Dashboard.aspx");
            else if (role == "Student")
            {
                if (isLeader) Response.Redirect("~/Student/Leader/Dashboard.aspx");
                else Response.Redirect("~/Student/Member/Dashboard.aspx");
            }
            else Response.Redirect("~/Default.aspx");
        }
    }
}
