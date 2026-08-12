<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RejectionForm.aspx.cs" Inherits="Project_Board.Faculty.RejectionForm" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>Provide Rejection Reason</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .rejection-container { max-width: 600px; margin: 40px auto; padding: 30px; background: var(--c-bg-card); border-radius: 12px; box-shadow: var(--shadow-lg); border: 1px solid var(--c-border); }
        .rejection-header h2 { font-size: 1.5rem; color: var(--c-text); margin-bottom: 5px; }
        .rejection-header p { color: var(--c-text-muted); margin-bottom: 20px; font-size: 0.9rem; }
        .form-group label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 0.9rem; }
        .form-control { width: 100%; padding: 12px; border: 1px solid var(--c-border); border-radius: 8px; font-family: var(--f-body); resize: vertical; min-height: 120px; }
        .actions { margin-top: 20px; display: flex; justify-content: flex-end; gap: 10px; }
        .btn-cancel { background: var(--c-surface); color: var(--c-text); border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; text-decoration: none; font-weight: 500; font-size: 0.9rem; }
        .btn-submit { background: var(--c-red); color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 0.9rem; }
    </style>
</head>
<body style="background:var(--c-bg-elevated); display:flex; align-items:center; justify-content:center; min-height:100vh;">
    <form id="form1" runat="server" style="width:100%;">
        <div class="rejection-container">
            <div class="rejection-header">
                <h2>Reject <asp:Literal ID="litType" runat="server"></asp:Literal></h2>
                <p>Please provide a detailed reason or required changes. This will be visible to the students.</p>
            </div>
            
            <asp:Label ID="lblError" runat="server" ForeColor="Red" Visible="false" style="display:block; margin-bottom:15px; font-size:0.9rem;"></asp:Label>
            
            <div class="form-group">
                <label>Reason / Changes Required</label>
                <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" CssClass="form-control" placeholder="Explain why this is being rejected..."></asp:TextBox>
            </div>
            
            <div class="actions">
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn-cancel" OnClick="btnCancel_Click">Cancel</asp:LinkButton>
                <asp:Button ID="btnSubmit" runat="server" CssClass="btn-submit" Text="Confirm Rejection" OnClick="btnSubmit_Click" />
            </div>
        </div>
    </form>
</body>
</html>
