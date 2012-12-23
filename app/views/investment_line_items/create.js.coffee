data = "<%= escape_javascript(render(partial: 'item', locals: {item: @item})) %>"
line_item_id = '<%=@item.id%>'

$('.main_table').prepend(data)
$('[data-item-id=' + line_item_id + ']').highlight();