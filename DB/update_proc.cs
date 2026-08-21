using System;
using System.Data.SqlClient;

class Program {
    static void Main() {
        string connStr = "Server=db60483.databaseasp.net;Database=db60483;User Id=db60483;Password=K+c38N?jf9L!;Encrypt=False;MultipleActiveResultSets=True;";
        using (SqlConnection conn = new SqlConnection(connStr)) {
            conn.Open();
            string sql = @"
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Groups]') AND name = 'IsActive')
BEGIN
    ALTER TABLE [dbo].[Groups] ADD IsActive BIT NOT NULL DEFAULT 1;
END
";
            using (SqlCommand cmd = new SqlCommand(sql, conn)) {
                cmd.ExecuteNonQuery();
            }
        }
        Console.WriteLine("Done");
    }
}
