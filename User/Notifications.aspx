<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="Project_Board.User.Notifications" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>My Notifications - Project Board</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .notification-card {
            background: var(--c-bg-card);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            border: 1px solid var(--c-border);
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            transition: var(--transition);
        }
        .notification-card:hover {
            border-color: var(--c-primary);
            box-shadow: var(--shadow-md);
        }
        .notification-card.unread {
            background: rgba(59, 130, 246, 0.03);
            border-left: 4px solid var(--c-primary);
        }
        .notif-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(59, 130, 246, 0.1);
            color: var(--c-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .notif-content {
            flex: 1;
        }
        .notif-message {
            color: var(--c-text);
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 0.5rem;
        }
        .notif-time {
            color: var(--c-text-muted);
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }
        .notif-actions {
            display: flex;
            align-items: center;
        }
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: var(--c-bg-card);
            border-radius: 12px;
            border: 1px dashed var(--c-border);
        }
        .empty-state i {
            font-size: 3rem;
            color: var(--c-text-muted);
            margin-bottom: 1rem;
            opacity: 0.5;
        }
        .empty-state h3 {
            margin-bottom: 0.5rem;
            color: var(--c-text);
        }
        .empty-state p {
            color: var(--c-text-muted);
        }
    </style>
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
                        <a href='<%= ResolveUrl("~/Default.aspx") %>' class="nav-link"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href='<%= ResolveUrl("~/User/Notifications.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-bell"></i> Notifications
                    </a>
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href='<%= ResolveUrl("~/Logout.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <div class="topbar">
                <div class="search-bar" style="visibility: hidden;">
                    <i class="fa-solid fa-search"></i>
                    <input type="text" placeholder="Search...">
                </div>
                <div class="topbar-actions">
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
            </div>

            <div class="dashboard-container">
                <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
                    <div class="page-title">
                        <h1>Notifications</h1>
                        <p>Stay updated on your project activities and alerts.</p>
                    </div>
                    <asp:LinkButton ID="btnMarkAllRead" runat="server" CssClass="btn-secondary" OnClick="btnMarkAllRead_Click">
                        <i class="fa-solid fa-check-double"></i> Mark all as read
                    </asp:LinkButton>
                </div>
                
                <div class="data-section" style="background: transparent; box-shadow: none; padding: 0;">
                    <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                        <ItemTemplate>
                            <div class='notification-card <%# Convert.ToBoolean(Eval("IsRead")) ? "" : "unread" %>'>
                                <div class="notif-icon">
                                    <i class='fa-solid <%# Convert.ToBoolean(Eval("IsRead")) ? "fa-bell" : "fa-bell-ringing fa-shake" %>'></i>
                                </div>
                                <div class="notif-content">
                                    <div class="notif-message"><%# Eval("Message") %></div>
                                    <div class="notif-time">
                                        <i class="fa-regular fa-clock"></i> 
                                        <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy h:mm tt") %>
                                    </div>
                                </div>
                                <div class="notif-actions">
                                    <asp:LinkButton ID="btnMarkRead" runat="server" CommandName="MarkRead" CommandArgument='<%# Eval("NotificationId") %>' Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>' CssClass="icon-btn" title="Mark as read">
                                        <i class="fa-solid fa-check" style="color: var(--c-green, #22c55e);"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:PlaceHolder ID="phEmpty" runat="server" Visible='<%# rptNotifications.Items.Count == 0 %>'>
                                <div class="empty-state">
                                    <i class="fa-regular fa-bell-slash"></i>
                                    <h3>No notifications yet</h3>
                                    <p>You're all caught up on your alerts.</p>
                                </div>
                            </asp:PlaceHolder>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </main>
    </form>
    
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>
</html>
