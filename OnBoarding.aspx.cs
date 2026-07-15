using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
namespace Project_Board
{
    public partial class OnBoarding : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if the user is already logged in
                if (Session["Role"] == null || Session["Role"].ToString() != "Student")
                {
                    Response.Redirect("Login.aspx");
                }
            }
        }
        protected void btnStartGroup_Click(object sender, EventArgs e)
        {
            try
            {
                // Change Student IsLeader to true in the database
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    //change user to leader
                    using (SqlCommand command = new SqlCommand("UPDATE Users SET IsLeader = 1 WHERE Email = @Email", connection))
                    {
                        command.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                        command.ExecuteNonQuery();
                        Session["IsLeader"] = true;
                    }

                    
                }
            }
            catch (Exception)
            {
                // Log the exception (you can log it to a file, database, etc.)
                // For simplicity, we'll just show a message here
                ShowMessage("An error occurred while updating your role. Please try again later.", false);
                return;
            }
            Response.Redirect("CreateGroup.aspx");
        }
        protected void btnJoinGroup_Click(object sender, EventArgs e)
        {
            Response.Redirect("JoinGroup.aspx");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            string safeMessage = HttpUtility.JavaScriptStringEncode(message);
            ClientScript.RegisterStartupScript(GetType(), "onboarding_msg", $"alert('{safeMessage}');", true);
        }
    }
}