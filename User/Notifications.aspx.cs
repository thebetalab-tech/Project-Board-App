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
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
            if (string.IsNullOrEmpty(connString))
            {
                System.Diagnostics.Trace.TraceError("[Notifications] Connection string 'Project_BoardConnectionString' is not configured.");
                return;
            }

            try
            {
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
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("[Notifications] Failed to load notifications: " + ex);
            }
        }

        // IsRead and CreatedAt are nullable in the Notifications table (BIT/DATETIME with a
        // DEFAULT but no NOT NULL), so rows inserted outside the app can carry NULL. Reading
        // them through Convert.ToBoolean/ToDateTime directly in the markup would throw
        // InvalidCastException while data-binding and take the whole page down.
        protected bool IsNotificationRead(object value)
        {
            return value != null && value != DBNull.Value && Convert.ToBoolean(value);
        }

        protected string FormatNotificationDate(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            DateTime created;
            if (!DateTime.TryParse(value.ToString(), out created)) return "";
            return created.ToString("MMM dd, yyyy h:mm tt");
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead")
            {
                if (!int.TryParse(Convert.ToString(e.CommandArgument), out int notificationId))
                {
                    System.Diagnostics.Trace.TraceError("[Notifications] MarkRead received a non-numeric CommandArgument.");
                    return;
                }

                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
                if (string.IsNullOrEmpty(connString))
                {
                    System.Diagnostics.Trace.TraceError("[Notifications] Connection string 'Project_BoardConnectionString' is not configured.");
                    return;
                }

                try
                {
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
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("[Notifications] Failed to mark notification as read: " + ex);
                }

                LoadNotifications();
            }
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
            if (string.IsNullOrEmpty(connString))
            {
                System.Diagnostics.Trace.TraceError("[Notifications] Connection string 'Project_BoardConnectionString' is not configured.");
                return;
            }

            try
            {
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
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("[Notifications] Failed to mark all notifications as read: " + ex);
            }

            LoadNotifications();
        }
    }
}
