<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OnBoarding.aspx.cs" Inherits="Project_Board.OnBoarding" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Choose Your Path</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="styles/login-signup.css?v=20260724" />
    <style>
        .onboarding-option-card {
            background: var(--c-surface);
            border: 1px solid var(--c-border);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1.25rem;
            text-decoration: none;
            color: var(--c-foreground);
            transition: var(--transition);
            cursor: pointer;
            margin-bottom: 1.25rem;
            box-shadow: var(--shadow-sm);
        }

        .onboarding-option-card:hover {
            border-color: var(--c-primary);
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
        }

        .option-icon-box {
            width: 54px;
            height: 54px;
            border-radius: var(--radius-md);
            background: var(--c-ring);
            color: var(--c-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            flex-shrink: 0;
            transition: var(--transition);
        }

        .onboarding-option-card:hover .option-icon-box {
            background: var(--c-primary);
            color: var(--c-on-primary);
        }

        .option-details {
            flex: 1;
            text-align: left;
        }

        .option-title {
            font-size: 1.125rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
        }

        .option-desc {
            font-size: 0.875rem;
            color: var(--c-text-muted);
            line-height: 1.4;
        }

        .option-arrow {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--c-input-bg);
            color: var(--c-text-muted);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.875rem;
            transition: var(--transition);
            flex-shrink: 0;
        }

        .onboarding-option-card:hover .option-arrow {
            background: var(--c-primary);
            color: var(--c-on-primary);
            transform: translateX(4px);
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            color: var(--c-text-muted);
            font-weight: 500;
            margin-bottom: 1.5rem;
            text-decoration: none;
            transition: color var(--transition);
        }
        
        .back-link:hover {
            color: var(--c-primary);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="auth-layout" style="max-width: 500px;">
        <div class="auth-brand">
            <div class="auth-brand-logo">
                <i class="fa-solid fa-cubes-stacked"></i>
            </div>
            <h1 class="auth-brand-title">Project Board</h1>
        </div>

        <div class="auth-card">
            <a href='<%= ResolveUrl("~/Logout.aspx") %>' class="back-link">
                <i class="fa-solid fa-arrow-left"></i> Sign Out
            </a>

            <div class="auth-header" style="text-align: left; margin-bottom: 1.5rem;">
                <h2 class="auth-title">Choose Your Path</h2>
                <p class="auth-subtitle">Select how you would like to participate in your project team.</p>
            </div>

            <div>
                <!-- Option 1: Start my own group -->
                <asp:LinkButton ID="btnStartGroup" runat="server" CssClass="onboarding-option-card" OnClick="btnStartGroup_Click">
                    <div class="option-icon-box">
                        <i class="fa-solid fa-crown"></i>
                    </div>
                    <div class="option-details">
                        <div class="option-title">Start my own group</div>
                        <div class="option-desc">Become a team leader, create a new project group, and invite members.</div>
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
    </form>
</body>
</html>
