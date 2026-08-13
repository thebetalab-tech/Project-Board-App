using System;
using System.Web.UI;

namespace Project_Board
{
    public partial class DashboardMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
            }
        }
    }
}
