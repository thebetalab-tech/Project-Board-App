<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Group_Details.aspx.cs" Inherits="Project_Board.Faculty.Details.Group_Details" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Group Details</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link  rel="stylesheet" href="../../Admin/admin.css?v=latest_v3" />
    <style>
        .details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .detail-card {
            background: var(--c-surface);
            border: 1px solid var(--c-border);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow-sm);
        }
        .detail-card h3 {
            font-size: 0.875rem;
            color: var(--c-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.5rem;
        }
        .detail-card p {
            font-size: 1.25rem;
            color: var(--c-text);
            font-weight: 500;
            word-break: break-word;
        }
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--c-text-muted);
            text-decoration: none;
            margin-bottom: 1.5rem;
            font-weight: 500;
            transition: color 0.2s;
        }
        .back-link:hover {
            color: var(--c-primary);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo-icon"><i class="fa-solid fa-graduation-cap" style="color: white;"></i></div>
                <h2 class="sidebar-title">Project Board</h2>
                <button type="button" id="sidebarToggle" class="sidebar-toggle-btn" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href='<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> <span>Dashboard</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/Analysis.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-line"></i> <span>Analysis & Reports</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-users-gear"></i> <span>Group Management</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> <span>Project Management</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> <span>Mentor Requests</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/TaskManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-list-check"></i> <span>Tasks</span>
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-user"></i> <span>Profile</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Logout.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> <span>Logout</span>
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
                                <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-solid fa-key"></i> <span>Change Password</span></a>
                                <a href="<%= ResolveUrl("~/Logout.aspx") %>"><i class="fa-solid fa-lock"></i> <span>Log Out</span></a>
                            </div>
                        </div>
                    </div>
            </div>

            <div class="dashboard-container">
                <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> <span>Back to Group Management</span>
                </a>
                <div class="page-header">
                    <div class="page-title">
                        <h1>Group Details</h1>
                        <p>Detailed information about the group and its members.</p>
                    </div>
                </div>
                
                <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="form-message"></asp:Label>

                <div id="DetailsContainer" runat="server" class="data-section">
                    <div class="section-header">
                        <h2>Overview</h2>
                    </div>
                    
                    <div class="details-grid">
                        <div class="detail-card">
                            <h3>Group Name</h3>
                            <p><asp:Literal ID="litGroupName" runat="server"></asp:Literal></p>
                        </div>
                        <div class="detail-card">
                            <h3>Leader Name</h3>
                            <p><asp:Literal ID="litLeaderName" runat="server"></asp:Literal></p>
                        </div>
                        <div class="detail-card">
                            <h3>Technology</h3>
                            <p><span class="badge status-forming"><asp:Literal ID="litTechnology" runat="server"></asp:Literal></span></p>
                        </div>
                        <div class="detail-card">
                            <h3>Status</h3>
                            <p><span class="badge status-active"><asp:Literal ID="litStatus" runat="server"></asp:Literal></span></p>
                        </div>
                    </div>

                    <div class="section-header" style="margin-top: 3rem;">
                        <h2>Group Members</h2>
                    </div>

                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Enrollment No.</th>
                                    <th>Role</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptMembers" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("FullName") %></strong></td>
                                            <td><%# Eval("Email") %></td>
                                            <td><%# Eval("EnrollmentNo") %></td>
                                            <td>
                                                <%# Convert.ToBoolean(Eval("IsLeader")) ? "<span class='badge status-approved'>Leader</span>" : "Member" %>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# rptMembers.Items.Count == 0 ? "<tr><td colspan='4' style='text-align:center; padding: 2rem; color: var(--c-text-muted);'>No members found.</td></tr>" : "" %>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </form>
    
    <!-- Mobile toggle script -->
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>
</html>
