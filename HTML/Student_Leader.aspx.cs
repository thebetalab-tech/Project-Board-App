using System;
using System.Web.UI;

namespace Project_Board.UI.Student
{
    public partial class Student_Leader : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Restrict direct access if not logged in
            if (Session["UserId"] == null)
            {
                Response.Redirect("../../Default.aspx");
                return;
            }

            // Parse leader validation check securely
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

            // Redirect if not a leader
            if (!isLeader)
            {
                Response.Redirect("Student_Member.aspx?error=access-denied");
                return;
            }

            // Sync database session info with client app state
            string fullName = Session["FullName"] != null ? Session["FullName"].ToString() : "Tirth Leader";
            string email = Session["Email"] != null ? Session["Email"].ToString() : "leader@example.com";

            string jsScript = $@"
                localStorage.setItem('projectBoard_userRole', 'Leader');
                let stateRaw = localStorage.getItem('projectBoard_studentState');
                if (stateRaw) {{
                    try {{
                        let state = JSON.parse(stateRaw);
                        if (state.leader) {{
                            state.leader.name = '{fullName.Replace("'", "\\'")}';
                            state.leader.email = '{email.Replace("'", "\\'")}';
                        }}
                        localStorage.setItem('projectBoard_studentState', JSON.stringify(state));
                    }} catch(e) {{}}
                }}
            ";
            ClientScript.RegisterStartupScript(this.GetType(), "SyncSessionState", jsScript, true);
        }
    }
}
