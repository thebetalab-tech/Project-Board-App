<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Mentor.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Mentor" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Dashboard — Mentor Request</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200793429373241" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>Project Board</h2>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href="<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                </div>
                    <div class="nav-section-title">Preferences</div>
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="<%= ResolveUrl("~/Logout.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="avatar">TL</div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Student Leader" %></h4>
                        <p><%= Session["Email"] ?? "leader@example.com" %></p>
                    </div>
                </div>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <div class="topbar">
                <div class="search-bar" style="visibility: hidden;">
                    <i class="fa-solid fa-search"></i>
                    <input type="text" placeholder="Search...">
                </div>
                <div class="topbar-actions">
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Faculty Mentor Request</h1>
                        <p>Select and manage your team's faculty mentor.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Mentor Selection</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1.5rem; font-size: 0.875rem;">Select your faculty mentor. Note: you can only have one active request outstanding. If your request is pending, you must withdraw it to request a different mentor.</p>

                        <!-- If there's an active request -->
                        <div id="divCurrentRequest" runat="server" visible="false" style="margin-bottom: 1.5rem; padding: 1rem; border: 1px solid var(--c-border); border-radius: 8px; background-color: var(--c-bg-elevated);">
                            <asp:Label ID="lblStatus" runat="server" Text=""></asp:Label>
                            <br/><br/>
                            <asp:Button ID="btnWithdraw" runat="server" CssClass="btn-primary" style="background-color: #ef4444 !important; border-color: #ef4444 !important; color: white !important;" Text="Withdraw Request" OnClick="btnWithdraw_Click" />
                        </div>

                        <!-- If no active request -->
                        <div id="divRequestForm" runat="server">
                            <div class="form-group" style="max-width: 400px;">
                                <label for="ddlMentors">Available Faculty</label>
                                <asp:DropDownList ID="ddlMentors" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="" Text="Select a Professor" />
                                </asp:DropDownList>
                            </div>
                            <asp:Button ID="btnRequest" runat="server" CssClass="btn-primary" Text="Send Request" OnClick="btnRequest_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </form>
	<script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
</body>
</html>


