content = '<%= escape_javascript(render(:partial => 'edit'))%>'
$(content).overlay({overlaySelector: '.edit_modal_dialog'})
dlg = new financeRails.views.budgets.BudgetItemDlg({el: '.edit_modal_dialog', active_categories: <%==@item.categories.to_json%>});