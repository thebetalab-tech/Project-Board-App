<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvitationManager.aspx.cs" Inherits="Project_Board.Faculty.InvitationManager" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Invitations</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200797339881886" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo-icon"><i class="fa-solid fa-graduation-cap" style="color: white;"></i></div>
                <h2>Project Board</h2>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href="<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
                    </a>
                </div>
                <div class="nav-section">
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
                    <div class="avatar"><%= UserInitials %></div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Faculty Member" %></h4>
                        <p><%= Session["Email"] ?? "faculty@example.com" %></p>
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
                        <h1>Invitations</h1>
                        <p>Welcome to the Invitations section.</p>
                    </div>
                </div>
                
                                <div class="data-section">
                    <div class="section-header">
                        <h2>Pending Mentor Requests</h2>
                    </div>
                    
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="form-message"></asp:Label>

                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Group Name</th>
                                    <th>Leader Name</th>
                                    <th>Technology</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptRequests" runat="server" OnItemCommand="rptRequests_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("GroupName") %></strong></td>
                                            <td><%# Eval("LeaderName") %></td>
                                            <td><span class="badge status-forming"><%# Eval("TechName") %></span></td>
                                            <td><span class="badge status-pending">Pending Approval</span></td>
                                            <td>
                                                <div class="table-actions">
                                                    <asp:LinkButton ID="btnAccept" runat="server" CommandName="Accept" CommandArgument='<%# Eval("GroupId") %>' CssClass="icon-btn" title="Accept Request">
                                                        <i class="fa-solid fa-check" style="color: var(--c-green);"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("GroupId") %>' CssClass="icon-btn delete" title="Reject Request">
                                                        <i class="fa-solid fa-xmark"></i>
                                                    </asp:LinkButton>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# rptRequests.Items.Count == 0 ? "<tr><td colspan='5' style='text-align:center; padding: 2rem; color: var(--c-text-muted);'>No pending mentor requests at this time.</td></tr>" : "" %>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            </div>
        </main>
    </form>
    
    <!-- Mobile toggle script -->
    <script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
</body>
</html>


