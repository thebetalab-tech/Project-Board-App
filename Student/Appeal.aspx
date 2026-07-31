<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Appeal.aspx.cs" Inherits="Project_Board.Student.Appeal" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Appeal — Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --c-bg: #ffffff;
            --c-bg-warm: #fdfbf7;
            --c-surface: #f4f5f7;
            --c-border: #e2e8f0;
            --c-text: #1e293b;
            --c-text-muted: #64748b;
            --c-text-dim: #94a3b8;
            --c-accent: #2563eb;
            --c-accent-hover: #1d4ed8;
            --c-accent-glow: rgba(37, 99, 235, 0.15);
            --c-green: #059669;
            --c-red: #dc2626;
            --c-red-bg: #fef2f2;
            --c-green-bg: #ecfdf5;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --f-body: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        body {
            font-family: var(--f-body);
            background-color: var(--c-surface);
            color: var(--c-text);
            margin: 0;
            padding: 2rem;
            display: flex;
            justify-content: center;
        }

        .container {
            width: 100%;
            max-width: 800px;
            background: var(--c-bg);
            border-radius: 16px;
            box-shadow: var(--shadow-md);
            padding: 2.5rem;
            border: 1px solid var(--c-border);
        }

        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--c-border);
        }

        .header h1 {
            margin: 0;
            font-size: 1.5rem;
            color: var(--c-text);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .btn-back {
            color: var(--c-text-muted);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: color 0.2s;
        }

        .btn-back:hover {
            color: var(--c-text);
        }

        .task-card {
            background: var(--c-bg-warm);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .task-card h3 {
            margin: 0 0 0.5rem 0;
            font-size: 1.1rem;
            color: var(--c-accent);
        }

        .task-card p {
            margin: 0;
            color: var(--c-text-muted);
            font-size: 0.9rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--c-text);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            border: 1px solid var(--c-border);
            font-family: inherit;
            font-size: 0.95rem;
            transition: all 0.2s;
            box-sizing: border-box;
            background: var(--c-bg);
            color: var(--c-text);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--c-accent);
            box-shadow: 0 0 0 3px var(--c-accent-glow);
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 1rem;
            background: rgba(5, 150, 105, 0.05);
            border: 1px solid rgba(5, 150, 105, 0.2);
            border-radius: 8px;
            margin-bottom: 2rem;
            cursor: pointer;
        }

        .checkbox-group input[type="checkbox"] {
            width: 1.25rem;
            height: 1.25rem;
            accent-color: var(--c-green);
            cursor: pointer;
        }

        .checkbox-group label {
            margin: 0;
            cursor: pointer;
            font-weight: 600;
            color: var(--c-green);
        }

        .btn-submit {
            background-color: var(--c-accent);
            color: white;
            border: none;
            padding: 0.875rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            width: 100%;
            justify-content: center;
        }

        .btn-submit:hover {
            background-color: var(--c-accent-hover);
        }

        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .alert-danger {
            background-color: var(--c-red-bg);
            color: var(--c-red);
            border: 1px solid rgba(220, 38, 38, 0.2);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="header">
                <h1><i class="fa-solid fa-file-signature"></i> Submit Appeal</h1>
                <asp:LinkButton ID="btnBack" runat="server" CssClass="btn-back" OnClick="btnBack_Click"><i class="fa-solid fa-arrow-left"></i> Back to Dashboard</asp:LinkButton>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

            <div class="task-card">
                <h3><asp:Label ID="lblTaskTitle" runat="server"></asp:Label></h3>
                <p>Assigned By: <strong><asp:Label ID="lblAssignorName" runat="server"></asp:Label></strong></p>
                <div style="margin-top: 1rem;">
                    <strong style="color:var(--c-text); font-size:0.85rem; display:block; margin-bottom:0.25rem;">Feedback / Requirements:</strong>
                    <p><asp:Label ID="lblFeedback" runat="server"></asp:Label></p>
                </div>
            </div>

            <div class="form-group">
                <label>Appeal Message / Reason <span style="color:var(--c-red);">*</span></label>
                <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" Placeholder="Why are you submitting this appeal? Provide a brief summary of the status..."></asp:TextBox>
            </div>

            <div class="form-group">
                <label>What Changes Have You Made?</label>
                <asp:TextBox ID="txtChangesMade" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" Placeholder="List the exact code, design, or logic changes you made for this task..."></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Detailed Explanation</label>
                <asp:TextBox ID="txtExplanation" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" Placeholder="Explain your approach, any blockers you faced, and how you solved them..."></asp:TextBox>
            </div>

            <div class="checkbox-group">
                <asp:CheckBox ID="chkIsCompleted" runat="server" />
                <label for="chkIsCompleted">Mark Task as Actually Completed</label>
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit Appeal" CssClass="btn-submit" OnClick="btnSubmit_Click" />
        </div>
    </form>
</body>
</html>

