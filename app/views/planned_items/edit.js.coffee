content = '<%= escape_javascript(render(:partial => 'edit'))%>'
$(content).overlay({overlaySelector: '.edit_modal_dialog'})
view = new financeRails.views.line_items.FormView($.extend({payees: payees, categories: categories, last_data_for_payee: last_data_for_payee}, {el: '.edit_modal_dialog'}))
