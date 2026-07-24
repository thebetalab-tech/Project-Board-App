<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Members.aspx.cs"
    Inherits="Project_Board.Student.Leader.Leader_Members" %>
    <!DOCTYPE html>
    <html lang="en">

    <head runat="server">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Leader Dashboard — Team Members</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200793429339939" />
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
                        <a href="<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>" class="nav-link active">
                            <i class="fa-solid fa-users"></i> Team Members
                        </a>
                        <a href="<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>" class="nav-link">
                            <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                        </a>
                        <a href="<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>" class="nav-link">
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
                        <div class="avatar">
                            <%= UserInitials %>
                        </div>
                        <div class="user-info">
                            <h4>
                                <%= Session["FullName"] ?? "Student Leader" %>
                            </h4>
                            <p>
                                <%= Session["Email"] ?? "leader@example.com" %>
                            </p>
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
                        <div class="status-badge-container"
                            style="background: var(--c-bg-elevated); padding: 0.5rem 1rem; border-radius: 20px; display: flex; align-items: center; gap: 0.5rem; font-weight: 500; font-size: 0.875rem;">
                            <span class="status-dot"
                                style='<%= MemberNeeded ? "width: 8px; height: 8px; border-radius: 50%; display: inline-block; background: var(--c-blue);" : "width: 8px; height: 8px; border-radius: 50%; display: inline-block; background: var(--c-green);" %>'></span>
                            <%= MemberNeeded ? "Team Forming" : "Team Completed" %>
                        </div>
                        <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="action-btn" title="Profile">
                            <i class="fa-solid fa-user"></i>
                        </a>
                    </div>
                </div>

                <div class="dashboard-container">
                    <div class="page-header">
                        <div class="page-title">
                            <h1>Team Members</h1>
                            <p>Manage your group members and send invitations.</p>
                        </div>
                        <div>
                            <asp:Button ID="btnToggleStatus" runat="server" CssClass="btn-primary"
                                OnClick="btnToggleStatus_Click" />
                        </div>
                    </div>

                    <div class="data-section">
                        <div class="section-header">
                            <h2>Active Members</h2>
                        </div>
                        <div class="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Member ID</th>
                                        <th>Member Name</th>
                                        <th>Enrollment No.</th>
                                        <th>Email</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptGroups" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong>
                                                        <%# Eval("UserId") %>
                                                    </strong></td>
                                                <td>
                                                    <%# Eval("FullName") %>
                                                </td>
                                                <td>
                                                    <%# Eval("EnrollmentNo") %>
                                                </td>
                                                <td>
                                                    <%# Eval("Email") %>
                                                </td>
                                                <td>
                                                    <span
                                                        class='badge status-<%# Eval("JoinStatus").ToString().ToLower() %>'>
                                                        <%# Eval("JoinStatus") %>
                                                    </span>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <asp:Panel ID="pnlInviteSection" runat="server" CssClass="data-section">
                        <div class="section-header">
                            <h2>Invite New Members</h2>
                        </div>
                        <div class="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Student Details</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptEligible" runat="server"
                                        OnItemCommand="rptEligible_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <div class="user-cell">
                                                        <div class="user-cell-avatar"><i class="fa-solid fa-user"
                                                                style="color: var(--c-text-muted);"></i></div>
                                                        <div class="user-cell-info">
                                                            <h4>
                                                                <%# Eval("FullName") %>
                                                            </h4>
                                                            <p>
                                                                <%# Eval("Email") %> | <%# Eval("EnrollmentNo") %>
                                                            </p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td style="text-align: right;">
                                                    <asp:Button ID="btnInvite" runat="server" CssClass="btn-secondary"
                                                        Text="Invite" CommandName="Invite"
                                                        CommandArgument='<%# Eval("UserId") %>' />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </asp:Panel>
                </div>
            </main>
        </form>
        <script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
    </body>

    </html>