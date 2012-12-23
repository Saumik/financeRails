$('.edit_modal_dialog').trigger('overlay:close')
$.event.trigger('financeRails:line-item-modified', <%==@response_params%>)

data = "<%= escape_javascript(render(partial: 'item', locals: {item: @item})) %>"
line_item_id = '<%=@item.id%>'
$('[data-item-id=' + line_item_id + ']').replaceWith(data);
$('[data-item-id=' + line_item_id + ']').highlight();