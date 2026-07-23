<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Group_Details.aspx.cs" Inherits="Project_Board.Faculty.Details.Group_Details" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Group Details</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css" />
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
                <h2>Project Board</h2>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href="<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="<%= ResolveUrl("~/Logout.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
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
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <a href="<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>" class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Back to Group Management
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
    <script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
</body>
</html>
