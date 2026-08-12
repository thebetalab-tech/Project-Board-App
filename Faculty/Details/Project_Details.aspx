<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Project_Details.aspx.cs"
    Inherits="Project_Board.Faculty.Details.Project_Details" %>

<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Project Details</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link  rel="stylesheet" href="../../Admin/admin.css?v=latest_v3" />
    <style>
        .details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
            font-size: 1.125rem;
            color: var(--c-text);
            font-weight: 500;
            word-break: break-word;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        .full-width p {
            line-height: 1.6;
            color: var(--c-text-muted);
            font-weight: 400;
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

        .tag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }

        .tag {
            background: rgba(59, 130, 246, 0.12);
            color: var(--c-accent, #3b82f6);
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            border: 1px solid rgba(59, 130, 246, 0.3);
        }

        .btn-approve-custom {
            background: #22c55e;
            color: white;
            padding: 0.6rem 1.4rem;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;

        }

        .btn-reject-custom {
            background: #ef4444;
            color: white;
            padding: 0.6rem 1.4rem;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
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
                    <a href='<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/TaskManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-list-check"></i> Tasks
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
                    <div class="avatar">
                        <%= UserInitials %>
                    </div>
                    <div class="user-info">
                        <h4>
                            <%= Session["FullName"] ?? "Faculty Member" %>
                        </h4>
                        <p>
                            <%= Session["Email"] ?? "faculty@example.com" %>
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
            </div>

            <div class="dashboard-container">
                <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Back to Project Management
                </a>
                <div class="page-header">
                    <div class="page-title">
                        <h1>Project Details</h1>
                        <p>Detailed information about the submitted project proposal.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="form-message"></asp:Label>

                <div id="DetailsContainer" runat="server" class="data-section">
                    <div class="section-header">
                        <h2>Overview</h2>
                    </div>

                    <div class="details-grid">
                        <div class="detail-card">
                            <h3>Project Title</h3>
                            <p>
                                <asp:Literal ID="litProjectTitle" runat="server"></asp:Literal>
                            </p>
                        </div>
                        <div class="detail-card">
                            <h3>Group Name</h3>
                            <p>
                                <asp:Literal ID="litGroupName" runat="server"></asp:Literal>
                            </p>
                        </div>
                        <div class="detail-card">
                            <h3>Project Type</h3>
                            <p>
                                <asp:Literal ID="litProjectType" runat="server"></asp:Literal>
                            </p>
                        </div>
                        <div class="detail-card">
                            <h3>Status</h3>
                            <p>
                                <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                            </p>
                        </div>
                        <div class="detail-card">
                            <h3>Submission Date</h3>
                            <p>
                                <asp:Literal ID="litSubmittedAt" runat="server"></asp:Literal>
                            </p>
                        </div>

                        <div class="detail-card full-width">
                            <h3>Functionality & Scope</h3>
                            <p>
                                <asp:Literal ID="litFunctionality" runat="server"></asp:Literal>
                            </p>
                        </div>

                        <div class="detail-card full-width">
                            <h3>Project Keywords (ProjectKeywords Table)</h3>
                            <div class="tag-list">
                                <asp:Repeater ID="rptKeywords" runat="server">
                                    <ItemTemplate>
                                        <span class="tag">
                                            <i class="fa-solid fa-tag" style="margin-right:0.3rem;"></i><%# Eval("Keyword") %>
                                        </span>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# rptKeywords.Items.Count==0
                                            ? "<span style='color:var(--c-text-muted); font-size: 0.875rem;'>No keywords specified.</span>"
                                            : "" %>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </div>

                        <div class="detail-card full-width" style="display:flex; justify-content:flex-end; gap:1rem; background:transparent; border:none; padding:0;">
                            <asp:Button ID="btnApprove" runat="server" Text="Approve Proposal" CssClass="btn-approve-custom" OnClick="btnApprove_Click" />
                            <asp:Button ID="btnReject" runat="server" Text="Reject Proposal" CssClass="btn-reject-custom" OnClick="btnReject_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </form>

    <!-- Mobile toggle script -->
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>

</html>