content = '<%= escape_javascript(render(:partial => 'new'))%>'
$(content).overlay({overlaySelector: '.new_modal_dialog'})
dlg = new financeRails.views.budgets.BudgetItemDlg({el: '.new_modal_dialog'});