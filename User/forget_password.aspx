<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="forget_password.aspx.cs" Inherits="Project_Board.User.forget_password" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Reset Password</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css" />
    <!-- Forget password specific style -->
    <link runat="server" rel="stylesheet" href="~/User/forget_password.css?v=2" />
    <style>
        html, body {
            height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            background-color: var(--c-bg-warm, #faf9f7) !important;
        }
        body {
            display: block !important;
        }
        form#form1 {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            min-height: 100vh !important;
            width: 100% !important;
            padding: 1.5rem !important;
            box-sizing: border-box !important;
            margin: 0 !important;
        }
        .forget-wrapper {
            width: 100% !important;
            max-width: 460px !important;
            margin: auto !important;
            background: var(--c-bg-card, #ffffff) !important;
            border: 1px solid var(--c-border, rgba(0, 0, 0, 0.08)) !important;
            border-radius: 20px !important;
            box-shadow: var(--shadow-lg, 0 12px 24px rgba(0,0,0,0.06)) !important;
            padding: 2.5rem 2rem !important;
            box-sizing: border-box !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" autocomplete="off">
        <div class="forget-wrapper">
            <div class="forget-header">
                <div class="forget-icon">
                    <i class="fa-solid fa-key"></i>
                </div>
                <h1 class="forget-title">
                    <asp:Literal ID="litTitle" runat="server" Text="Reset Password"></asp:Literal>
                </h1>
                <p class="forget-subtitle">
                    <asp:Literal ID="litSubtitle" runat="server" Text="Identify your account and verify with email code"></asp:Literal>
                </p>
            </div>

            <!-- Message Notification -->
            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="form-message"></asp:Label>

            <!-- STEP 1: Enter Email (only for non-logged-in users) -->
            <asp:Panel ID="pnlEmailStep" runat="server">
                <div class="form-group">
                    <label for="txtEmail">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="name@example.com" TextMode="Email" required="required"></asp:TextBox>
                </div>

                <div class="form-actions">
                    <asp:LinkButton ID="btnSendCode" runat="server" CssClass="btn-primary" OnClick="btnSendCode_Click">
                        <i class="fa-solid fa-paper-plane"></i> Send Verification Code
                    </asp:LinkButton>
                    
                    <div class="back-link-container">
                        <a href="<%= ResolveUrl("~/Default.aspx") %>" class="back-link">
                            <i class="fa-solid fa-arrow-left-long"></i> Back to Login
                        </a>
                    </div>
                </div>
            </asp:Panel>

            <!-- STEP 2: Enter Verification Code (only for non-logged-in users) -->
            <asp:Panel ID="pnlCodeStep" runat="server" Visible="false">
                <div class="step-info">
                    <div class="step-badge">
                        <i class="fa-solid fa-envelope-circle-check"></i>
                    </div>
                    <p class="step-description">We've sent a 6-digit code to <strong><asp:Literal ID="litEmailDisplay" runat="server"></asp:Literal></strong></p>
                </div>

                <div class="form-group">
                    <label for="txtCode">Verification Code</label>
                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control code-input" placeholder="Enter 6-digit code" required="required" MaxLength="6"></asp:TextBox>
                    <span class="hint-text">Enter the 6-digit code sent to your email.</span>
                </div>

                <div class="form-actions">
                    <asp:LinkButton ID="btnVerifyCode" runat="server" CssClass="btn-primary" OnClick="btnVerifyCode_Click">
                        <i class="fa-solid fa-shield-check"></i> Verify Code
                    </asp:LinkButton>
                    
                    <div class="back-link-container">
                        <asp:LinkButton ID="btnBackToEmail" runat="server" CssClass="back-link" OnClick="btnBackToEmail_Click" CausesValidation="false">
                            <i class="fa-solid fa-arrow-left-long"></i> Back to Email Step
                        </asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

            <!-- STEP 3: Set New Password (for both logged-in and verified non-logged-in users) -->
            <asp:Panel ID="pnlPasswordStep" runat="server" Visible="false">
                <div class="step-info">
                    <div class="step-badge step-badge--success">
                        <i class="fa-solid fa-lock-open"></i>
                    </div>
                    <p class="step-description">
                        <asp:Literal ID="litPasswordStepInfo" runat="server" Text="Set your new password below."></asp:Literal>
                    </p>
                </div>

                <div class="form-group">
                    <label for="txtNewPassword">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" placeholder="At least 8 characters" TextMode="Password" required="required"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label for="txtConfirmPassword">Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" placeholder="Confirm your new password" TextMode="Password" required="required"></asp:TextBox>
                </div>

                <div class="form-actions">
                    <asp:LinkButton ID="btnReset" runat="server" CssClass="btn-primary" OnClick="btnReset_Click">
                        <i class="fa-solid fa-circle-check"></i> Update Password
                    </asp:LinkButton>
                    
                    <div class="back-link-container">
                        <asp:LinkButton ID="btnBackFromPassword" runat="server" CssClass="back-link" OnClick="btnBackFromPassword_Click" CausesValidation="false">
                            <i class="fa-solid fa-arrow-left-long"></i> <asp:Literal ID="litBackText" runat="server" Text="Cancel"></asp:Literal>
                        </asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

            <!-- Progress Indicator -->
            <asp:Panel ID="pnlProgress" runat="server" CssClass="progress-dots">
                <span class="dot" id="dot1" runat="server"></span>
                <span class="dot" id="dot2" runat="server"></span>
                <span class="dot" id="dot3" runat="server"></span>
            </asp:Panel>

        </div>
    </form>
</body>
</html>
