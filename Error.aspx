<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="Project_Board.Error" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Error - Project Board</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f7f6;
            color: #333;
            text-align: center;
            padding: 50px;
        }
        .error-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            max-width: 600px;
            margin: auto;
        }
        h1 {
            color: #d9534f;
        }
        a {
            color: #0275d8;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="error-container">
            <h1>Oops! Something went wrong.</h1>
            <p>We are sorry, but an unexpected error occurred while processing your request.</p>
            <p>Our team has been notified, and we are working to fix it.</p>
            <br />
            <a href="<%= ResolveUrl("~/Default.aspx") %>">Return to Homepage</a>
        </div>
    </form>
</body>
</html>
