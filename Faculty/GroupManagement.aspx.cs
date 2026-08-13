using System.Collections.Generic;
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

        protected void btnGeneratePdf_Click(object sender, EventArgs e)
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        g.GroupName AS [Group Name], 
                        u.FullName AS [Leader Name], 
                        t.TechName AS [Technology],
                        (SELECT COUNT(*) FROM GroupMembers gm WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted') AS [Team Size]
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
                        
                        List<string> selectedCols = new List<string>();
                        if (chkColGroupName.Checked) selectedCols.Add("Group Name");
                        if (chkColLeaderName.Checked) selectedCols.Add("Leader Name");
                        if (chkColTechnology.Checked) selectedCols.Add("Technology");
                        if (chkColTeamSize.Checked) selectedCols.Add("Team Size");

                        string userName = Session["FullName"]?.ToString() ?? "Faculty";
                        string userEmail = Session["Email"]?.ToString() ?? "faculty@example.com";
                        
                        byte[] pdfBytes = Project_Board.Utils.ReportService.GeneratePdfReport("Mentored Groups Report", dt, userName, userEmail, selectedCols);
                        
                        Response.Clear();
                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition", "attachment;filename=Faculty_GroupsReport.pdf");
                        Response.BinaryWrite(pdfBytes);
                        Response.End();
                    }
                }
            }
        }
    }
}


