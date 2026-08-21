<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JoinGroup.aspx.cs" Inherits="Project_Board.JoinGroup" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join a Group — Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Admin/admin.css?v=latest_v3" />
    <style>
        .group-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.25rem;
            transition: all 0.2s;
        }

        .group-card:hover {
            box-shadow: var(--shadow-sm);
            border-color: var(--c-accent);
        }

        .group-header {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .group-avatar {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: rgba(59, 130, 246, 0.1);
            color: var(--c-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        .group-info {
            flex: 1;
        }

        .group-info h3 {
            margin: 0 0 0.25rem 0;
            font-size: 1.1rem;
            color: var(--c-text);
        }

        .group-info p {
            margin: 0;
            color: var(--c-text-muted);
            font-size: 0.875rem;
        }

        .group-tech {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.35rem 0.75rem;
            background: rgba(59, 130, 246, 0.1);
            color: var(--c-primary);
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .btn-request {
            padding: 0.6rem 1.25rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.875rem;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
        }

        .btn-primary {
            background: var(--c-accent);
            color: white;
        }

        .btn-primary:hover {
            background: var(--c-accent-dark);
        }

        .btn-secondary {
            background: var(--c-bg-muted);
            color: var(--c-text-muted);
            cursor: not-allowed;
        }

        .no-groups {
            text-align: center;
            padding: 3rem 1rem;
            color: var(--c-text-muted);
        }

        .no-groups i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: var(--c-text-dim);
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2 class="sidebar-title">Project Board</h2>
                <button type="button" id="sidebarToggle" class="sidebar-toggle-btn" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href='<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/JoinGroup.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Join Group
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/MyRequests.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-file-circle-check"></i> My Requests
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_TaskManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-list-check"></i> My Tasks
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href='<%= ResolveUrl("~/Logout.aspx") %>' class="nav-link">
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
            <header class="topbar">
                <div class="topbar-left">
                    <h1 class="topbar-page-title">Join a Group</h1>
                </div>
                <div class="topbar-actions">
                    <a href="<%= ResolveUrl("~/User/Notifications.aspx") %>" class="notification-btn" title="Notifications">
                        <i class="fa-regular fa-bell"></i>
                        <span class="notification-badge"><%= Project_Board.Utils.NotificationHelper.GetUnreadCount(Session["UserId"]) %></span>
                    </a>
                    <div class="profile-menu-container">
                        <div class="profile-trigger">
                            <div class="avatar"><%= Session["FullName"] != null ? Session["FullName"].ToString().Substring(0,1).ToUpper() : "U" %></div>
                            <div class="profile-greeting">
                                <span>Hi,</span> <%= Session["FullName"] ?? "User" %>
                            </div>
                            <i class="fa-solid fa-chevron-down profile-arrow"></i>
                        </div>
                        <div class="profile-dropdown">
                            <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-regular fa-user"></i> My Profile</a>
                            <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-solid fa-key"></i> Change Password</a>
                            <a href="<%= ResolveUrl("~/Logout.aspx") %>"><i class="fa-solid fa-lock"></i> Log Out</a>
                        </div>
                    </div>
                </div>
            </header>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Browse Available Groups</h1>
                        <p>Find a group that fits your technology domain and request to join.</p>
                    </div>
                </div>

                <!-- Success/Error Messages -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" style="margin-bottom:1.5rem; padding:1rem; border-radius:8px;">
                    <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                </asp:Panel>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Forming Teams</h2>
                    </div>

                    <!-- Technology Filter -->
                    <div class="filter-section" style="margin-bottom:1.5rem; display:flex; gap:1rem; align-items:flex-end; flex-wrap:wrap;">
                        <div class="form-group" style="flex:1; min-width:200px;">
                            <label style="display:block; font-size:0.75rem; font-weight:600; text-transform:uppercase; margin-bottom:0.5rem; color:var(--c-text-dim);">Filter by Technology</label>
                            <asp:DropDownList ID="ddlTechnology" runat="server" CssClass="form-control" style="width:100%; padding:0.65rem; border-radius:8px; border:1px solid var(--c-border);" AutoPostBack="true" OnSelectedIndexChanged="ddlTechnology_SelectedIndexChanged">
                                <asp:ListItem Text="All Technologies" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <asp:Button ID="btnClearFilter" runat="server" Text="Clear Filter" CssClass="btn-secondary" OnClick="btnClearFilter_Click" Style="padding:0.65rem 1.25rem; border-radius:8px;" />
                    </div>

                    <div id="groupsList" runat="server">
                        <asp:Repeater ID="rptAvailableGroups" runat="server" OnItemCommand="rptAvailableGroups_ItemCommand">
                            <ItemTemplate>
                                <div class="group-card">
                                    <div class="group-header">
                                        <div class="group-avatar">
                                            <i class="fa-solid fa-users"></i>
                                        </div>
                                        <div class="group-info">
                                            <h3><%# Eval("GroupName") %></h3>
                                            <p><i class="fa-solid fa-user-tie"></i> Leader: <%# Eval("LeaderName") %></p>
                                        </div>
                                        <span class="group-tech"><i class="fa-solid fa-microchip"></i> <%# Eval("TechName") %></span>
                                    </div>
                                    <div style="text-align: right;">
                                        <asp:Button ID="btnRequest" runat="server"
                                            CssClass='btn-request <%# Convert.ToInt32(Eval("HasRequested")) > 0 ? "btn-secondary" : "btn-primary" %>'
                                            Text='<%# Convert.ToInt32(Eval("HasRequested")) > 0 ? "Requested" : "Request to Join" %>'
                                            CommandName="RequestJoin"
                                            CommandArgument='<%# Eval("GroupId") %>'
                                            Enabled='<%# Convert.ToInt32(Eval("HasRequested")) == 0 %>' />
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <%# rptAvailableGroups.Items.Count == 0 ? "<div class='no-groups'><i class='fa-solid fa-users-slash'></i><h3>No groups available</h3><p>There are currently no groups accepting new members. Check back later!</p></div>" : "" %>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </main>
        <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v7") %>'></script>
    </form>
</body>

</html>
