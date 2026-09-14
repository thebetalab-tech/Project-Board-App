using System;
using System.Security.Cryptography;

namespace Project_Board.Utils
{
    // Shared PBKDF2 password hashing and one-time-code generation used by SignUp,
    // the forgot-password flow, and profile password changes — previously copy-pasted
    // identically in each of those code-behind files.
    public static class AuthHelper
    {
        public static string HashPassword(string password)
        {
            byte[] salt = new byte[16];

            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }

            using (var deriveBytes = new Rfc2898DeriveBytes(password, salt, 100000))
            {
                byte[] hash = deriveBytes.GetBytes(32);
                return $"QKDF2$100000${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";
            }
        }

        public static string GenerateRandomCode()
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] bytes = new byte[4];
                rng.GetBytes(bytes);
                // Mask off the sign bit instead of Math.Abs, which throws OverflowException
                // for int.MinValue.
                int value = (BitConverter.ToInt32(bytes, 0) & 0x7FFFFFFF) % 900000 + 100000;
                return value.ToString();
            }
        }
    }
}
