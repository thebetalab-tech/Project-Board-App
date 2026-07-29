<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Project.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Project" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader - Project Management</title>
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

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }

        .form-group label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--c-text);
        }

        .form-control {
            background: var(--c-bg);
            border: 1px solid var(--c-border);
            color: var(--c-text);
            padding: 0.6rem 0.8rem;
            border-radius: 8px;
            font-family: inherit;
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
                    <a href='<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Project.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-folder-open"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_TaskManagement.aspx") %>' class="nav-link">
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
                        <h1>Group Project Management</h1>
                        <p>Submit and manage your group's project proposal for faculty approval.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; margin-bottom:1rem;"></asp:Label>

                <!-- EXISTING PROJECT DISPLAY PANEL -->
                <asp:Panel ID="pnlExistingProject" runat="server" CssClass="stat-card" style="margin-bottom:1.5rem;" Visible="false">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--c-border); padding-bottom:0.75rem; margin-bottom:1rem;">
                        <h3><i class="fa-solid fa-folder-check" style="color:var(--c-accent); margin-right:0.5rem;"></i> Current Submitted Project Proposal</h3>
                        <span class="badge-status badge-warning"><asp:Label ID="lblProjectStatus" runat="server"></asp:Label></span>
                    </div>

                    <div class="form-grid">
                        <div>
                            <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Project Title</label>
                            <p style="font-size:1.1rem; font-weight:600; color:var(--c-text); margin-top:0.2rem;"><asp:Label ID="lblProjectTitle" runat="server"></asp:Label></p>
                        </div>
                        <div>
                            <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Project Type</label>
                            <p style="font-size:1.1rem; font-weight:600; color:var(--c-text); margin-top:0.2rem;"><asp:Label ID="lblProjectType" runat="server"></asp:Label></p>
                        </div>
                    </div>

                    <div style="margin-top:1rem;">
                        <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Project Functionality & Description</label>
                        <p style="color:var(--c-text); background:var(--c-bg); padding:0.8rem; border-radius:8px; border:1px solid var(--c-border); margin-top:0.3rem;"><asp:Label ID="lblFunctionality" runat="server"></asp:Label></p>
                    </div>

                    <div style="font-size:0.8rem; color:var(--c-text-dim); margin-top:0.8rem;">
                        Submitted on: <asp:Label ID="lblSubmittedAt" runat="server"></asp:Label>
                    </div>
                </asp:Panel>

                <!-- PROJECT SUBMISSION / EDIT FORM -->
                <div class="stat-card">
                    <h3><i class="fa-solid fa-pen-to-square" style="color:var(--c-accent); margin-right:0.5rem;"></i> Submit / Edit Project Proposal</h3>
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label>Project Title</label>
                            <asp:TextBox ID="txtProjectTitle" runat="server" CssClass="form-control" placeholder="Enter project title..."></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Project Type</label>
                            <asp:DropDownList ID="ddlProjectType" runat="server" CssClass="form-control">
                                <asp:ListItem Text="UDP (User Defined Project)" Value="UDP"></asp:ListItem>
                                <asp:ListItem Text="IDP (Industry Defined Project)" Value="IDP"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Key Functionalities & Overview</label>
                            <asp:TextBox ID="txtFunctionality" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control" placeholder="Describe main features, functionalities, and scope of your project..."></asp:TextBox>
                        </div>
                    </div>
                    <div style="margin-top:1rem; text-align:right;">
                        <asp:Button ID="btnSubmitProject" runat="server" Text="Submit Project Proposal" CssClass="btn-primary" OnClick="btnSubmitProject_Click" />
                    </div>
                </div>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>

</html>
