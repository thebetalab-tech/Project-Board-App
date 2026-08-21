<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="Project_Board.SignUp" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Project Board - Sign up for your project management dashboard.">
    <title>Project Board - Sign Up</title>
    <link rel="icon" href="favicon.ico" type="image/x-icon" />
    <link rel="stylesheet" href="styles/login-signup.css?v=20260724" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .verify-step-info { text-align: center; margin-bottom: 1.5rem; }
        .verify-icon-badge { display: inline-flex; align-items: center; justify-content: center; width: 56px; height: 56px; border-radius: 50%; background: var(--c-ring); color: var(--c-primary); margin-bottom: 1rem; }
        .resend-otp-area { text-align: center; margin-top: 1rem; font-size: 0.875rem; color: var(--c-text-muted); }
        .resend-otp-link { color: var(--c-primary); font-weight: 600; text-decoration: none; }
        .resend-otp-link--disabled { opacity: 0.5; pointer-events: none; }
        .verify-back-link { font-size: 0.875rem; color: var(--c-text-muted); font-weight: 500; text-decoration: none; }
        .verify-back-link:hover { color: var(--c-primary); }
    </style>
</head>

<body>
    <div class="auth-layout">
        <div class="auth-brand">
            <h1 class="auth-brand-title">Project Board</h1>
            <p class="auth-brand-tagline">Organize. Track. Collaborate.</p>
        </div>

        <div class="auth-card">
            <div class="auth-header">
                <h2 class="auth-title">Create Account</h2>
                <p class="auth-subtitle">Join Project Board today</p>
            </div>

            <form id="signupForm" runat="server" autocomplete="off">
                <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="error-message text-center mb-4"></asp:Label>

                <!-- Signup Form Fields -->
                <asp:Panel ID="pnlSignupForm" runat="server">
                    <div class="form-grid">
                        <div class="input-group" id="nameGroup" style="grid-column: 1 / -1;">
                        <label for="fullName" class="input-label">Full Name</label>
                        <div class="input-wrapper">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                <circle cx="12" cy="7" r="4" />
                            </svg>
                            <asp:TextBox ID="fullName" runat="server" ClientIDMode="Static" CssClass="form-input" placeholder="Enter your full name" required="required"></asp:TextBox>
                        </div>
                        <asp:Label ID="lblFullNameError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                    </div>

                    <div class="input-group" id="emailGroup">
                        <label for="loginId" class="input-label">Email Address</label>
                        <div class="input-wrapper">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="5" width="18" height="14" rx="2" ry="2" />
                                <polyline points="3 7 12 13 21 7" />
                            </svg>
                            <asp:TextBox ID="loginId" runat="server" ClientIDMode="Static" CssClass="form-input" TextMode="Email" placeholder="Enter your email" required="required"></asp:TextBox>
                        </div>
                        <asp:Label ID="lblEmailError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                    </div>

                    <div class="input-group" id="enrollmentGroup">
                        <label for="enrollment" class="input-label">Enrollment Number</label>
                        <div class="input-wrapper">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
                                <line x1="8" y1="21" x2="16" y2="21" />
                                <line x1="12" y1="17" x2="12" y2="21" />
                            </svg>
                            <asp:TextBox ID="enrollment" runat="server" ClientIDMode="Static" CssClass="form-input" placeholder="Enter your enrollment number" required="required"></asp:TextBox>
                        </div>
                        <asp:Label ID="lblEnrollmentError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                    </div>

                    <div class="input-group" id="passwordGroup">
                        <label for="password" class="input-label">Password</label>
                        <div class="input-wrapper">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                            </svg>
                            <asp:TextBox ID="password" runat="server" ClientIDMode="Static" CssClass="form-input" TextMode="Password" placeholder="Create a password" required="required"></asp:TextBox>
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

                    <div class="input-group" id="confirmPasswordGroup">
                        <label for="confirmPassword" class="input-label">Confirm Password</label>
                        <div class="input-wrapper">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                            </svg>
                            <asp:TextBox ID="confirmPassword" runat="server" ClientIDMode="Static" CssClass="form-input" TextMode="Password" placeholder="Confirm your password" required="required"></asp:TextBox>
                            <button type="button" class="password-toggle" id="confirmPasswordToggle" aria-label="Toggle confirm password visibility">
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
                        <asp:Label ID="lblConfirmPasswordError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                    </div>
                    </div>

                    <asp:LinkButton ID="loginBtn" runat="server" ClientIDMode="Static" CssClass="btn-primary mt-4" OnClick="loginBtn_Click">
                        <span class="btn-text">Sign Up</span>
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
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                            </svg>
                            <asp:TextBox ID="txtVerifyCode" runat="server" ClientIDMode="Static" CssClass="form-input text-center" placeholder="Enter 6-digit code" MaxLength="6" style="letter-spacing: 0.25rem; font-weight: 600; font-size: 1.1rem; padding-left: 1rem;"></asp:TextBox>
                        </div>
                        <asp:Label ID="lblCodeError" runat="server" CssClass="error-message" EnableViewState="false"></asp:Label>
                    </div>

                    <div class="resend-otp-area" id="resendOtpArea">
                        <span class="resend-timer" id="resendTimer">Resend code in <strong id="resendCountdown">01:00</strong></span>
                        <asp:LinkButton ID="btnResendOtp" runat="server" ClientIDMode="Static" CssClass="resend-otp-link resend-otp-link--disabled" OnClick="btnResendOtp_Click" CausesValidation="false">Resend Code</asp:LinkButton>
                    </div>

                    <asp:LinkButton ID="btnVerifyAndRegister" runat="server" ClientIDMode="Static" CssClass="btn-primary mt-4" OnClick="btnVerifyAndRegister_Click">
                        <span class="btn-text">Verify &amp; Create Account</span>
                    </asp:LinkButton>

                    <div style="text-align: center; margin-top: 1rem;">
                        <asp:LinkButton ID="btnBackToSignup" runat="server" CssClass="verify-back-link" OnClick="btnBackToSignup_Click" CausesValidation="false">
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
                <p>Already have an account? <a href='<%= ResolveUrl("~/Default.aspx") %>'>Login Now</a></p>
            </div>
        </div>
    </div>

    <script src="Scripts/main/login-signup.js?v=20260723_v3"></script>
    <script>
        (function () {
            var COOLDOWN = 60;
            var timerSpan = document.getElementById('resendTimer');
            var countdownEl = document.getElementById('resendCountdown');
            var resendBtn = document.getElementById('btnResendOtp');

            if (!timerSpan || !countdownEl || !resendBtn) return;

            var remaining = COOLDOWN;
            function pad(n) { return n < 10 ? '0' + n : '' + n; }
            function updateDisplay() {
                var mins = Math.floor(remaining / 60);
                var secs = remaining % 60;
                countdownEl.textContent = pad(mins) + ':' + pad(secs);
            }
            function enableResend() {
                timerSpan.style.display = 'none';
                resendBtn.style.display = 'inline';
                resendBtn.classList.remove('resend-otp-link--disabled');
                resendBtn.style.pointerEvents = 'auto';
                resendBtn.style.opacity = '1';
            }
            function startTimer() {
                remaining = COOLDOWN;
                timerSpan.style.display = 'inline';
                resendBtn.style.display = 'none';
                resendBtn.classList.add('resend-otp-link--disabled');
                resendBtn.style.pointerEvents = 'none';
                resendBtn.style.opacity = '0.4';
                updateDisplay();

                var interval = setInterval(function () {
                    remaining--;
                    if (remaining <= 0) {
                        clearInterval(interval);
                        enableResend();
                    } else {
                        updateDisplay();
                    }
                }, 1000);
            }
            startTimer();
        })();
    </script>
</body>
</html>
