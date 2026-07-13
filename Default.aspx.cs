using System;
using System.Web.UI;
    
namespace Project_Board
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void loginBtn_Click(object sender, EventArgs e)
        {
            string loginId = Request.Form["txtLoginID"]?.Trim();
            string password = Request.Form["txtPassword"];

            if (string.IsNullOrWhiteSpace(loginId) || string.IsNullOrWhiteSpace(password))
            {
                return;
            }

            Session["LoginId"] = loginId;
        }
    }
}