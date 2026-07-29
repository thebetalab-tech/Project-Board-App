<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Member_Project.aspx.cs" Inherits="Project_Board.Student.Member.Member_Project" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - Project Details</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200793428857004" />
    <style>
        .badge-status {
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-success { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
        .badge-warning { background: rgba(234, 179, 8, 0.15); color: #eab308; }
        .badge-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
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
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Team Project Details</h1>
                        <p>View your team's project proposal and approval status.</p>
                    </div>
                </div>

                <!-- UNASSIGNED / NO PROJECT PANEL -->
                <asp:Panel ID="pnlNoProject" runat="server" CssClass="stat-card" style="padding:2rem; text-align:center;">
                    <i class="fa-solid fa-folder-minus" style="font-size:3rem; color:var(--c-text-dim); margin-bottom:1rem; display:block;"></i>
                    <h2 style="margin-bottom:0.5rem;">No Project Proposal Submitted Yet</h2>
                    <p style="color:var(--c-text-dim);">Your Team Leader has not submitted a project proposal for faculty approval yet.</p>
                </asp:Panel>

                <!-- PROJECT DETAILS PANEL -->
                <asp:Panel ID="pnlProjectDetails" runat="server" CssClass="stat-card" Visible="false">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--c-border); padding-bottom:0.75rem; margin-bottom:1rem;">
                        <h3><i class="fa-solid fa-folder-check" style="color:var(--c-accent); margin-right:0.5rem;"></i> Group Project Overview</h3>
                        <span class="badge-status badge-warning"><asp:Label ID="lblProjectStatus" runat="server"></asp:Label></span>
                    </div>

                    <div class="form-grid">
                        <div>
                            <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Project Title</label>
                            <p style="font-size:1.1rem; font-weight:600; color:var(--c-text); margin-top:0.2rem;"><asp:Label ID="lblProjectTitle" runat="server"></asp:Label></p>
                        </div>
                        <div>
                            <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Group Name</label>
                            <p style="font-size:1.1rem; font-weight:600; color:var(--c-text); margin-top:0.2rem;"><asp:Label ID="lblGroupName" runat="server"></asp:Label></p>
                        </div>
                        <div>
                            <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Project Type</label>
                            <p style="font-size:1rem; font-weight:600; color:var(--c-text); margin-top:0.2rem;"><asp:Label ID="lblProjectType" runat="server"></asp:Label></p>
                        </div>
                        <div>
                            <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Submission Date</label>
                            <p style="font-size:1rem; font-weight:500; color:var(--c-text); margin-top:0.2rem;"><asp:Label ID="lblSubmittedAt" runat="server"></asp:Label></p>
                        </div>
                    </div>

                    <div style="margin-top:1.25rem;">
                        <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Project Functionalities & Features</label>
                        <p style="color:var(--c-text); background:var(--c-bg); padding:0.8rem; border-radius:8px; border:1px solid var(--c-border); margin-top:0.3rem;"><asp:Label ID="lblFunctionality" runat="server"></asp:Label></p>
                    </div>
                </asp:Panel>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>

</html>
