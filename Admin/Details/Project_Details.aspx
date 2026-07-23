<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Project_Details.aspx.cs" Inherits="Project_Board.Admin.Details.Project_Details" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Project Details</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link rel="stylesheet" href="../../Admin/admin.css">
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
            background: var(--c-surface-hover);
            color: var(--c-text);
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            border: 1px solid var(--c-border);
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
                    <a href="../Admin_Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="../Admin_UserManagement.aspx" class="nav-link">
                        <i class="fa-solid fa-users"></i> Users Management
                    </a>
                    <a href="../Admin_GroupsManagement.aspx" class="nav-link">
                        <i class="fa-solid fa-user-group"></i> Groups
                    </a>
                    <a href="../Admin_ProjectsManagement.aspx" class="nav-link active">
                        <i class="fa-solid fa-folder-open"></i> Projects
                    </a>
                    <a href="../Admin_TechManagement.aspx" class="nav-link">
                        <i class="fa-solid fa-microchip"></i> Technologies
                    </a>
                </div>

                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href="../../User/Profile.aspx" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="../../Logout.aspx" class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="avatar"><%= UserInitials %></div>
                <div class="user-info">
                    <h4><%= Session["FullName"] ?? "Administrator" %></h4>
                    <p><%= Session["Email"] ?? "admin@example.com" %></p>
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
                    <a href="../../User/Profile.aspx" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <a href="../Admin_ProjectsManagement.aspx" class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Back to Project Management
                </a>
                <div class="page-header">
                    <div class="page-title">
                        <h1>Project Details</h1>
                        <p>Detailed information about the submitted project.</p>
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
                            <p><asp:Literal ID="litProjectTitle" runat="server"></asp:Literal></p>
                        </div>
                        <div class="detail-card">
                            <h3>Group Name</h3>
                            <p><asp:Literal ID="litGroupName" runat="server"></asp:Literal></p>
                        </div>
                        <div class="detail-card">
                            <h3>Project Type</h3>
                            <p><asp:Literal ID="litProjectType" runat="server"></asp:Literal></p>
                        </div>
                        <div class="detail-card">
                            <h3>Status</h3>
                            <p><asp:Literal ID="litStatus" runat="server"></asp:Literal></p>
                        </div>
                        <div class="detail-card">
                            <h3>Submission Date</h3>
                            <p><asp:Literal ID="litSubmittedAt" runat="server"></asp:Literal></p>
                        </div>
                        
                        <div class="detail-card full-width">
                            <h3>Functionality</h3>
                            <p><asp:Literal ID="litFunctionality" runat="server"></asp:Literal></p>
                        </div>

                        <div class="detail-card full-width">
                            <h3>Keywords</h3>
                            <div class="tag-list">
                                <asp:Repeater ID="rptKeywords" runat="server">
                                    <ItemTemplate>
                                        <span class="tag"><%# Eval("Keyword") %></span>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# rptKeywords.Items.Count == 0 ? "<span style='color:var(--c-text-muted); font-size: 0.875rem;'>No keywords specified.</span>" : "" %>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </form>
    
    <script src="../../Admin/admin.js"></script>
</body>
</html>
