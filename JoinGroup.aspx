<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JoinGroup.aspx.cs" Inherits="Project_Board.JoinGroup" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join a Group — Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="Admin/admin.css" />
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
                    <a href="<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="<%= ResolveUrl("~/JoinGroup.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-users"></i> Join Group
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
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
                        <h4><%= Session["FullName"] ?? "Student Member" %></h4>
                        <p><%= Session["Email"] ?? "member@example.com" %></p>
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
                        <h1>Browse Available Groups</h1>
                        <p>Find a group that fits your technology domain and request to join.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Forming Teams</h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Group Details</th>
                                    <th>Technology</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptAvailableGroups" runat="server" OnItemCommand="rptAvailableGroups_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <div class="user-cell">
                                                    <div class="user-cell-avatar"><i class="fa-solid fa-users" style="color: var(--c-text-muted);"></i></div>
                                                    <div class="user-cell-info">
                                                        <h4><%# Eval("GroupName") %></h4>
                                                        <p>Leader: <%# Eval("LeaderName") %></p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><%# Eval("TechName") %></td>
                                            <td style="text-align: right;">
                                                <asp:Button ID="btnRequest" runat="server" 
                                                    CssClass='<%# Convert.ToInt32(Eval("HasRequested")) > 0 ? "btn-secondary" : "btn-primary" %>' 
                                                    Text='<%# Convert.ToInt32(Eval("HasRequested")) > 0 ? "Requested" : "Request to Join" %>' 
                                                    CommandName="RequestJoin" 
                                                    CommandArgument='<%# Eval("GroupId") %>' 
                                                    Enabled='<%# Convert.ToInt32(Eval("HasRequested")) == 0 %>' />
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
