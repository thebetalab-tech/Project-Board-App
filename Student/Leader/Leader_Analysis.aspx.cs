using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

namespace Project_Board.Student.Leader
{
    public partial class Leader_Analysis : System.Web.UI.Page
    {
        public string TasksByStatusJson { get; set; } = "{}";
        public string MemberTasksJson { get; set; } = "{}";
        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            if (!IsPostBack)
            {
                LoadAnalysisData();
            }
        }

        private void LoadAnalysisData()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            int groupId = 0;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string groupQuery = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
                using (SqlCommand cmd = new SqlCommand(groupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        groupId = Convert.ToInt32(result);
                    }
                }

                if (groupId > 0)
                {
                    string chartQuery = @"
                        SELECT Status, COUNT(1) as Cnt 
                        FROM Task 
                        WHERE GroupId = @GroupId 
                        GROUP BY Status;
                        
                        SELECT u.FullName, COUNT(t.TaskId) as Cnt 
                        FROM Task t 
                        INNER JOIN Users u ON t.AssignedTo = u.UserId 
                        WHERE t.GroupId = @GroupId AND t.Status = 'Completed' 
                        GROUP BY u.FullName;
                    ";

                    using (SqlCommand cmd = new SqlCommand(chartQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        try
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                                
                                // Tasks by Status
                                var dictTasks = new Dictionary<string, int>();
                                while (reader.Read()) { dictTasks[reader["Status"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                TasksByStatusJson = js.Serialize(dictTasks);

                                // Member Tasks
                                if (reader.NextResult())
                                {
                                    var dictMembers = new Dictionary<string, int>();
                                    while (reader.Read()) { dictMembers[reader["FullName"].ToString()] = Convert.ToInt32(reader["Cnt"]); }
                                    MemberTasksJson = js.Serialize(dictMembers);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine(ex.Message);
                        }
                    }
                }
            }
        }
    }
}
