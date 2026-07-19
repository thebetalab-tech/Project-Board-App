<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvitationManager.aspx.cs" Inherits="Project_Board.Student.Member.InvitationManager" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Invitations — Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../../Admin/admin.css?v=639200793429432375">
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
                    <a href="Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="Member_Team.aspx" class="nav-link">
                        <i class="fa-solid fa-users"></i> Team & Mentor
                    </a>
                    <a href="InvitationManager.aspx" class="nav-link active">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <% if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Leader") { %>
                    <a href="../Leader/Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-user-tie"></i> Leader Panel
                    </a>
                    <% } %>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href="../../User/Profile.aspx" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="../../Logout.aspx" class="nav-link">
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
                    <a href="../../User/Profile.aspx" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Invitations Inbox</h1>
                        <p>Manage invitations sent to you by team leaders.</p>
                    </div>
                </div>

                <asp:Panel ID="pnlInvitations" runat="server" CssClass="data-section" Visible="false">
                    <div class="section-header">
                        <h2>Pending Invitations <span class="badge" style="background: var(--c-blue); color: white;">New</span></h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Group Details</th>
                                    <th>Technology Domain</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptInvitations" runat="server" OnItemCommand="rptInvitations_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <div class="user-cell">
                                                    <div class="user-cell-avatar"><i class="fa-solid fa-layer-group" style="color: var(--c-text-muted);"></i></div>
                                                    <div class="user-cell-info">
                                                        <h4><%# Eval("GroupName") %></h4>
                                                        <p>Leader: <%# Eval("LeaderName") %></p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><%# Eval("TechName") %></td>
                                            <td style="text-align: right; display: flex; gap: 0.5rem; justify-content: flex-end;">
                                                <asp:Button ID="btnAccept" runat="server" CssClass="btn-primary" Text="Accept" CommandName="Accept" CommandArgument='<%# Eval("GroupId") %>' style="background: var(--c-green);" />
                                                <asp:Button ID="btnReject" runat="server" CssClass="btn-secondary" Text="Reject" CommandName="Reject" CommandArgument='<%# Eval("GroupId") %>' style="background: var(--c-red); color: white; border: none;" />
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="data-section" style="text-align: center; padding: 4rem 2rem;">
                    <i class="fa-solid fa-envelope-open" style="font-size: 3rem; color: var(--c-text-muted); margin-bottom: 1rem;"></i>
                    <h2 style="font-size: 1.5rem; margin-bottom: 0.5rem;">No Pending Invitations</h2>
                    <p style="color: var(--c-text-muted); margin-bottom: 2rem;">You do not have any incoming group invitations from leaders right now.</p>
                </asp:Panel>
            </div>
        </main>
    </form>
	<script src="../../Admin/admin.js"></script>
</body>
</html>


