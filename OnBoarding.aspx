<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OnBoarding.aspx.cs" Inherits="Project_Board.OnBoarding" %>
<!DOCTYPE html>
<html lang="en">

<<<<<<< HEAD
    <head runat="server">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Project Board — Choose Your Path</title>
        <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="styles/login-signup.css?v=20260723_v3">
    </head>
=======
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Choose Your Path</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles/login-signup.css?v=5">
</head>
>>>>>>> a86dd5a9babfe519d5bcc33e23f7710f950763a9

<body class="theme-light">
    
    <div class="theme-bg">
        <div class="theme-bg__image"></div>
        <div class="theme-bg__blur"></div>
        <div class="theme-bg__gradient"></div>
    </div>

    <form id="form1" runat="server">
        <div class="onboarding-container">
            
            <div class="branding-content" style="text-align: center; margin-bottom: 24px; animation: fadeInDown 1s cubic-bezier(0.16, 1, 0.3, 1) both;">
                <div class="brand-text-group">
                    <h1 class="brand-title">
                        <span class="brand-word brand-word--project">Project </span>
                        <span class="brand-word brand-word--board">Board</span>
                    </h1>
                    <p class="brand-tagline">Organize. Track. Collaborate.</p>
                </div>
            </div>
<<<<<<< HEAD
        </form>
        <script src="Scripts/main/login-signup.js?v=20260723_v3"></script>
    </body>
=======
>>>>>>> a86dd5a9babfe519d5bcc33e23f7710f950763a9

            <div class="form-header" style="text-align: center; margin-bottom: 32px; animation: cardSlideIn 1.2s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.1s;">
                <h2 class="form-title" style="font-size: 2rem; font-weight: 700; font-family: var(--font-primary);">Choose Your Path</h2>
                <p class="form-subtitle" style="font-size: 1rem; color: #5c5c5c; margin-top: 4px;">How would you like to proceed?</p>
            </div>

            <div class="onboarding-cards" style="animation: cardSlideIn 1.5s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.2s;">

                <asp:LinkButton ID="btnStartGroup" runat="server" CssClass="onboarding-card"
                    OnClick="btnStartGroup_Click">
                    <div class="card-icon-wrapper">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                            <circle cx="9" cy="7" r="4" />
                            <line x1="19" y1="8" x2="19" y2="14" />
                            <line x1="22" y1="11" x2="16" y2="11" />
                        </svg>
                    </div>
                    <h3 class="card-title">Start my own group</h3>
                    <p class="card-text">Become a leader, create a new project group, and invite members to join your team.</p>
                    <div class="card-action">
                        <span>Continue</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12" />
                            <polyline points="12 5 19 12 12 19" />
                        </svg>
                    </div>
                </asp:LinkButton>

                <asp:LinkButton ID="btnJoinGroup" runat="server" CssClass="onboarding-card"
                    OnClick="btnJoinGroup_Click">
                    <div class="card-icon-wrapper">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                            <circle cx="9" cy="7" r="4" />
                            <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                            <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                        </svg>
                    </div>
                    <h3 class="card-title">Join a group</h3>
                    <p class="card-text">Search for existing groups and request to join their project team.</p>
                    <div class="card-action">
                        <span>Continue</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12" />
                            <polyline points="12 5 19 12 12 19" />
                        </svg>
                    </div>
                </asp:LinkButton>

            </div>
        </div>
    </form>
    <script src="Scripts/main/login-signup.js"></script>
</body>

</html>
