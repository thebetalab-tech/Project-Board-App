<%@ Page Title="Project Board - Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Project_Board._Default" %>

    <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

        <meta name="description"
            content="Project Board - Login to your project management dashboard. Organize, track, and collaborate on your projects seamlessly.">
        <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="styles/login-signup.css?v=5">

        <div class="bg-scene" id="bgScene">
            <div class="bg-layer bg-layer--deep">
                <video id="bg-video-1" class="bg-video" autoplay loop muted playsinline poster="assets/bg.webp">
                    <source src="assets/background video.mp4" type="video/mp4">
                </video>
            </div>
            <div class="bg-layer bg-layer--mid">
                <div class="texture-overlay"></div>
            </div>
            <div class="bg-layer bg-layer--front">
                <div class="particle-field" id="particleField"></div>
            </div>
            <div class="bg-gradient-overlay"></div>
        </div>

        <div class="login-container">

            <div class="branding-side">
                <div class="brand-corner">
                    <div class="logo-wrapper" aria-label="Project Board logo">
                        <div class="logo-glow"></div>
                    </div>
                    <div class="brand-text-group">
                        <h1 class="brand-title">
                            <span class="brand-word brand-word--project">Project </span>
                            <span class="brand-word brand-word--board">Board</span>
                        </h1>
                        <p class="brand-tagline">Organize. Track. Collaborate.</p>
                    </div>
                </div>
            </div>

            <div class="form-side">
                <div class="form-side-content">
                    <div class="form-header">
                        <h2 class="form-title">Welcome Back</h2>
                        <p class="form-subtitle">Sign in to continue to your dashboard</p>
                    </div>
                    <asp:Label ID="lblError" runat="server" ForeColor="#ff4d4d" CssClass="error-message" EnableViewState="false"></asp:Label>
                    <div class="login-form" id="loginForm">

                        <div class="input-group" id="emailGroup">
                            <label for="txtLoginID" class="input-label">Login ID</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                    <circle cx="12" cy="7" r="4" />
                                </svg>
                                <asp:TextBox ID="txtLoginID" runat="server" ClientIDMode="Static" CssClass="form-input"
                                    placeholder="Enter your Email Or Enrollment Or UID"></asp:TextBox>
                            </div>
                        </div>

                        <div class="input-group" id="passwordGroup">
                            <label for="txtPassword" class="input-label">Password</label>
                            <div class="input-wrapper">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="1.5">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                </svg>
                                <asp:TextBox ID="txtPassword" runat="server" ClientIDMode="Static" CssClass="form-input"
                                    TextMode="Password" placeholder="Enter your password"></asp:TextBox>

                                <button type="button" class="password-toggle" id="passwordToggle"
                                    aria-label="Toggle password visibility">
                                    <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                        <circle cx="12" cy="12" r="3" />
                                    </svg>
                                    <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none"
                                        stroke="currentColor" stroke-width="1.5" style="display:none;">
                                        <path
                                            d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                                        <line x1="1" y1="1" x2="23" y2="23" />
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <div class="form-options">
                            <a href="#" class="forgot-link" id="forgotPassword">Forgot Password?</a>
                        </div>

                        <asp:LinkButton ID="loginBtn" runat="server" ClientIDMode="Static" CssClass="login-btn"
                            OnClick="loginBtn_Click">
                            <span class="btn-text">Login</span>
                            <span class="btn-loader" id="btnLoader" style="display:none;">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="10" stroke-dasharray="31.4" stroke-dashoffset="10" />
                                </svg>
                            </span>
                            <span class="btn-arrow">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <line x1="5" y1="12" x2="19" y2="12" />
                                    <polyline points="12 5 19 12 12 19" />
                                </svg>
                            </span>
                            <div class="btn-ripple"></div>
                        </asp:LinkButton>
                    </div>

                    <div class="divider">
                        <span class="divider-line"></span>
                        <span class="divider-text">or</span>
                        <span class="divider-line"></span>
                    </div>

                    <div class="form-footer">
                        <p class="footer-text">Don't have an account?</p>
                        <a href="SignUp.aspx" class="register-btn" id="registerBtn">
                            <span>Register Now</span>
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16"
                                height="16">
                                <line x1="5" y1="12" x2="19" y2="12" />
                                <polyline points="12 5 19 12 12 19" />
                            </svg>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <script src="Scripts/main/login-signup.js"></script>

    </asp:Content>
