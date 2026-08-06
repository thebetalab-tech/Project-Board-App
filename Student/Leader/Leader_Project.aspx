<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Project.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Project" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader - Project Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../../Admin/admin.css?v=639200793428857004" />
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

        .alert-warning-box {
            background: rgba(245, 158, 11, 0.12);
            border: 1px solid rgba(245, 158, 11, 0.4);
            color: #d97706;
            padding: 0.85rem 1.1rem;
            border-radius: 8px;
            margin-bottom: 1.2rem;
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            font-size: 0.88rem;
            line-height: 1.5;
        }

        .proposal-card {
            background: var(--c-surface, #ffffff);
            border: 1px solid var(--c-border, #e2e8f0);
            border-radius: 12px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .proposal-card:hover {
            box-shadow: 0 4px 14px rgba(0,0,0,0.08);
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

        .help-text {
            font-size: 0.75rem;
            color: var(--c-text-dim, #64748b);
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
                        <p>Submit project proposals and track faculty review and approval.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; margin-bottom:1rem;"></asp:Label>

                <!-- SIMILARITY WARNING BOX -->
                <div id="pnlWarning" runat="server" visible="false" class="alert-warning-box">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.25rem; margin-top: 0.15rem; flex-shrink:0;"></i>
                    <div>
                        <asp:Label ID="lblWarningMessage" runat="server"></asp:Label>
                    </div>
                </div>

                <!-- PROJECT SUBMISSION FORM -->
                <div class="stat-card" style="margin-bottom: 2rem;">
                    <h3><i class="fa-solid fa-plus-circle" style="color:var(--c-accent); margin-right:0.5rem;"></i> Submit New Project Proposal</h3>
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label>Project Title</label>
                            <asp:TextBox ID="txtProjectTitle" runat="server" CssClass="form-control" placeholder="Enter project title..." AutoPostBack="true" OnTextChanged="txtProjectTitle_TextChanged"></asp:TextBox>
                            <span class="help-text">Auto-checks system for similar project names.</span>
                        </div>
                        <div class="form-group">
                            <label>Project Type</label>
                            <asp:DropDownList ID="ddlProjectType" runat="server" CssClass="form-control">
                                <asp:ListItem Text="UDP (User Defined Project)" Value="UDP"></asp:ListItem>
                                <asp:ListItem Text="IDP (Industry Defined Project)" Value="IDP"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Project Keywords / Tech Stack Tags</label>
                            <asp:TextBox ID="txtKeywords" runat="server" CssClass="form-control" placeholder="e.g. Artificial Intelligence, Web App, React, Python"></asp:TextBox>
                            <span class="help-text">Separate tags with commas. Stored in ProjectKeywords table.</span>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Key Functionalities & Overview</label>
                            <asp:TextBox ID="txtFunctionality" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" placeholder="Describe main features, functionalities, and scope of your project..."></asp:TextBox>
                        </div>
                    </div>
                    <div style="margin-top:1rem; text-align:right;">
                        <asp:Button ID="btnSubmitProject" runat="server" Text="Submit Project Proposal" CssClass="btn-primary" OnClick="btnSubmitProject_Click" />
                    </div>
                </div>

                <!-- SUBMITTED PROPOSALS LIST -->
                <div class="data-section">
                    <div class="section-header">
                        <h2><i class="fa-solid fa-folder-open" style="color:var(--c-accent); margin-right:0.5rem;"></i> Submitted Project Proposals</h2>
                    </div>

                    <asp:Repeater ID="rptProposals" runat="server" OnItemCommand="rptProposals_ItemCommand">
                        <ItemTemplate>
                            <div class="proposal-card">
                                <div class="proposal-header">
                                    <div>
                                        <span class="proposal-title"><%# Eval("ProjectTitle") %></span>
                                        <span class="badge-status badge-info" style="margin-left:0.5rem; background:rgba(99,102,241,0.15); color:#6366f1;">
                                            <%# Eval("ProjectType") %>
                                        </span>
                                    </div>
                                    <div style="display:flex; align-items:center; gap:0.75rem;">
                                        <span class='badge-status status-<%# Eval("Status").ToString().ToLower() %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteProposal" CommandArgument='<%# Eval("ProjectId") %>' Visible='<%# Eval("Status").ToString() == "Pending" %>' CssClass="icon-btn delete" title="Withdraw Proposal" OnClientClick="return confirm('Are you sure you want to withdraw this proposal?');">
                                            <i class="fa-solid fa-trash" style="color:#ef4444;"></i>
                                        </asp:LinkButton>
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
                        <FooterTemplate>
                            <%# rptProposals.Items.Count == 0 ? "<div style='text-align:center; padding: 2.5rem; color: var(--c-text-dim); border: 1px dashed var(--c-border); border-radius: 12px;'>No project proposals submitted yet. Use the form above to submit your proposal.</div>" : "" %>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>

</html>
