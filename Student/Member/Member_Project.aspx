<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Member_Project.aspx.cs" Inherits="Project_Board.Student.Member.Member_Project" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - Project Details</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../../Admin/admin.css?v=latest_v3" />
    <style>
        .badge-status {
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-success, .status-approved { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
        .badge-warning, .status-pending { background: rgba(234, 179, 8, 0.15); color: #eab308; }
        .badge-danger, .status-rejected { background: rgba(239, 68, 68, 0.15); color: #ef4444; }

        .tag-pill {
            display: inline-block;
            background: rgba(59, 130, 246, 0.12);
            color: var(--c-accent, #3b82f6);
            border: 1px solid rgba(59, 130, 246, 0.3);
            padding: 0.2rem 0.6rem;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 500;
            margin-right: 0.3rem;
            margin-bottom: 0.3rem;
        }

        .proposal-card {
            background: var(--c-surface, #ffffff);
            border: 1px solid var(--c-border, #e2e8f0);
            border-radius: 12px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }

        .proposal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--c-border);
            padding-bottom: 0.75rem;
            margin-bottom: 0.75rem;
        }

        .proposal-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--c-text);
        }
    </style>
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
                    <a href='<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Team.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Team & Mentor
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Project.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-folder-open"></i> Project Details
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
                        <h4><%= UserName %></h4>
                        <p><%= UserEmail %></p>
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
                <div class="page-header">
                    <div class="page-title">
                        <h1>Team Project Proposals</h1>
                        <p>View your team's project proposals and approval status.</p>
                    </div>
                </div>

                <!-- UNASSIGNED / NO PROJECT PANEL -->
                <asp:Panel ID="pnlNoProject" runat="server" CssClass="stat-card" style="padding:2.5rem; text-align:center;">
                    <i class="fa-solid fa-folder-minus" style="font-size:3rem; color:var(--c-text-dim); margin-bottom:1rem; display:block;"></i>
                    <h2 style="margin-bottom:0.5rem;">No Project Proposal Submitted Yet</h2>
                    <p style="color:var(--c-text-dim);">Your Team Leader has not submitted a project proposal for faculty review yet.</p>
                </asp:Panel>

                <!-- PROJECT DETAILS PANEL -->
                <asp:Panel ID="pnlProjectDetails" runat="server" Visible="false">
                    <div style="margin-bottom:1.5rem;">
                        <h3 style="color:var(--c-text-dim); font-size:0.9rem; text-transform:uppercase; letter-spacing:0.05em;">Group Name</h3>
                        <p style="font-size:1.4rem; font-weight:700; color:var(--c-text);"><asp:Label ID="lblGroupName" runat="server"></asp:Label></p>
                    </div>

                    <asp:Repeater ID="rptMemberProposals" runat="server">
                        <ItemTemplate>
                            <div class="proposal-card">
                                <div class="proposal-header">
                                    <div>
                                        <span class="proposal-title"><%# Eval("ProjectTitle") %></span>
                                        <span class="badge-status badge-info" style="margin-left:0.5rem; background:rgba(99,102,241,0.15); color:#6366f1;">
                                            <%# Eval("ProjectType") %>
                                        </span>
                                    </div>
                                    <div>
                                        <span class='badge-status status-<%# Eval("Status").ToString().ToLower() %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                    </div>
                                </div>

                                <%# !string.IsNullOrWhiteSpace(Eval("Keywords")?.ToString()) ? "<div style='margin-bottom:0.75rem;'>" + string.Join("", Eval("Keywords").ToString().Split(',').Select(k => "<span class=\"tag-pill\"><i class=\"fa-solid fa-tag\" style=\"font-size:0.7rem; margin-right:0.3rem;\"></i>" + k.Trim() + "</span>")) + "</div>" : "" %>

                                <div style="font-size:0.9rem; color:var(--c-text); background:var(--c-bg); padding:0.8rem; border-radius:8px; border:1px solid var(--c-border); line-height:1.5;">
                                    <%# Eval("Functionality") %>
                                </div>

                                <div style="font-size:0.78rem; color:var(--c-text-dim); margin-top:0.75rem;">
                                    Submitted on: <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("MMM dd, yyyy hh:mm tt") %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>

</html>
