<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SignUp.aspx.cs" Inherits="Project_Board.SignUp" %>
    <!DOCTYPE html>
    <html lang="en">

    <head runat="server">
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description"
            content="Project Board - Sign up for your project management dashboard. Organize, track, and collaborate on your projects seamlessly.">
        <title>Project Board — Sign Up</title>
        <link rel="icon" href="favicon.ico" type="image/x-icon">
        <link
            href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap"
            rel="stylesheet">

        <link rel="stylesheet" href="styles/login-signup.css?v=20260719">
    </head>

    <body>
        <div class="bg-scene" id="bgScene">
            <div class="bg-layer bg-layer--deep aurora-container">
                <div class="aurora-blob blob-1"></div>
                <div class="aurora-blob blob-2"></div>
                <div class="aurora-blob blob-3"></div>
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
                        <h2 class="form-title">Create Account</h2>
                        <p class="form-subtitle">Join Project Board today</p>
                    </div>

                    <form id="signupForm" runat="server" class="login-form" autocomplete="off">
                        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="form-message">
                        </asp:Label>

                        <!-- Signup Form Fields -->
                        <asp:Panel ID="pnlSignupForm" runat="server">
                            <div class="input-group" id="nameGroup">
                                <label for="fullName" class="input-label">Full Name</label>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                        <circle cx="12" cy="7" r="4" />
                                    </svg>
                                    <asp:TextBox ID="fullName" runat="server" ClientIDMode="Static"
                                        placeholder="Enter your full name" required="required"></asp:TextBox>
                                </div>
                            </div>

                            <div class="input-group" id="emailGroup">
                                <label for="loginId" class="input-label">Email Address</label>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <rect x="3" y="5" width="18" height="14" rx="2" ry="2" />
                                        <polyline points="3 7 12 13 21 7" />
                                    </svg>
                                    <asp:TextBox ID="loginId" runat="server" ClientIDMode="Static" TextMode="Email"
                                        placeholder="Enter your email" required="required"></asp:TextBox>
                                </div>
                            </div>

                            <div class="input-group" id="enrollmentGroup">
                                <label for="enrollment" class="input-label">Enrollment Number</label>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
                                        <line x1="8" y1="21" x2="16" y2="21" />
                                        <line x1="12" y1="17" x2="12" y2="21" />
                                    </svg>
                                    <asp:TextBox ID="enrollment" runat="server" ClientIDMode="Static"
                                        placeholder="Enter your enrollment number" required="required"></asp:TextBox>
                                </div>
                            </div>

                            <div class="input-group" id="passwordGroup">
                                <label for="password" class="input-label">Password</label>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                    </svg>
                                    <asp:TextBox ID="password" runat="server" ClientIDMode="Static" TextMode="Password"
                                        placeholder="Create a password" required="required"></asp:TextBox>
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
                                <div class="password-strength" id="passwordStrength">
                                    <div class="strength-bars">
                                        <span class="strength-bar" data-index="0"></span>
                                        <span class="strength-bar" data-index="1"></span>
                                        <span class="strength-bar" data-index="2"></span>
                                        <span class="strength-bar" data-index="3"></span>
                                    </div>
                                    <span class="strength-label" id="strengthLabel"></span>
                                    <ul class="strength-requirements" id="strengthRequirements">
                                        <li data-req="length"><span class="req-icon"></span>At least 8 characters</li>
                                        <li data-req="uppercase"><span class="req-icon"></span>One uppercase letter (A–Z)</li>
                                        <li data-req="lowercase"><span class="req-icon"></span>One lowercase letter (a–z)</li>
                                        <li data-req="number"><span class="req-icon"></span>One number (0–9)</li>
                                        <li data-req="special"><span class="req-icon"></span>One special character (!@#$…)</li>
                                    </ul>
                                </div>
                            </div>

                            <div class="input-group" id="confirmPasswordGroup">
                                <label for="confirmPassword" class="input-label">Confirm Password</label>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                    </svg>
                                    <asp:TextBox ID="confirmPassword" runat="server" ClientIDMode="Static"
                                        TextMode="Password" placeholder="Confirm your password" required="required">
                                    </asp:TextBox>
                                    <button type="button" class="password-toggle" id="confirmPasswordToggle"
                                        aria-label="Toggle confirm password visibility">
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

                            <asp:LinkButton ID="loginBtn" runat="server" ClientIDMode="Static" CssClass="login-btn"
                                OnClick="loginBtn_Click" style="margin-top: 10px;">
                                <span class="btn-text">Sign Up</span>
                                <span class="btn-arrow">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <line x1="5" y1="12" x2="19" y2="12" />
                                        <polyline points="12 5 19 12 12 19" />
                                    </svg>
                                </span>
                                <div class="btn-ripple"></div>
                            </asp:LinkButton>
                        </asp:Panel>

                        <!-- Email Verification Step -->
                        <asp:Panel ID="pnlVerifyCode" runat="server" Visible="false">
                            <div class="verify-step-info">
                                <div class="verify-icon-badge">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="28" height="28">
                                        <rect x="3" y="5" width="18" height="14" rx="2" ry="2" />
                                        <polyline points="3 7 12 13 21 7" />
                                    </svg>
                                </div>
                                <p class="verify-description">We've sent a 6-digit verification code to<br/>
                                    <strong><asp:Literal ID="litVerifyEmail" runat="server"></asp:Literal></strong>
                                </p>
                            </div>

                            <div class="input-group" id="codeGroup">
                                <label for="txtVerifyCode" class="input-label">Verification Code</label>
                                <div class="input-wrapper">
                                    <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="1.5">
                                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                    </svg>
                                    <asp:TextBox ID="txtVerifyCode" runat="server" ClientIDMode="Static"
                                        CssClass="verify-code-input"
                                        placeholder="Enter 6-digit code" MaxLength="6"></asp:TextBox>
                                </div>
                                <span class="verify-hint">Enter the 6-digit code sent to your email</span>
                            </div>

                            <asp:LinkButton ID="btnVerifyAndRegister" runat="server" ClientIDMode="Static" CssClass="login-btn"
                                OnClick="btnVerifyAndRegister_Click" style="margin-top: 10px;">
                                <span class="btn-text">Verify &amp; Create Account</span>
                                <span class="btn-arrow">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <line x1="5" y1="12" x2="19" y2="12" />
                                        <polyline points="12 5 19 12 12 19" />
                                    </svg>
                                </span>
                                <div class="btn-ripple"></div>
                            </asp:LinkButton>

                            <div style="text-align: center; margin-top: 12px;">
                                <asp:LinkButton ID="btnBackToSignup" runat="server" CssClass="verify-back-link"
                                    OnClick="btnBackToSignup_Click" CausesValidation="false">
                                    &larr; Back to Sign Up
                                </asp:LinkButton>
                            </div>
                        </asp:Panel>
                    </form>

                    <div class="divider">
                        <span class="divider-line"></span>
                        <span class="divider-text">or</span>
                        <span class="divider-line"></span>
                    </div>

                    <div class="form-footer">
                        <p class="footer-text">Already have an account?</p>
                        <a href="Default.aspx" class="register-btn" id="registerBtn">
                            <span>Login Now</span>
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
    </body>

    </html>
