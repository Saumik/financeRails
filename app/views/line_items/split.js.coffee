modal_class = '.split_form_area'
$(modal_class).remove()

$('<%= escape_javascript(render(:partial => 'split'))%>')
  .appendTo('body')

$(modal_class).modal();
$(modal_class).centerModalInWindow();
form_view = new financeRails.views.line_items.SplitFormView($.extend(@options, {el: modal_class, amount_left: <%=@item.amount%>}))