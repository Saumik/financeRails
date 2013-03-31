modal_class = '.split_form_area'
$(modal_class).remove()

source = "<%= escape_javascript(render(:partial => 'split_form'))%>"
$('body').append($(source))

$(modal_class).modal();
$(modal_class).centerModalInWindow();
form_view = new financeRails.views.line_items.SplitFormView({el: modal_class, amount_left: <%=@item.amount%>})