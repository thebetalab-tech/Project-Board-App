<%@ Page Title="Project Board - Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Project_Board._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <meta name="description" content="Project Board - Login to your project management dashboard. Organize, track, and collaborate on your projects seamlessly.">
    <link rel="stylesheet" href="styles/login-signup.css?v=20260724" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <div class="auth-layout">
        <div class="auth-brand">
            <div class="auth-brand-logo">
                <i class="fa-solid fa-cubes-stacked"></i>
            </div>
            <h1 class="auth-brand-title">Project Board</h1>
            <p class="auth-brand-tagline">Organize. Track. Collaborate.</p>
        </div>

        <div class="auth-card">
            <div class="auth-header">
                <h2 class="auth-title">Welcome Back</h2>
                <p class="auth-subtitle">Sign in to continue to your dashboard</p>
            </div>
            
            <asp:Label ID="lblError" runat="server" CssClass="error-message text-center mb-4" EnableViewState="false"></asp:Label>
            
            <div class="login-form" id="loginForm">
                <div class="input-group" id="emailGroup">
                    <label for="txtLoginID" class="input-label">Login ID</label>
                    <div class="input-wrapper">
                        <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                            <circle cx="12" cy="7" r="4" />
                        </svg>
                        <asp:TextBox ID="txtLoginID" runat="server" ClientIDMode="Static" CssClass="form-input" placeholder="Enter your Email Or Enrollment"></asp:TextBox>
                    </div>
                    <asp:Label ID="lblLoginIDError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                </div>

                <div class="input-group" id="passwordGroup">
                    <label for="txtPassword" class="input-label">Password</label>
                    <div class="input-wrapper">
                        <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                        </svg>
                        <asp:TextBox ID="txtPassword" runat="server" ClientIDMode="Static" CssClass="form-input" TextMode="Password" placeholder="Enter your password"></asp:TextBox>
                        <button type="button" class="password-toggle" id="passwordToggle" aria-label="Toggle password visibility">
                            <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                <circle cx="12" cy="12" r="3" />
                            </svg>
                            <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="display:none;">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                                <line x1="1" y1="1" x2="23" y2="23" />
                            </svg>
                        </button>
                    </div>
                    <asp:Label ID="lblPasswordError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                </div>

                <div class="form-options">
                    <a href='<%= ResolveUrl("~/User/forget_password.aspx") %>' class="forgot-link" id="forgotPassword">Forgot Password?</a>
                </div>

                <asp:LinkButton ID="loginBtn" runat="server" ClientIDMode="Static" CssClass="btn-primary mt-4" OnClick="loginBtn_Click">
                    <span class="btn-text">Login</span>
                </asp:LinkButton>
            </div>

            <div class="divider">
                <span class="divider-line"></span>
                <span class="divider-text">or</span>
                <span class="divider-line"></span>
            </div>

            <div class="form-footer">
                <p>Don't have an account? <a href='<%= ResolveUrl("~/SignUp.aspx") %>'>Register Now</a></p>
            </div>
        </div>
    </div>

    <script src="Scripts/main/login-signup.js?v=20260723_v3"></script>
</asp:Content>