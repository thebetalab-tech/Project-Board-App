<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_TechManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_TechManagement" MasterPageFile="~/Admin/Admin.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard — Technologies
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="dashboard-container">
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Technologies Master</h1>
                        <p>Manage the list of approved technologies for projects.</p>
                    </div>

                </div>

                <div class="data-section" style="max-width: 600px;">
                    <div class="section-header">
                        <h2>Available Technologies</h2>
                        <div class="search-bar" style="width: 250px;">
                            <i class="fa-solid fa-search"></i>
                            <input type="text" id="searchTechs" placeholder="Filter tech...">
                        </div>
                    </div>
                    <table id="techsTable">
                        <thead>
                            <tr>
                                <th>Tech ID</th>
                                <th>Technology Name</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptTechs" runat="server" OnItemCommand="rptTechs_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td>#<%# Eval("TechId") %></td>
                                        <td><strong><%# Eval("TechName") %></strong></td>
                                        <td style="text-align: right;">
                                            <div class="table-actions" style="justify-content: flex-end;">
                                                <button type="button" class="icon-btn edit" onclick="openEditTechModal('<%# Eval("TechId") %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("TechName").ToString()) %>')" style="color:var(--c-primary); background:none; border:none; cursor:pointer;">
                                                    <i class="fa-solid fa-edit"></i>
                                                </button>
                                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn delete" CommandName="DeleteTech" CommandArgument='<%# Eval("TechId") %>' OnClientClick="return confirm('Are you sure you want to delete this technology?');">
                                                    <i class="fa-solid fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <div style="padding: 1.5rem; background-color: var(--c-bg-elevated); border-top: 1px solid var(--c-border);">
                        <div style="display: flex; gap: 1rem; align-items: center;">
                            <div style="flex: 1;">
                                <asp:TextBox ID="txtNewTech" runat="server" CssClass="form-control" placeholder="New Technology Name..."></asp:TextBox>
                            </div>
                            <asp:Button ID="btnAddTech" runat="server" Text="Add Technology" CssClass="btn-primary" OnClick="btnAddTech_Click" />
                        </div>
                        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" style="display:block; margin-top: 0.75rem; font-weight: 500;"></asp:Label>
                    </div>
                </div>

                <div class="data-section" style="max-width: 800px; margin-top: 2rem;">
                    <div class="section-header">
                        <h2>Assign Technology to Faculty</h2>
                    </div>
                    
                    <div style="padding: 1.5rem; background-color: var(--c-bg-elevated); border-radius: 8px; border: 1px solid var(--c-border); margin-bottom: 2rem;">
                        <div style="display: flex; gap: 1rem; align-items: flex-end;">
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label>Faculty Member</label>
                                <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label>Technology</label>
                                <asp:DropDownList ID="ddlTech" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>
                            <asp:Button ID="btnAssign" runat="server" Text="Assign" CssClass="btn-primary" OnClick="btnAssign_Click" />
                        </div>
                        <asp:Label ID="lblAssignMessage" runat="server" EnableViewState="false" style="display:block; margin-top: 1rem; font-weight: 500;"></asp:Label>
                    </div>

                    <div class="section-header">
                        <h2>Current Assignments</h2>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Faculty Name</th>
                                <th>Assigned Technology</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptFacultyTech" runat="server" OnItemCommand="rptTechs_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("FacultyName") %></strong></td>
                                        <td><%# Eval("TechName") %></td>
                                        <td style="text-align: right;">
                                            <asp:LinkButton ID="btnDeleteAssign" runat="server" CssClass="icon-btn delete" CommandName="DeleteAssignment" CommandArgument='<%# Eval("FacultyId") + "|" + Eval("TechId") %>' OnClientClick="return confirm('Are you sure you want to remove this assignment?');">
                                                <i class="fa-solid fa-trash"></i>
                                            </asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
    <!-- Edit Tech Modal -->
    <div class="modal-overlay" id="editTechModal">
        <div class="modal-content" style="max-width:400px;">
            <div class="modal-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
                <h2 style="margin:0;">Edit Technology</h2>
                <button type="button" class="close-btn" onclick="closeModal('editTechModal')" style="background:none; border:none; font-size:1.25rem; cursor:pointer;"><i class="fa-solid fa-times"></i></button>
            </div>
            <asp:HiddenField ID="hdnEditTechId" runat="server" />
            <div class="form-group" style="margin-top:1rem; display:flex; flex-direction:column; gap:0.5rem;">
                <label style="font-weight:600; font-size:0.85rem;">Technology Name</label>
                <asp:TextBox ID="txtEditTechName" runat="server" CssClass="form-control" style="padding:0.6rem; border-radius:8px; border:1px solid var(--c-border);"></asp:TextBox>
            </div>
            <div style="text-align: right; margin-top: 1.5rem; display:flex; justify-content:flex-end; gap:1rem;">
                <button type="button" class="btn-secondary" onclick="closeModal('editTechModal')" style="padding:0.6rem 1rem;">Cancel</button>
                <asp:Button ID="btnUpdateTech" runat="server" Text="Save Changes" CssClass="btn-primary" OnClick="btnUpdateTech_Click" style="padding:0.6rem 1rem;" />
            </div>
        </div>
    </div>

        </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchTechs', 'techsTable');
        });
        function openEditTechModal(id, name) {
            document.getElementById('<%= hdnEditTechId.ClientID %>').value = id;
            document.getElementById('<%= txtEditTechName.ClientID %>').value = name;
            document.getElementById('editTechModal').classList.add('active');
        }
        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }
    </script>
</asp:Content>
