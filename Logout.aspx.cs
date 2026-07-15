using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
            try
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("~/Login.aspx");
            }
            catch (Exception ex)
            {
                // Log the exception (you can use a logging framework or write to a log file)
                // For simplicity, we'll just display the error message on the page.
                Console.WriteLine("Error during logout: " + ex.Message);
            }
            finally
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("~/Default.aspx");
            
            }
        
        }
    }
}