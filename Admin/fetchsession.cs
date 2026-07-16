using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public static class SessionHelper
    {
        public static (string userName, string userEmail) fetchsession()
        {
            // Fetch user information from session
            var session = System.Web.HttpContext.Current?.Session;
            string userName = session?["userName"]?.ToString() ?? "Guest";
            string userEmail = session?["userEmail"]?.ToString() ?? "No email provided";
            return (userName, userEmail);
        }
    }
}