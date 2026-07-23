<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="Project_Board.Logout" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:label ID="lbl1" runat="server"></asp:Label>
            <asp:Label ID="lbl2" runat="server" Text="If You Are Still Seeing This Page Means System Is not working Woohoo!" CssClass="logout-message2"></asp:Label>
            <h1 class="logout-title">Redirecting to Login Page...</h1>
            <asp:HyperLink ID="hlLogin" runat="server" NavigateUrl="~/Default.aspx">Click here to go to the default page</asp:HyperLink>
        </div>
    </form>
</body>
</html>
