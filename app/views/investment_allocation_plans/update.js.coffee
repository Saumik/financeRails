$('.edit_modal_dialog').trigger('overlay:close')
$.event.trigger('financeRails:line-item-modified', <%==@response_params%>)

itemHTML = "<%= escape_javascript(render(partial: 'investment/tile_investment_allocation_plan', locals: {item: @item})) %>"
line_item_id = '<%=@item.id%>'
$('[data-item-id=' + line_item_id + ']').html(itemHTML);
$('[data-item-id=' + line_item_id + ']').highlight();