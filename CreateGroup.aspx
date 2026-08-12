<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateGroup.aspx.cs" Inherits="Project_Board.CreateGroup" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board — Create Group</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="styles/login-signup.css?v=20260724" />
    <style>
        .user-info-badge {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: var(--c-input-bg);
            border: 1px solid var(--c-border);
            border-radius: var(--radius-md);
            margin-bottom: 2rem;
        }
        .user-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: var(--c-ring);
            color: var(--c-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.125rem;
            flex-shrink: 0;
        }
        .user-details {
            display: flex;
            flex-direction: column;
            text-align: left;
        }
        .user-name {
            font-weight: 600;
            color: var(--c-foreground);
            font-size: 1rem;
        }
        .user-roll {
            font-size: 0.8125rem;
            color: var(--c-text-muted);
            margin-top: 0.125rem;
        }
        .select-chevron {
            position: absolute;
            right: 1rem;
            width: 18px;
            height: 18px;
            color: #94A3B8;
            pointer-events: none;
        }
        select.form-input {
            appearance: none;
            cursor: pointer;
            padding-right: 2.75rem;
        }
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            color: var(--c-text-muted);
            font-weight: 500;
            text-decoration: none;
            transition: color var(--transition);
        }
        .back-link:hover {
            color: var(--c-primary);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="auth-layout" style="max-width: 480px;">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="auth-brand">
            <div class="auth-brand-logo">
                <i class="fa-solid fa-cubes-stacked"></i>
            </div>
            <h1 class="auth-brand-title">Project Board</h1>
            <p class="auth-brand-tagline">Organize. Track. Collaborate.</p>
        </div>

        <div class="auth-card">
            <div class="auth-header">
                <h2 class="auth-title">Create Group</h2>
                <p class="auth-subtitle">Initialize your project team</p>
            </div>

            <div class="user-info-badge">
                <div class="user-avatar">
                    <i class="fa-solid fa-user-tie"></i>
                </div>
                <div class="user-details">
                    <span class="user-name">Group Leader</span>
                    <span class="user-roll">Ready to create a new team</span>
                </div>
            </div>

            <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="error-message text-center mb-4" style="display:block;"></asp:Label>

            <div>
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
                                <asp:TextBox ID="txtGroupName" runat="server" ClientIDMode="Static" CssClass="form-input" placeholder="e.g. Beta Lab Core Team" required="required" AutoPostBack="true" OnTextChanged="txtGroupName_TextChanged"></asp:TextBox>
                            </div>
                            <asp:Label ID="lblNameStatus" runat="server" CssClass="error-message"></asp:Label>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

                <div class="input-group">
                    <label for="ddlTechDomain" class="input-label">Technology Domain</label>
                    <div class="input-wrapper">
                        <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
                            <line x1="8" y1="21" x2="16" y2="21" />
                            <line x1="12" y1="17" x2="12" y2="21" />
                        </svg>
                        
                        <asp:DropDownList ID="ddlTechDomain" runat="server" ClientIDMode="Static" CssClass="form-input" required="required" AppendDataBoundItems="true">
                            <asp:ListItem Value="" Text="Select primary technology" disabled="disabled" Selected="True"></asp:ListItem>
                        </asp:DropDownList>
                        
                        <svg class="select-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="6 9 12 15 18 9" />
                        </svg>
                    </div>
                </div>

                <asp:LinkButton ID="btnCreateGroup" runat="server" CssClass="btn-primary mt-6" OnClick="btnCreateGroup_Click">
                    <span class="btn-text">Create Group</span>
                </asp:LinkButton>
            </div>
            
            <div class="form-footer mt-6">
                <a href='<%= ResolveUrl("~/OnBoarding.aspx") %>' class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Back
                </a>
            </div>
        </div>
    </form>
    <script src='<%= ResolveUrl("~/Scripts/main/login-signup.js?v=20260723_v3") %>'></script>
</body>
</html>
