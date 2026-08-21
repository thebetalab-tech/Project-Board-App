using System;
using System.Web.UI;

namespace Project_Board.Student.Member
{
    public partial class MemberMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Prevent Leaders and Faculty from accessing Member dashboard
            if (Session["UserId"] != null)
            {
                string role = Session["Role"]?.ToString() ?? "";
                if (role == "Leader")
                {
                    Response.Redirect("~/Student/Leader/Dashboard.aspx");
                }
                else if (role == "Faculty")
                {
                    Response.Redirect("~/Faculty/Dashboard.aspx");
                }
            }
        }
    }
}
