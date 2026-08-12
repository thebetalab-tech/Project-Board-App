using System;
using System.Configuration;
using System.Data.SqlClient;

namespace Project_Board.Utils
{
    public static class NotificationHelper
    {
        public static int GetUnreadCount(object userIdObj)
        {
            if (userIdObj == null) return 0;
            int userId = Convert.ToInt32(userIdObj);
            int count = 0;
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
            
            if (string.IsNullOrEmpty(connString)) return 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_select_notifications", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "UNREAD_COUNT");
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            count = Convert.ToInt32(result);
                        }
                    }
                }
            }
            catch
            {
                // Ignore exceptions so it doesn't break UI
            }
            return count;
        }
    }
}
