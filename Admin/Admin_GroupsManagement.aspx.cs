using System.Collections.Generic;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_GroupsManagement : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Fetch user information from session



                LoadGroups();
            }
        }

        private void LoadGroups()
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        g.GroupId,
                        g.GroupName,
                        g.Status,
                        l.FullName AS LeaderName,
                        m.FullName AS MentorName,
                        STUFF((
                            SELECT ', ' + u.FullName 
                            FROM GroupMembers gm 
                            JOIN Users u ON gm.UserId = u.UserId 
                            WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted'
                            FOR XML PATH('')
                        ), 1, 2, '') AS Members
                    FROM Groups g
                    JOIN Users l ON g.LeaderId = l.UserId
                    LEFT JOIN Users m ON g.MentorId = m.UserId";
                    
                if (filter != "All")
                {
                    query += " WHERE g.Status = @Status";
                }
                
                query += " ORDER BY g.GroupName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", filter);
                    }
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            rptGroups.DataSource = reader;
                            rptGroups.DataBind();
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
            }
        }

        protected void ddlReportFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadGroups();
        }

        protected void btnExportReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;
            
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        g.GroupName AS [Group Name],
                        g.Status AS [Status],
                        l.FullName AS [Leader Name],
                        ISNULL(m.FullName, 'Not Assigned') AS [Faculty Mentor],
                        STUFF((
                            SELECT ', ' + u.FullName 
                            FROM GroupMembers gm 
                            JOIN Users u ON gm.UserId = u.UserId 
                            WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted'
                            FOR XML PATH('')
                        ), 1, 2, '') AS [Members]
                    FROM Groups g
                    JOIN Users l ON g.LeaderId = l.UserId
                    LEFT JOIN Users m ON g.MentorId = m.UserId";

                if (filter != "All")
                {
                    query += " WHERE g.Status = @Status";
                }
                
                query += " ORDER BY g.GroupName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filter != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", filter);
                    }
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        string userName = Session["FullName"]?.ToString() ?? "Admin";
                        string userEmail = Session["Email"]?.ToString() ?? "admin@example.com";
                        
                        List<string> selectedCols = new List<string>();
                        foreach (DataColumn column in dt.Columns)
                        {
                            selectedCols.Add(column.ColumnName);
                        }
                        
                        byte[] pdfBytes = Project_Board.Utils.ReportService.GeneratePdfReport("Groups Management Report", dt, userName, userEmail, selectedCols);
                        
                        Response.Clear();
                        Response.ContentType = "application/pdf";
                        Response.AddHeader("content-disposition", "attachment;filename=Report.pdf");
                        Response.BinaryWrite(pdfBytes);
                        Response.End();
                    }
                }
            }
        }

        protected void rptGroups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteGroup")
            {
                int groupId = Convert.ToInt32(e.CommandArgument);
                if (string.IsNullOrEmpty(connString)) return;

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string deleteQuery = @"
                        IF OBJECT_ID('ProjectKeywords', 'U') IS NOT NULL
                            DELETE FROM ProjectKeywords WHERE ProjectId IN (SELECT ProjectId FROM Projects WHERE GroupId = @GroupId);
                        IF OBJECT_ID('Projects', 'U') IS NOT NULL
                            DELETE FROM Projects WHERE GroupId = @GroupId;
                        IF OBJECT_ID('Task', 'U') IS NOT NULL
                            DELETE FROM Task WHERE GroupId = @GroupId;
                        IF OBJECT_ID('Tasks', 'U') IS NOT NULL
                            DELETE FROM Tasks WHERE GroupId = @GroupId;
                        
                        DELETE FROM GroupMentorRejections WHERE GroupId = @GroupId;
                        DELETE FROM GroupMembers WHERE GroupId = @GroupId;
                        DELETE FROM Groups WHERE GroupId = @GroupId;
                    ";
                    
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            LoadGroups();
                        }
                        catch (Exception)
                        {
                            // Could log or show error.
                        }
                    }
                }
            }
        }

        protected void btnUpdateGroup_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(connString)) return;

            string groupIdStr = hdnEditGroupId.Value;
            string status = ddlEditGroupStatus.SelectedValue;

            int groupId;
            if (!int.TryParse(groupIdStr, out groupId)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "UPDATE Groups SET Status = @Status WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        LoadGroups();
                        lblEditMessage.ForeColor = System.Drawing.Color.Green;
                        lblEditMessage.Text = "Group updated successfully.";
                        ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal", "closeModal('editGroupModal');", true);
                    }
                    catch (Exception ex)
                    {
                        lblEditMessage.ForeColor = System.Drawing.Color.Red;
                        lblEditMessage.Text = "Error updating group: " + ex.Message;
                    }
                }
            }
        }
    }
}