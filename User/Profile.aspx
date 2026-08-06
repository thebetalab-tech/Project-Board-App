<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="Project_Board.User.Profile" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile</title>
    <!-- Vector Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Inherit the premium editorial theme -->
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <link  rel="stylesheet" href="../User/profile.css?v=20260723" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="profile-wrapper">
            
            <!-- Left Sidebar Profile Card -->
            <div class="profile-sidebar-card">
                <div class="profile-avatar">
                    <span id="avatarInitials" runat="server">JD</span>
                </div>
                
                <h2 class="profile-name"><asp:Label ID="lblDisplayName" runat="server" Text="John Doe"></asp:Label></h2>
                <div class="profile-badge">
                    <span class="badge admin" style="font-size: 0.85rem;"><asp:Label ID="lblRoleBadge" runat="server" Text="Student"></asp:Label></span>
                </div>
                
                <asp:PlaceHolder ID="phStats" runat="server">
                    <div class="stats-grid" style="width: 100%; margin-bottom: 0; gap: 1rem;">
                        <div class="stat-card" style="padding: 1.25rem; text-align: center; display: flex; flex-direction: column; align-items: center;">
                            <div class="stat-value" style="font-size: 1.75rem;"><asp:Label ID="lblProjectsCount" runat="server" Text="3"></asp:Label></div>
                            <div class="stat-label">Projects</div>
                        </div>
                        <div class="stat-card" style="padding: 1.25rem; text-align: center; display: flex; flex-direction: column; align-items: center;">
                            <div class="stat-value" style="font-size: 1.75rem;"><asp:Label ID="lblGroupsCount" runat="server" Text="1"></asp:Label></div>
                            <div class="stat-label">Groups</div>
                        </div>
                    </div>
                </asp:PlaceHolder>
            </div>

            <!-- Right Main Form -->
            <div class="profile-main-card">
                <div class="back-btn-container">
                    <a href='<%= ResolveUrl("~/Default.aspx") %>' class="back-btn">
                        <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
                    </a>
                </div>

                <div class="section-header-custom">
                    <h3>Personal Details</h3>
                </div>

                <div class="form-row full">
                    <div class="form-group">
                        <label>Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter your email address" TextMode="Email" ReadOnly="true" style="background-color: var(--c-bg-elevated); color: var(--c-text-muted); cursor: not-allowed;"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Enrollment / ID</label>
                        <asp:TextBox ID="txtEnrollment" runat="server" CssClass="form-control" ReadOnly="true" style="background-color: var(--c-bg-elevated); color: var(--c-text-muted); cursor: not-allowed;"></asp:TextBox>
                    </div>
                </div>

                <div class="section-header-custom" style="margin-top: 3rem;">
                    <h3>Security</h3>
                </div>

                <div class="form-row">
                    <div class="form-group" style="position:relative;">
                        <label>New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" placeholder="Leave blank to keep current" TextMode="Password" style="padding-right:40px;"></asp:TextBox>
                        <button type="button" class="password-toggle" aria-label="Toggle password visibility" style="position:absolute; right:10px; top:35px; background:none; border:none; color:var(--text-secondary, #666); cursor:pointer;">
                            <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                <circle cx="12" cy="12" r="3" />
                            </svg>
                            <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18" style="display:none;">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                                <line x1="1" y1="1" x2="23" y2="23" />
                            </svg>
                        </button>
                    </div>
                    <div class="form-group" style="position:relative;">
                        <label>Confirm Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" placeholder="Re-type new password" TextMode="Password" style="padding-right:40px;"></asp:TextBox>
                        <button type="button" class="password-toggle" aria-label="Toggle password visibility" style="position:absolute; right:10px; top:35px; background:none; border:none; color:var(--text-secondary, #666); cursor:pointer;">
                            <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                <circle cx="12" cy="12" r="3" />
                            </svg>
                            <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18" style="display:none;">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                                <line x1="1" y1="1" x2="23" y2="23" />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn-secondary" onclick="document.getElementById('form1').reset(); return false;">Discard</button>
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn-primary" OnClick="btnSave_Click">
                        <i class="fa-solid fa-check"></i> Save Changes
                    </asp:LinkButton>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
