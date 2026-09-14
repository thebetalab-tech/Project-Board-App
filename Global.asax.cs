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
            if (exc != null)
            {
                // Log server-side so the failure is visible to developers/ops without
                // exposing stack traces to the end user. The response itself is handled
                // by Web.config's <customErrors> redirect (Error.aspx / NotFoundPage.aspx).
                System.Diagnostics.Trace.TraceError(exc.ToString());
            }
        }
    }
}