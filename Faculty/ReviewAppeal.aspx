<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReviewAppeal.aspx.cs" Inherits="Project_Board.Faculty.ReviewAppeal" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Appeal - Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../Admin/admin.css" />
    <style>
        .appeal-container {
            width: 100%;
            max-width: 900px;
            background: var(--c-bg);
            border-radius: 16px;
            box-shadow: var(--shadow-md);
            padding: 2.5rem;
            border: 1px solid var(--c-border);
            margin: 0 auto;
        }

        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--c-border);
        }

        .header h1 {
            margin: 0;
            font-size: 1.5rem;
            color: var(--c-text);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .btn-back {
            color: var(--c-text-muted);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: color 0.2s;
        }

        .btn-back:hover { color: var(--c-text); }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .info-card {
            background: var(--c-bg-warm);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
        }

        .info-card h3 {
            margin: 0 0 0.5rem 0;
            font-size: 1.1rem;
            color: var(--c-accent);
        }

        .info-card p {
            margin: 0 0 0.5rem 0;
            color: var(--c-text);
            font-size: 0.9rem;
        }

        .report-section {
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .report-section h4 {
            margin: 0 0 1rem 0;
            font-size: 1.1rem;
            color: var(--c-text);
            border-bottom: 1px solid var(--c-border);
            padding-bottom: 0.5rem;
        }

        .report-box {
            background-color: var(--c-surface);
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            white-space: pre-wrap;
            font-size: 0.9rem;
            line-height: 1.6;
        }

        .form-group { margin-bottom: 1.5rem; }

        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--c-text);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            border: 1px solid var(--c-border);
            font-family: inherit;
            font-size: 0.95rem;
            transition: all 0.2s;
            box-sizing: border-box;
            background: var(--c-bg);
            color: var(--c-text);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--c-accent);
            box-shadow: 0 0 0 3px var(--c-accent-glow);
        }

        .btn-submit {
            background-color: var(--c-accent);
            color: white;
            border: none;
            padding: 0.875rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            width: 100%;
            justify-content: center;
        }

        .btn-submit:hover { background-color: var(--c-accent-hover); }

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .alert-success { background-color: #ecfdf5; color: #059669; border: 1px solid rgba(5,150,105,0.2); }
        .alert-danger { background-color: var(--c-red-bg); color: var(--c-red); border: 1px solid rgba(220,38,38,0.2); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <% string currentRole = (Session["Role"] ?? Session["UserRole"])?.ToString() ?? ""; %>
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon"><i class="fa-solid fa-graduation-cap" style="color: white;"></i></div>
            <h2>Project Board</h2>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <% if (currentRole == "Leader") { %>
                    <a href='<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Project.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_TaskManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> Tasks
                    </a>
                <% } else if (currentRole == "Faculty") { %>
                    <a href='<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users-rectangle"></i> Managed Groups
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-diagram-project"></i> Project Approvals
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope-open-text"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Admin/Mentor_TaskManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> Task Reviews
                    </a>
                <% } else { %>
                    <a href='<%= ResolveUrl("~/Admin/Admin_Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href='<%= ResolveUrl("~/Admin/Admin_UserManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> User Management
                    </a>
                    <a href='<%= ResolveUrl("~/Admin/Admin_GroupsManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Group Management
                    </a>
                    <a href='<%= ResolveUrl("~/Admin/Admin_ProjectsManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Admin/Admin_TechManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-microchip"></i> Technology Stack
                    </a>
                    <a href='<%= ResolveUrl("~/Admin/Admin_TaskManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> Task Reviews
                    </a>
                <% } %>
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
                <div class="avatar"><%= (Session["FullName"]?.ToString() ?? "U").Substring(0, 1).ToUpper() %></div>
                <div class="user-info">
                    <h4><%= Session["FullName"]?.ToString() ?? "User" %></h4>
                    <p><%= Session["Email"]?.ToString() ?? "user@example.com" %></p>
                </div>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <header class="topbar">
            <div class="search-bar" style="visibility: hidden;">
                <i class="fa-solid fa-search"></i>
                <input type="text" placeholder="Search...">
            </div>
            <div class="topbar-actions">
                <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="action-btn" title="Profile">
                    <i class="fa-solid fa-user"></i>
                </a>
            </div>
        </header>
        <div class="dashboard-container">
            <div class="appeal-container">
                <div class="header">
                    <h1><i class="fa-solid fa-check-to-slot"></i> Review Appeal</h1>
                    <asp:LinkButton ID="btnBack" runat="server" CssClass="btn-back" OnClick="btnBack_Click"><i class="fa-solid fa-arrow-left"></i> Back to Dashboard</asp:LinkButton>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

                <div class="info-grid">
                    <div class="info-card">
                        <h3>Task Information</h3>
                        <p><strong>Title:</strong> <asp:Label ID="lblTaskTitle" runat="server"></asp:Label></p>
                        <p><strong>Group:</strong> <asp:Label ID="lblGroupName" runat="server"></asp:Label></p>
                        <p><strong>Status:</strong> <asp:Label ID="lblStatus" runat="server"></asp:Label></p>
                        <p style="margin-top: 1rem; font-size: 0.85rem; color: var(--c-text-muted);"><asp:Label ID="lblTaskDescription" runat="server"></asp:Label></p>
                    </div>
                    
                    <div class="info-card">
                        <h3>Requirements / Feedback Given</h3>
                        <p style="font-size: 0.85rem; color: var(--c-text-muted);"><asp:Label ID="lblRequirements" runat="server"></asp:Label></p>
                    </div>
                </div>

                <asp:Panel ID="pnlAppeal" runat="server" CssClass="report-section">
                    <h4><i class="fa-solid fa-user-graduate" style="color:var(--c-accent); margin-right:0.5rem;"></i> Student Appeal & Report</h4>
                    
                    <strong>Message / Reason:</strong>
                    <div class="report-box"><asp:Label ID="lblReason" runat="server"></asp:Label></div>
                    
                    <strong>Changes Made:</strong>
                    <div class="report-box"><asp:Label ID="lblChangesMade" runat="server"></asp:Label></div>
                    
                    <strong>Explanation:</strong>
                    <div class="report-box"><asp:Label ID="lblExplanation" runat="server"></asp:Label></div>

                    <div style="font-weight: 600; margin-top: 1rem;">
                        <asp:Label ID="lblIsCompleted" runat="server"></asp:Label>
                    </div>
                    <div style="font-size: 0.8rem; color: var(--c-text-muted); margin-top: 0.5rem;">
                        Submitted at: <asp:Label ID="lblCreatedAt" runat="server"></asp:Label>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlNoAppeal" runat="server" CssClass="report-section" Visible="false">
                    <p style="text-align:center; color:var(--c-text-muted); font-style:italic;">No appeal has been submitted for this task.</p>
                </asp:Panel>

                <div style="border-top: 1px solid var(--c-border); padding-top: 2rem;">
                    <h4 style="margin: 0 0 1.5rem 0; font-size: 1.1rem;"><i class="fa-solid fa-gavel" style="color:var(--c-accent); margin-right:0.5rem;"></i> Your Decision</h4>
                    
                    <div class="form-group">
                        <label>Update Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Text="Working" Value="Working"></asp:ListItem>
                            <asp:ListItem Text="Appealed" Value="Appealed"></asp:ListItem>
                            <asp:ListItem Text="Completed" Value="Completed"></asp:ListItem>
                            <asp:ListItem Text="Revision Needed" Value="Revision Needed"></asp:ListItem>
                            <asp:ListItem Text="Failed" Value="Failed"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label>Feedback / Remarks</label>
                        <asp:TextBox ID="txtFeedback" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" Placeholder="Provide instructions for revision or remarks upon completion..."></asp:TextBox>
                    </div>

                    <asp:Button ID="btnSubmitDecision" runat="server" Text="Save Decision & Feedback" CssClass="btn-submit" OnClick="btnSubmitDecision_Click" />
                </div>
            </div>
        </div>
    </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>
</html>
