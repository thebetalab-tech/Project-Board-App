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
    <link rel="stylesheet" href="../Admin/admin.css">
    <!-- Forget password specific style -->
    <link rel="stylesheet" href="forget_password.css">
</head>
<body>
    <form id="form1" runat="server" autocomplete="off">
        <div class="forget-wrapper">
            <div class="forget-header">
                <div class="forget-icon">
                    <i class="fa-solid fa-key"></i>
                </div>
                <h1 class="forget-title">Reset Password</h1>
                <p class="forget-subtitle">Identify your account and verify with email code</p>
            </div>

            <!-- Message Notification -->
            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="form-message"></asp:Label>

            <!-- STEP 1: Enter Email -->
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
                        <a href="../Default.aspx" class="back-link">
                            <i class="fa-solid fa-arrow-left-long"></i> Back to Login
                        </a>
                    </div>
                </div>
            </asp:Panel>

            <!-- STEP 2: Enter Verification Code & New Password -->
            <asp:Panel ID="pnlVerificationStep" runat="server" Visible="false">
                <div class="form-group">
                    <label for="txtCode">Verification Code</label>
                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" placeholder="Enter 6-digit code" required="required" MaxLength="6"></asp:TextBox>
                    <span class="hint-text">Enter the 6-digit random code sent to your email.</span>
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
                        <i class="fa-solid fa-circle-check"></i> Reset & Log In
                    </asp:LinkButton>
                    
                    <div class="back-link-container">
                        <asp:LinkButton ID="btnBackToEmail" runat="server" CssClass="back-link" OnClick="btnBackToEmail_Click" CausesValidation="false">
                            <i class="fa-solid fa-arrow-left-long"></i> Back to Email Step
                        </asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>
