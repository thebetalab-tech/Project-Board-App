<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateGroup.aspx.cs" Inherits="Project_Board.CreateGroup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Create Group</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles/login-signup.css">
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
            <div class="glass-card" style="width: 100%; max-width: 480px; padding: 40px; display: flex; flex-direction: column; animation: cardSlideIn 1.5s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.2s;">
                
                <div class="branding-content" style="text-align: center; margin-bottom: 24px;">
                    <div class="brand-text-group">
                        <h1 class="brand-title">
                            <span class="brand-word brand-word--project">Project </span>
                            <span class="brand-word brand-word--board">Board</span>
                        </h1>
                        <p class="brand-tagline">Organize. Track. Collaborate.</p>
                    </div>
                </div>

                <div class="form-header" style="text-align: center; margin-bottom: 24px;">
                    <h2 class="form-title">Create Group</h2>
                    <p class="form-subtitle">Initialize your project team</p>
                </div>

                <div class="user-info-badge" style="display: flex; align-items: center; gap: 16px; padding: 16px; background: rgba(0,0,0,0.03); border: 1px solid rgba(0,0,0,0.06); border-radius: 12px; margin-bottom: 32px;">
                    <div class="user-avatar" style="width: 48px; height: 48px; border-radius: 50%; background: rgba(163, 11, 11, 0.1); color: var(--red-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-family: var(--font-primary); font-size: 1.2rem; flex-shrink: 0;">
                        JD
                    </div>
                    <div class="user-details" style="display: flex; flex-direction: column; text-align: left;">
                        <span class="user-name" style="font-family: var(--font-primary); font-weight: 600; color: #1a1a1a; font-size: 1.05rem;">Jane Doe</span>
                        <span class="user-roll" style="font-family: var(--font-secondary); font-size: 0.85rem; color: #5c5c5c; margin-top: 2px;">21BCE0001 &bull; Group Leader</span>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>

                <div class="login-form">
                    
                    <div class="input-group">
                        <label for="txtGroupName" class="input-label">Group Name</label>
                        
                        <asp:UpdatePanel ID="upGroupName" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                                        <circle cx="9" cy="7" r="4" />
                                        <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                                        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                                    </svg>
                                    
                                    <asp:TextBox ID="txtGroupName" runat="server" ClientIDMode="Static" 
                                        placeholder="e.g. Beta Lab Core Team" required="required"
                                        AutoPostBack="true" OnTextChanged="txtGroupName_TextChanged">
                                    </asp:TextBox>
                                </div>
                                
                                <asp:Label ID="lblNameStatus" runat="server" Font-Size="13px" Font-Bold="true" style="margin-top: 6px; display: block;"></asp:Label>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>

                    <div class="input-group">
                        <label for="ddlTechDomain" class="input-label">Technology Domain</label>
                        <div class="input-wrapper input-wrapper--select">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
                                <line x1="8" y1="21" x2="16" y2="21" />
                                <line x1="12" y1="17" x2="12" y2="21" />
                            </svg>
                                                                                
                            <asp:DropDownList ID="ddlTechDomain" runat="server" ClientIDMode="Static" CssClass="glass-select" required="required" AppendDataBoundItems="true">
                                <asp:ListItem Value="" Text="Select primary technology" disabled="disabled" Selected="True"></asp:ListItem>
                            </asp:DropDownList>
                            
                            <svg class="select-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <polyline points="6 9 12 15 18 9" />
                            </svg>
                        </div>
                    </div>

                    <asp:LinkButton ID="btnCreateGroup" runat="server" CssClass="login-btn" style="margin-top: 20px;" OnClick="btnCreateGroup_Click">
                        <span class="btn-text">Create Group</span>
                        <span class="btn-arrow">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <line x1="5" y1="12" x2="19" y2="12" />
                                <polyline points="12 5 19 12 12 19" />
                            </svg>
                        </span>
                    </asp:LinkButton>
                </div>
                
                <div class="form-footer" style="margin-top: 30px; display: flex; justify-content: center;">
                    <a href="OnBoarding.aspx" class="register-btn" style="display: flex; align-items: center; gap: 8px;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                            <line x1="19" y1="12" x2="5" y2="12" />
                            <polyline points="12 19 5 12 12 5" />
                        </svg>
                        <span>Back</span>
                    </a>
                </div>
            </div>
        </div>
    </form>
    <script src="Scripts/main/login-signup.js"></script>
</body>
</html>