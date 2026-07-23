<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="Project_Board.User.Profile" %>
    <!DOCTYPE html>
    <html lang="en">

    <head runat="server">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Project Board — User Profile</title>
        <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="../styles/login-signup.css?v=5">
    </head>

    <body class="theme-light">

        <div class="theme-bg">
            <div class="theme-bg__image"></div>
            <div class="theme-bg__blur"></div>
            <div class="theme-bg__gradient"></div>
        </div>

        <form id="form1" runat="server">
            <div class="onboarding-container" style="min-height: 100vh; height: auto; padding: 40px 20px; overflow-y: auto;">
                <div class="glass-card"
                    style="width: 100%; max-width: 560px; padding: 40px; display: flex; flex-direction: column; animation: cardSlideIn 1.5s cubic-bezier(0.16, 1, 0.3, 1) both; animation-delay: 0.2s;">

                    <div class="branding-content" style="text-align: center; margin-bottom: 20px;">
                        <div class="brand-text-group">
                            <h1 class="brand-title">
                                <span class="brand-word brand-word--project">Project </span>
                                <span class="brand-word brand-word--board">Board</span>
                            </h1>
                            <p class="brand-tagline">Organize. Track. Collaborate.</p>
                        </div>
                    </div>

                    <div class="form-header" style="text-align: center; margin-bottom: 24px;">
                        <h2 class="form-title">User Profile</h2>
                        <p class="form-subtitle">View & update your personal account settings</p>
                    </div>

                    <div class="user-info-badge"
                        style="display: flex; flex-direction: column; gap: 16px; padding: 20px; background: rgba(0,0,0,0.03); border: 1px solid rgba(0,0,0,0.06); border-radius: 16px; margin-bottom: 28px;">
                        <div style="display: flex; align-items: center; gap: 16px;">
                            <div class="user-avatar"
                                style="width: 54px; height: 54px; border-radius: 50%; background: rgba(163, 11, 11, 0.1); color: var(--red-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-family: var(--font-primary); font-size: 1.3rem; flex-shrink: 0;">
                                <span id="avatarInitials" runat="server">JD</span>
                            </div>
                            <div class="user-details"
                                style="display: flex; flex-direction: column; text-align: left; flex-grow: 1;">
                                <span class="user-name"
                                    style="font-family: var(--font-primary); font-weight: 700; color: #1a1a1a; font-size: 1.15rem;">
                                    <asp:Label ID="lblDisplayName" runat="server" Text="John Doe"></asp:Label>
                                </span>
                                <span class="user-roll"
                                    style="font-family: var(--font-secondary); font-size: 0.85rem; color: var(--red-primary); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px;">
                                    <asp:Label ID="lblRoleBadge" runat="server" Text="Student"></asp:Label>
                                </span>
                            </div>
                        </div>

                        <asp:PlaceHolder ID="phStats" runat="server">
                            <div
                                style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; padding-top: 14px; border-top: 1px solid rgba(0,0,0,0.06);">
                                <div
                                    style="background: rgba(255, 255, 255, 0.7); padding: 12px; border-radius: 10px; text-align: center; border: 1px solid rgba(0,0,0,0.04);">
                                    <div
                                        style="font-size: 1.4rem; font-weight: 700; color: #1a1a1a; font-family: var(--font-primary);">
                                        <asp:Label ID="lblProjectsCount" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div
                                        style="font-size: 0.78rem; color: #666; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px;">
                                        Projects</div>
                                </div>
                                <div
                                    style="background: rgba(255, 255, 255, 0.7); padding: 12px; border-radius: 10px; text-align: center; border: 1px solid rgba(0,0,0,0.04);">
                                    <div
                                        style="font-size: 1.4rem; font-weight: 700; color: #1a1a1a; font-family: var(--font-primary);">
                                        <asp:Label ID="lblGroupsCount" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div
                                        style="font-size: 0.78rem; color: #666; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px;">
                                        Groups</div>
                                </div>
                            </div>
                        </asp:PlaceHolder>
                    </div>

                    <div class="login-form">
                        <div
                            style="font-size: 0.85rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #666; margin-bottom: 12px;">
                            Personal Details</div>

                        <div class="input-group">
                            <label for="txtFullName" class="input-label">Full Name</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                    <circle cx="12" cy="7" r="4" />
                                </svg>
                                <asp:TextBox ID="txtFullName" runat="server" ClientIDMode="Static"
                                    placeholder="Enter your full name" required="required"></asp:TextBox>
                            </div>
                        </div>

                        <div class="input-group">
                            <label for="txtEmail" class="input-label">Email Address</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <path
                                        d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                                    <polyline points="22,6 12,13 2,6" />
                                </svg>
                                <asp:TextBox ID="txtEmail" runat="server" ClientIDMode="Static" TextMode="Email"
                                    ReadOnly="true" placeholder="Email address"
                                    style="background: rgba(0,0,0,0.02); opacity: 0.8; cursor: not-allowed;">
                                </asp:TextBox>
                            </div>
                        </div>

                        <div class="input-group">
                            <label for="txtEnrollment" class="input-label">Enrollment / ID</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <rect x="3" y="4" width="18" height="16" rx="2" />
                                    <line x1="7" y1="8" x2="17" y2="8" />
                                    <line x1="7" y1="12" x2="13" y2="12" />
                                </svg>
                                <asp:TextBox ID="txtEnrollment" runat="server" ClientIDMode="Static" ReadOnly="true"
                                    placeholder="Enrollment / ID number"
                                    style="background: rgba(0,0,0,0.02); opacity: 0.8; cursor: not-allowed;">
                                </asp:TextBox>
                            </div>
                        </div>

                        <div
                            style="font-size: 0.85rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #666; margin-top: 24px; margin-bottom: 12px;">
                            Security</div>

                        <div class="input-group">
                            <label for="txtNewPassword" class="input-label">New Password</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                </svg>
                                <asp:TextBox ID="txtNewPassword" runat="server" ClientIDMode="Static"
                                    TextMode="Password" placeholder="Leave blank to keep current"></asp:TextBox>
                            </div>
                        </div>

                        <div class="input-group">
                            <label for="txtConfirmPassword" class="input-label">Confirm Password</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <path
                                        d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4" />
                                </svg>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" ClientIDMode="Static"
                                    TextMode="Password" placeholder="Re-type new password"></asp:TextBox>
                            </div>
                        </div>

                        <asp:LinkButton ID="btnSave" runat="server" CssClass="login-btn" style="margin-top: 24px;"
                            OnClick="btnSave_Click">
                            <span class="btn-text">Save Changes</span>
                            <span class="btn-arrow">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <line x1="5" y1="12" x2="19" y2="12" />
                                    <polyline points="12 5 19 12 12 19" />
                                </svg>
                            </span>
                        </asp:LinkButton>
                    </div>

                    <div class="form-footer" style="margin-top: 24px; display: flex; justify-content: center;">
                        <a href="javascript:history.back()" class="register-btn"
                            style="display: flex; align-items: center; gap: 8px;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16"
                                height="16">
                                <line x1="19" y1="12" x2="5" y2="12" />
                                <polyline points="12 19 5 12 12 5" />
                            </svg>
                            <span>Back to Dashboard</span>
                        </a>
                    </div>
                </div>
            </div>
        </form>
        <script src="../Scripts/main/login-signup.js"></script>
    </body>

    </html>