<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvitationManager.aspx.cs" Inherits="Project_Board.Student.Member.InvitationManager" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - Invitations</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200793429432375" />
    <style>
        .invitation-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.25rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .invitation-info h4 {
            margin: 0 0 0.3rem 0;
            font-size: 1.1rem;
            color: var(--c-text);
        }

        .invitation-info p {
            margin: 0;
            font-size: 0.85rem;
            color: var(--c-text-dim);
        }

        .btn-accept {
            background-color: var(--c-accent);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            text-decoration: none;
            margin-right: 0.5rem;
        }

        .btn-reject {
            background-color: rgba(239, 68, 68, 0.15);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            text-decoration: none;
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
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Project.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Project Details
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>' class="nav-link active">
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
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="action-btn" title="Profile">
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

                <!-- EMPTY INVITATIONS STATE -->
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="stat-card" style="padding: 3rem 1.5rem; text-align: center;">
                    <i class="fa-solid fa-envelope-open" style="font-size: 3rem; color: var(--c-text-dim); margin-bottom: 1rem; display: block;"></i>
                    <h2 style="margin-bottom: 0.5rem;">No Pending Invitations</h2>
                    <p style="color: var(--c-text-dim);">You do not have any incoming group invitations from leaders right now.</p>
                </asp:Panel>

                <!-- INVITATIONS LIST -->
                <asp:Panel ID="pnlInvitations" runat="server" Visible="false">
                    <asp:Repeater ID="rptInvitations" runat="server" OnItemCommand="rptInvitations_ItemCommand">
                        <ItemTemplate>
                            <div class="invitation-card">
                                <div class="invitation-info">
                                    <h4><i class="fa-solid fa-users" style="color:var(--c-accent); margin-right:0.4rem;"></i> <%# Eval("GroupName") %></h4>
                                    <p>Invited by Leader: <strong><%# Eval("LeaderName") %></strong> | Technology: <%# Eval("TechName") != DBNull.Value ? Eval("TechName") : "General" %></p>
                                </div>
                                <div>
                                    <asp:Button ID="btnAccept" runat="server" CommandName="Accept" CommandArgument='<%# Eval("GroupId") %>' Text="Accept Invitation" CssClass="btn-accept" />
                                    <asp:Button ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("GroupId") %>' Text="Decline" CssClass="btn-reject" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>

</html>