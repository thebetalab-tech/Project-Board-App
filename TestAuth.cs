using System;
using System.Security.Cryptography;
using System.Text;
using System.Data.SqlClient;

class Program
{
    static void Main()
    {
        string connStr = @"Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=Project_Board;Integrated Security=True;TrustServerCertificate=True;";
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand("SELECT Email, PasswordHash FROM Users", conn))
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    string email = reader.GetString(0);
                    string hash = reader.GetString(1);
                    // Just testing password "password123" for example
                    bool ok = VerifyPassword("ProjectBoard@123", hash);
                    Console.WriteLine(email + ": Valid with ProjectBoard@123? " + ok);
                    if (!ok) {
                        Console.WriteLine("    Could it be literal txtPassword.Text? " + VerifyPassword("txtPassword.Text", hash));
                        Console.WriteLine("    Could it be Student? " + VerifyPassword("Student", hash));
                        Console.WriteLine("    Could it be Faculty? " + VerifyPassword("Faculty", hash));
                    }
                    if (!ok) {
                        Console.WriteLine("    Could it be empty string? " + VerifyPassword("", hash));
                        Console.WriteLine("    Could it be placeholder? " + VerifyPassword("Create a temporary password", hash));
                    }
                }
            }
        }
    }

    static bool VerifyPassword(string password, string storedHash)
    {
        if (storedHash.StartsWith("QKDF2$"))
        {
            string[] parts = storedHash.Split('$');
            int iterations = int.Parse(parts[1]);
            byte[] salt = Convert.FromBase64String(parts[2]);
            byte[] hash = Convert.FromBase64String(parts[3]);

            using (var deriveBytes = new Rfc2898DeriveBytes(password, salt, iterations))
            {
                byte[] testHash = deriveBytes.GetBytes(32);
                for (int i = 0; i < 32; i++) if (hash[i] != testHash[i]) return false;
                return true;
            }
        }
        return false;
    }
}
