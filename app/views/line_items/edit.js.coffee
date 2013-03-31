content = '<%= escape_javascript(render(:partial => 'edit'))%>'
$(content).overlay({overlaySelector: '.edit_modal_dialog'})
view = new financeRails.views.line_items.FormView({el: '.edit_modal_dialog'})
