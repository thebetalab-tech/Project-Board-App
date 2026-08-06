<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Appeal.aspx.cs" Inherits="Project_Board.Student.Appeal" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Appeal - Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .appeal-container {
            width: 100%;
            max-width: 800px;
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

        .btn-back:hover {
            color: var(--c-text);
        }

        .task-card {
            background: var(--c-bg-warm);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .task-card h3 {
            margin: 0 0 0.5rem 0;
            font-size: 1.1rem;
            color: var(--c-accent);
        }

        .task-card p {
            margin: 0;
            color: var(--c-text-muted);
            font-size: 0.9rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--c-text);
        }

        textarea.form-control { resize: vertical; max-width: 100%; }

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

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 1rem;
            background: rgba(5, 150, 105, 0.05);
            border: 1px solid rgba(5, 150, 105, 0.2);
            border-radius: 8px;
            margin-bottom: 2rem;
            cursor: pointer;
        }

        .checkbox-group input[type="checkbox"] {
            width: 1.25rem;
            height: 1.25rem;
            accent-color: var(--c-green);
            cursor: pointer;
        }

        .checkbox-group label {
            margin: 0;
            cursor: pointer;
            font-weight: 600;
            color: var(--c-green);
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

        .btn-submit:hover {
            background-color: var(--c-accent-light);
        }

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .alert-danger {
            background-color: var(--c-red-bg);
            color: var(--c-red);
            border: 1px solid rgba(220, 38, 38, 0.2);
        }
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
                <% } else { %>
                    <a href='<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Team.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Team & Mentor
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Project.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Project Details
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_TaskManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> My Tasks
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
                        <a href="<%= ResolveUrl("~/User/Notifications.aspx") %>" class="notification-btn" title="Notifications">
                            <i class="fa-regular fa-bell"></i>
                            <span class="notification-badge">0</span>
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
            <div class="appeal-container">
                <div class="header">
                    <h1><i class="fa-solid fa-file-signature"></i> Submit Appeal</h1>
                    <asp:LinkButton ID="btnBack" runat="server" CssClass="btn-back" OnClick="btnBack_Click"><i class="fa-solid fa-arrow-left"></i> Back to Dashboard</asp:LinkButton>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

                <div class="task-card">
                    <h3><asp:Label ID="lblTaskTitle" runat="server"></asp:Label></h3>
                    <p>Assigned By: <strong><asp:Label ID="lblAssignorName" runat="server"></asp:Label></strong></p>
                    <div style="margin-top: 1rem;">
                        <strong style="color:var(--c-text); font-size:0.85rem; display:block; margin-bottom:0.25rem;">Feedback / Requirements:</strong>
                        <p><asp:Label ID="lblFeedback" runat="server"></asp:Label></p>
                    </div>
                </div>

                <div class="form-group">
                    <label>Appeal Message / Reason <span style="color:var(--c-red);">*</span></label>
                    <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" Placeholder="Why are you submitting this appeal? Provide a brief summary of the status..."></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>What Changes Have You Made?</label>
                    <asp:TextBox ID="txtChangesMade" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" Placeholder="List the exact code, design, or logic changes you made for this task..."></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Detailed Explanation</label>
                    <asp:TextBox ID="txtExplanation" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" Placeholder="Explain your approach, any blockers you faced, and how you solved them..."></asp:TextBox>
                </div>

                <div class="checkbox-group">
                    <asp:CheckBox ID="chkIsCompleted" runat="server" />
                    <label for="chkIsCompleted">Mark Task as Actually Completed</label>
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="Submit Appeal" CssClass="btn-submit" OnClick="btnSubmit_Click" />
            </div>
        </div>
    </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>
</html>
