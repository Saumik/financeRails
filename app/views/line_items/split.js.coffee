modal_class = '.split_form_area'
$(modal_class).remove()

source = "<%= escape_javascript(render(:partial => 'split_form'))%>"
$('body').append($(source))

$(modal_class).modal();
$(modal_class).centerModalInWindow();
payees = <%== current_user.payees.to_json %>
categories = <%==current_user.categories.to_json %>
last_data_for_payee = <%==current_user.all_last_data_for_payee.to_json%>
options = {payees:payees, categories: categories, last_data_for_payee: last_data_for_payee}
form_view = new financeRails.views.line_items.SplitFormView($.extend(options, {el: modal_class, amount_left: <%=@item.amount%>}))