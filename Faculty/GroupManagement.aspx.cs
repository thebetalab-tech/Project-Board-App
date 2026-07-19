using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Faculty
{
    public partial class GroupManagement : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Repeater rptGroups;
        protected string UserInitials { get; set; } = "FM";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Faculty")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Faculty Member";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadActiveGroups();
            }
        }

        private void LoadActiveGroups()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        g.GroupId, 
                        g.GroupName, 
                        u.FullName AS LeaderName, 
                        t.TechName,
                        (SELECT COUNT(*) FROM GroupMembers gm WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted') AS MemberCount
                    FROM Groups g
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    INNER JOIN Technologies t ON g.TechId = t.TechId
                    WHERE g.MentorId = @FacultyId AND g.Status != 'Pending Faculty Approval' AND g.Status != 'Forming'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptGroups.DataSource = dt;
                        rptGroups.DataBind();
                    }
                }
            }
        }
    }
}
