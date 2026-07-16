using System;
using System.Web.UI;

namespace Project_Board.UI.Student
{
    public partial class Student_Member : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Restrict direct access if not logged in
            if (Session["UserId"] == null)
            {
                Response.Redirect("../../Default.aspx");
                return;
            }

            // Parse session role to sync localStorage state
            bool isLeader = false;
            if (Session["IsLeader"] != null)
            {
                if (Session["IsLeader"] is bool b)
                {
                    isLeader = b;
                }
                else
                {
                    bool.TryParse(Session["IsLeader"].ToString(), out isLeader);
                }
            }

            string roleString = isLeader ? "Leader" : "Member";

            string jsScript = $@"
                localStorage.setItem('projectBoard_userRole', '{roleString}');
            ";
            ClientScript.RegisterStartupScript(this.GetType(), "SyncSessionState", jsScript, true);
        }
    }
}
