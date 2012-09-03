modal_class = '.split_form_area'
$(modal_class).remove()

source = "<%= escape_javascript(render(:partial => 'split_form'))%>"
$('body').append($(source))

$(modal_class).modal();
$(modal_class).centerModalInWindow();
payees = <%== LineItem.payees.to_json %>
categories = <%==LineItem.categories.to_json %>
last_data_for_payee = <%==LineItem.all_last_data_for_payee.to_json%>
options = {payees:payees, categories: categories, last_data_for_payee: last_data_for_payee}
form_view = new financeRails.views.line_items.SplitFormView($.extend(options, {el: modal_class, amount_left: <%=@item.amount%>}))