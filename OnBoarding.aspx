<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OnBoarding.aspx.cs" Inherits="Project_Board.OnBoarding" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Choose Your Path</title>
    <!-- Vector Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Inherit the premium editorial theme -->
    <link rel="stylesheet" href="Admin/admin.css">
    <link rel="stylesheet" href="User/profile.css?v=20260723">
    <style>
        .onboarding-option-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 16px;
            padding: 1.75rem;
            display: flex;
            align-items: center;
            gap: 1.5rem;
            text-decoration: none;
            color: var(--c-text);
            transition: var(--transition);
            cursor: pointer;
            margin-bottom: 1.5rem;
            position: relative;
        }

        .onboarding-option-card:hover {
            border-color: var(--c-accent);
            box-shadow: var(--shadow-md);
            transform: translateY(-3px);
            background: var(--c-bg-card-hover);
        }

        .option-icon-box {
            width: 60px;
            height: 60px;
            border-radius: 14px;
            background: var(--c-accent-bg);
            color: var(--c-accent);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            flex-shrink: 0;
            transition: var(--transition);
        }

        .onboarding-option-card:hover .option-icon-box {
            background: var(--c-accent);
            color: #ffffff;
            box-shadow: 0 4px 12px var(--c-accent-glow);
        }

        .option-details {
            flex: 1;
        }

        .option-title {
            font-family: var(--f-display);
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--c-text);
            margin-bottom: 0.35rem;
        }

        .option-desc {
            font-size: 0.875rem;
            color: var(--c-text-muted);
            line-height: 1.45;
        }

        .option-arrow {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--c-bg-elevated);
            color: var(--c-text-muted);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            transition: var(--transition);
            flex-shrink: 0;
        }

        .onboarding-option-card:hover .option-arrow {
            background: var(--c-accent);
            color: #ffffff;
            transform: translateX(4px);
        }

        .brand-logo-circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background-color: var(--c-accent);
            color: white;
            font-size: 2.25rem;
            font-family: var(--f-display);
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            box-shadow: 0 8px 16px var(--c-accent-glow);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="profile-wrapper">
            
            <!-- Left Sidebar Card -->
            <div class="profile-sidebar-card">
                <div class="brand-logo-circle">
                    <i class="fa-solid fa-cubes-stacked"></i>
                </div>
                
                <h2 class="profile-name">Project Board</h2>
                <div class="profile-badge">
                    <span class="badge admin" style="font-size: 0.85rem;">Student Onboarding</span>
                </div>
                
                <div class="stats-grid" style="width: 100%; margin-bottom: 0;">
                    <div class="stat-card" style="padding: 1.25rem; text-align: center; display: flex; flex-direction: column; align-items: center; background: var(--c-bg-card);">
                        <div class="stat-value" style="font-size: 1.25rem; font-weight: 600; color: var(--c-accent); margin-bottom: 0.25rem;">
                            <i class="fa-solid fa-layer-group"></i>
                        </div>
                        <div class="stat-label" style="font-size: 0.8rem; line-height: 1.3;">Organize &amp; Collaborate</div>
                    </div>
                </div>
            </div>

            <!-- Right Main Form -->
            <div class="profile-main-card">
                <div class="back-btn-container">
                    <a href="Default.aspx" class="back-btn">
                        <i class="fa-solid fa-right-from-bracket"></i> Sign Out
                    </a>
                </div>

                <div class="section-header-custom">
                    <h3>Choose Your Path</h3>
                    <p style="color: var(--c-text-muted); font-size: 0.9rem; margin-top: 0.35rem;">
                        Select how you would like to participate in your project team.
                    </p>
                </div>

                <div style="margin-top: 2rem;">
                    
                    <!-- Option 1: Start my own group -->
                    <asp:LinkButton ID="btnStartGroup" runat="server" CssClass="onboarding-option-card" OnClick="btnStartGroup_Click">
                        <div class="option-icon-box">
                            <i class="fa-solid fa-crown"></i>
                        </div>
                        <div class="option-details">
                            <div class="option-title">Start my own group</div>
                            <div class="option-desc">Become a team leader, create a new project group, and invite members to collaborate.</div>
                        </div>
                        <div class="option-arrow">
                            <i class="fa-solid fa-arrow-right"></i>
                        </div>
                    </asp:LinkButton>

                    <!-- Option 2: Join a group -->
                    <asp:LinkButton ID="btnJoinGroup" runat="server" CssClass="onboarding-option-card" OnClick="btnJoinGroup_Click">
                        <div class="option-icon-box">
                            <i class="fa-solid fa-users-rectangle"></i>
                        </div>
                        <div class="option-details">
                            <div class="option-title">Join a group</div>
                            <div class="option-desc">Search for existing project groups and send a request to join their team.</div>
                        </div>
                        <div class="option-arrow">
                            <i class="fa-solid fa-arrow-right"></i>
                        </div>
                    </asp:LinkButton>

                </div>
            </div>

        </div>
    </form>
</body>
</html>