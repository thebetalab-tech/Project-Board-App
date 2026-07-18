<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MentorSelection.aspx.cs" Inherits="Project_Board.MentorSelection" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Mentor Selection</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="styles/login-signup.css?v=5">
    <style>
        /* Extra custom styles for the mentor cards to overlay on login-signup.css */
        .mentor-selection-card {
            width: 100%;
            max-width: 900px;
            padding: 40px;
            display: flex;
            flex-direction: column;
            animation: cardSlideIn 1.5s cubic-bezier(0.16, 1, 0.3, 1) both;
            animation-delay: 0.2s;
        }
        
        .faculty-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 20px;
            margin-top: 24px;
            margin-bottom: 24px;
        }

        .faculty-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 16px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);
            backdrop-filter: blur(10px);
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
            background: var(--red-primary);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .faculty-card:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(255, 255, 255, 0.2);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.2);
        }

        .faculty-card:hover::before {
            opacity: 1;
        }

        .faculty-avatar {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: var(--red-subtle);
            color: var(--red-primary);
            font-weight: 700;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
            border: 1px solid rgba(163, 11, 11, 0.3);
            text-transform: uppercase;
        }

        .faculty-name {
            font-family: var(--font-primary);
            font-size: 1.15rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 6px;
        }

        .faculty-email {
            font-family: var(--font-secondary);
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-bottom: 16px;
            word-break: break-all;
        }

        .faculty-email i {
            margin-right: 4px;
            opacity: 0.7;
        }

        .tech-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.08);
            color: var(--text-primary);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            margin-top: auto;
            margin-bottom: 16px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .btn-request-mentor {
            width: 100%;
            background: var(--red-primary);
            color: var(--white);
            border: none;
            padding: 10px 16px;
            border-radius: 8px;
            font-family: var(--font-primary);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-request-mentor:hover {
            background: var(--red-light);
            box-shadow: 0 4px 12px var(--red-glow);
        }

        /* Active request banner */
        .active-request-box {
            background: rgba(163, 11, 11, 0.08);
            border: 1px solid rgba(163, 11, 11, 0.3);
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            margin-top: 20px;
            backdrop-filter: blur(10px);
            animation: cardSlideIn 1s cubic-bezier(0.16, 1, 0.3, 1) both;
        }

        .active-request-icon {
            font-size: 2.5rem;
            color: var(--red-primary);
            margin-bottom: 16px;
        }

        .active-request-text {
            font-size: 1.1rem;
            color: var(--text-primary);
            margin-bottom: 8px;
            line-height: 1.6;
        }

        .active-request-status {
            display: inline-block;
            background: rgba(255, 193, 7, 0.15);
            color: #ffc107;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 24px;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }

        .btn-withdraw {
            background: #ef4444;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-family: var(--font-primary);
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-withdraw:hover {
            background: #dc2626;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
        }

        /* Empty state styling */
        .empty-state {
            grid-column: 1 / -1;
            padding: 48px 24px;
            text-align: center;
            background: rgba(255, 255, 255, 0.02);
            border: 1px dashed rgba(255, 255, 255, 0.1);
            border-radius: 16px;
        }

        .empty-state-icon {
            font-size: 3rem;
            color: var(--text-muted);
            margin-bottom: 16px;
        }

        .empty-state-title {
            font-size: 1.2rem;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .empty-state-desc {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .dashboard-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-top: 16px;
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s ease;
        }

        .dashboard-link:hover {
            color: var(--white);
        }

        /* Adjust onboarding card container to handle the wider mentor card */
        .onboarding-container {
            max-width: 950px;
        }

        .badge-info-pills {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .badge-pill {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 6px 14px;
            border-radius: 30px;
            font-size: 0.85rem;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .badge-pill i {
            color: var(--red-primary);
        }

        .badge-pill strong {
            color: var(--text-primary);
        }
    </style>
</head>
<body class="theme-light">
    
    <div class="theme-bg">
        <div class="theme-bg__image"></div>
        <div class="theme-bg__blur"></div>
        <div class="theme-bg__gradient"></div>
    </div>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="onboarding-container">
            <div class="glass-card mentor-selection-card">
                
                <div class="branding-content" style="text-align: center; margin-bottom: 16px;">
                    <div class="brand-text-group">
                        <h1 class="brand-title">
                            <span class="brand-word brand-word--project">Project </span>
                            <span class="brand-word brand-word--board">Board</span>
                        </h1>
                        <p class="brand-tagline">Organize. Track. Collaborate.</p>
                    </div>
                </div>

                <div class="form-header" style="text-align: center; margin-bottom: 20px;">
                    <h2 class="form-title">Mentor Selection</h2>
                    <p class="form-subtitle">Choose a professor to mentor your group</p>
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

                <asp:Label ID="lblMessage" runat="server" EnableViewState="false" style="display: block; margin-bottom: 16px; text-align: center; font-weight: 500;"></asp:Label>

                <!-- Active Request Box (Shown when a mentor is requested) -->
                <asp:Panel ID="pnlCurrentRequest" runat="server" Visible="false" CssClass="active-request-box">
                    <div class="active-request-icon">
                        <i class="fa-solid fa-paper-plane"></i>
                    </div>
                    <div class="active-request-text">
                        You have sent a mentor request to:<br />
                        <strong style="font-size: 1.3rem; color: var(--white); display: block; margin: 8px 0;"><asp:Label ID="lblMentorName" runat="server"></asp:Label></strong>
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
                                    <asp:Button ID="btnSelect" runat="server" Text="Request Mentor" CssClass="btn-request-mentor" CommandName="SelectMentor" CommandArgument='<%# Eval("UserId") %>' />
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

                <div class="form-footer" style="margin-top: 24px; display: flex; justify-content: center; flex-direction: column; align-items: center;">
                    <a href="Student/Leader/Dashboard.aspx" class="dashboard-link">
                        <span>Go to Dashboard</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                            <line x1="5" y1="12" x2="19" y2="12" />
                            <polyline points="12 5 19 12 12 19" />
                        </svg>
                    </a>
                </div>
            </div>
        </div>
    </form>
    <script src="Scripts/main/login-signup.js"></script>
</body>
</html>
