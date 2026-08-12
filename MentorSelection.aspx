<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MentorSelection.aspx.cs" Inherits="Project_Board.MentorSelection" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Mentor Selection</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="styles/login-signup.css?v=20260724" />
    <style>
        .mentor-selection-card {
            width: 100%;
            max-width: 900px;
        }
        
        .faculty-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 1.25rem;
            margin-top: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .faculty-card {
            background: var(--c-surface);
            border: 1px solid var(--c-border);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: var(--transition);
            box-shadow: var(--shadow-sm);
            position: relative;
            overflow: hidden;
        }

        .faculty-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: var(--c-primary);
            opacity: 0;
            transition: opacity var(--transition);
        }

        .faculty-card:hover {
            transform: translateY(-4px);
            border-color: var(--c-primary);
            box-shadow: var(--shadow-md);
        }

        .faculty-card:hover::before {
            opacity: 1;
        }

        .faculty-avatar {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: var(--c-ring);
            color: var(--c-primary);
            font-weight: 700;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1rem;
            border: 2px solid var(--c-surface);
            box-shadow: 0 0 0 2px var(--c-ring);
            text-transform: uppercase;
        }

        .faculty-name {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--c-foreground);
            margin-bottom: 0.25rem;
        }

        .faculty-email {
            font-size: 0.875rem;
            color: var(--c-text-muted);
            margin-bottom: 1rem;
            word-break: break-all;
        }

        .faculty-email i {
            margin-right: 0.25rem;
            opacity: 0.7;
        }

        .tech-badge {
            display: inline-block;
            background: var(--c-input-bg);
            color: var(--c-foreground);
            padding: 0.25rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.75rem;
            font-weight: 500;
            margin-top: auto;
            margin-bottom: 1rem;
            border: 1px solid var(--c-border);
        }

        .active-request-box {
            background: var(--c-ring);
            border: 1px solid rgba(13, 148, 136, 0.3);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            text-align: center;
            margin-top: 1.25rem;
        }

        .active-request-icon {
            font-size: 2.5rem;
            color: var(--c-primary);
            margin-bottom: 1rem;
        }

        .active-request-text {
            font-size: 1rem;
            color: var(--c-foreground);
            margin-bottom: 0.5rem;
            line-height: 1.5;
        }

        .active-request-status {
            display: inline-block;
            background: rgba(234, 179, 8, 0.15);
            color: #CA8A04;
            padding: 0.25rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            border: 1px solid rgba(234, 179, 8, 0.3);
        }

        .btn-withdraw {
            background: var(--c-destructive);
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-withdraw:hover {
            background: #B91C1C;
            box-shadow: 0 4px 6px rgba(220, 38, 38, 0.2);
        }

        .empty-state {
            grid-column: 1 / -1;
            padding: 3rem 1.5rem;
            text-align: center;
            background: var(--c-input-bg);
            border: 1px dashed #CBD5E1;
            border-radius: var(--radius-lg);
        }

        .empty-state-icon {
            font-size: 3rem;
            color: #94A3B8;
            margin-bottom: 1rem;
        }

        .empty-state-title {
            font-size: 1.25rem;
            color: var(--c-foreground);
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .empty-state-desc {
            font-size: 0.95rem;
            color: var(--c-text-muted);
        }

        .dashboard-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 1rem;
            color: var(--c-text-muted);
            text-decoration: none;
            font-size: 0.95rem;
            transition: color var(--transition);
            font-weight: 500;
        }

        .dashboard-link:hover {
            color: var(--c-primary);
        }

        .auth-layout-wide {
            width: 100%;
            max-width: 900px;
            padding: 2rem 1.5rem;
            margin: auto;
        }

        .badge-info-pills {
            display: flex;
            justify-content: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
        }

        .badge-pill {
            background: var(--c-input-bg);
            border: 1px solid var(--c-border);
            padding: 0.35rem 0.875rem;
            border-radius: 1.5rem;
            font-size: 0.875rem;
            color: var(--c-text-muted);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .badge-pill i {
            color: var(--c-primary);
        }

        .badge-pill strong {
            color: var(--c-foreground);
            font-weight: 600;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="auth-layout-wide">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="auth-brand">
            <div class="auth-brand-logo">
                <i class="fa-solid fa-cubes-stacked"></i>
            </div>
            <h1 class="auth-brand-title">Project Board</h1>
            <p class="auth-brand-tagline">Organize. Track. Collaborate.</p>
        </div>

        <div class="auth-card mentor-selection-card">
            <div class="auth-header">
                <h2 class="auth-title">Mentor Selection</h2>
                <p class="auth-subtitle">Choose a professor to mentor your group</p>
            </div>

            <!-- Info Badges -->
            <div class="badge-info-pills">
                <div class="badge-pill">
                    <i class="fa-solid fa-users"></i> Group: <strong><asp:Label ID="lblGroupName" runat="server" Text="Loading..."></asp:Label></strong>
                </div>
                <div class="badge-pill">
                    <i class="fa-solid fa-laptop-code"></i> Domain: <strong><asp:Label ID="lblTechName" runat="server" Text="Loading..."></asp:Label></strong>
                </div>
            </div>

            <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="error-message text-center mb-4" style="display: block; font-weight: 500;"></asp:Label>

            <!-- Active Request Box -->
            <asp:Panel ID="pnlCurrentRequest" runat="server" Visible="false" CssClass="active-request-box">
                <div class="active-request-icon">
                    <i class="fa-solid fa-paper-plane"></i>
                </div>
                <div class="active-request-text">
                    You have sent a mentor request to:<br />
                    <strong style="font-size: 1.25rem; color: var(--c-foreground); display: block; margin: 0.5rem 0;"><asp:Label ID="lblMentorName" runat="server"></asp:Label></strong>
                </div>
                <div>
                    <span class="active-request-status">
                        <i class="fa-solid fa-hourglass-half"></i> <asp:Label ID="lblStatusText" runat="server"></asp:Label>
                    </span>
                </div>
                <asp:Button ID="btnWithdraw" runat="server" CssClass="btn-withdraw" Text="Withdraw Request" OnClick="btnWithdraw_Click" />
            </asp:Panel>

            <!-- Available Mentors Selection Grid -->
            <asp:Panel ID="pnlSelectionForm" runat="server">
                <div class="faculty-grid">
                    <asp:Repeater ID="rptFaculty" runat="server" OnItemCommand="rptFaculty_ItemCommand">
                        <ItemTemplate>
                            <div class="faculty-card">
                                <div class="faculty-avatar">
                                    <%# GetInitials(Eval("FullName").ToString()) %>
                                </div>
                                <h3 class="faculty-name"><%# Eval("FullName") %></h3>
                                <p class="faculty-email">
                                    <i class="fa-solid fa-envelope"></i> <%# Eval("Email") %>
                                </p>
                                <span class="tech-badge">
                                    <i class="fa-solid fa-tag"></i> <asp:Label ID="lblCardTech" runat="server" Text='<%# SelectedTechName %>'></asp:Label>
                                </span>
                                <asp:Button ID="btnSelect" runat="server" Text="Request Mentor" CssClass="btn-primary" CommandName="SelectMentor" CommandArgument='<%# Eval("UserId") %>' />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <!-- Empty State if no professors are available -->
                    <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                        <div class="empty-state">
                            <div class="empty-state-icon">
                                <i class="fa-solid fa-user-slash"></i>
                            </div>
                            <h3 class="empty-state-title">No Mentors Available</h3>
                            <p class="empty-state-desc">There are currently no active faculty members assigned to your technology domain who are available.</p>
                        </div>
                    </asp:PlaceHolder>
                </div>
            </asp:Panel>

            <div class="text-center mt-6">
                <a href='<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>' class="dashboard-link">
                    <span>Go to Dashboard</span> <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>
        </div>
    </form>
    <script src='<%= ResolveUrl("~/Scripts/main/login-signup.js?v=20260723_v3") %>'></script>
</body>
</html>
