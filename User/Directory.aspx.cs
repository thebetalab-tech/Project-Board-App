using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.User
{
    public partial class Directory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDirectory();
            }
        }

        private void LoadDirectory()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
                ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT UserId, FullName, Email, Role, IsLeader 
                        FROM Users 
                        WHERE IsActive = 1 
                        ORDER BY Role, FullName";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            
                            rptUsers.DataSource = dt;
                            rptUsers.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Could not load directory: " + ex.Message;
            }
        }
    }
}
