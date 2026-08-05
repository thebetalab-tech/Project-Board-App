using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace Project_Board
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }

        void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs
            Exception exc = Server.GetLastError();

            // Here we could log the exception details to a file, database, or error tracking system like Elmah.
            // For now, we just clear the error so we can let the CustomErrors config redirect, or handle it here.
            // System.Diagnostics.Trace.WriteLine(exc.ToString());
            
            // Optionally, clear error if we want to handle response manually, 
            // but letting it pass through allows Web.config <customErrors> to take over.
        }
    }
}