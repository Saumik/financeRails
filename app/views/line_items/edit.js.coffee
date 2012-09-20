payees = <%== LineItem.payees.to_json %>
last_data_for_payee = <%== LineItem.all_last_data_for_payee.to_json %>
categories = <%== LineItem.categories.to_json %>


content = '<%= escape_javascript(render(:partial => 'edit'))%>'
$(content).overlay({overlaySelector: '.edit_modal_dialog'})
view = new financeRails.views.line_items.FormView($.extend({payees: payees, categories: categories, last_data_for_payee: last_data_for_payee}, {el: '.edit_modal_dialog'}))
