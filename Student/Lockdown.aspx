<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Lockdown.aspx.cs" Inherits="Project_Board.Student.Lockdown" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Lockdown - Project Board</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --c-bg: #0f172a;
            --c-surface: #1e293b;
            --c-text: #f8fafc;
            --c-text-muted: #94a3b8;
            --c-red: #ef4444;
            --c-red-glow: rgba(239, 68, 68, 0.2);
            --font-main: 'Inter', system-ui, -apple-system, sans-serif;
        }

        body {
            background-color: var(--c-bg);
            color: var(--c-text);
            font-family: var(--font-main);
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            text-align: center;
            background-image: radial-gradient(circle at top right, var(--c-red-glow) 0%, transparent 40%);
        }

        .lockdown-container {
            background-color: var(--c-surface);
            padding: 3rem 2rem;
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            max-width: 500px;
            width: 90%;
            border: 1px solid rgba(239, 68, 68, 0.3);
            position: relative;
            overflow: hidden;
        }

        .lockdown-container::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, transparent, var(--c-red), transparent);
        }

        .icon-wrapper {
            width: 80px;
            height: 80px;
            background-color: rgba(239, 68, 68, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            color: var(--c-red);
            font-size: 2.5rem;
            box-shadow: 0 0 20px var(--c-red-glow);
        }

        h1 {
            font-size: 1.75rem;
            margin: 0 0 1rem;
            letter-spacing: -0.025em;
            color: white;
        }

        p {
            color: var(--c-text-muted);
            line-height: 1.6;
            margin: 0 0 2rem;
            font-size: 1rem;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background-color: rgba(239, 68, 68, 0.15);
            color: var(--c-red);
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            border: 1px solid rgba(239, 68, 68, 0.3);
            margin-bottom: 2rem;
        }

        .btn-home {
            display: inline-block;
            background-color: transparent;
            color: var(--c-text);
            text-decoration: none;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            border: 1px solid var(--c-text-muted);
            transition: all 0.2s ease;
        }

        .btn-home:hover {
            background-color: rgba(255, 255, 255, 0.05);
            border-color: white;
            color: white;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="lockdown-container">
            <div class="icon-wrapper">
                <i class="fa-solid fa-lock"></i>
            </div>
            
            <div class="status-badge">
                <i class="fa-solid fa-ban"></i>
                ACCOUNT IN LOCKDOWN
            </div>

            <h1>Your Group is Deactivated</h1>
            <p>Your associated group has been disabled by the Administrator. During this time, your ID is in lockdown status. You cannot access group features, join another group, or create a new one until the Admin reactivates your current group.</p>
            
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="btn-home" OnClick="btnLogout_Click">
                <i class="fa-solid fa-sign-out-alt" style="margin-right: 0.5rem;"></i> Logout
            </asp:LinkButton>
        </div>
    </form>
</body>
</html>
