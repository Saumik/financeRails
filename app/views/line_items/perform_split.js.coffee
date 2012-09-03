modal_class = '.split_form_area'
$(modal_class).modal('hide')

replace_id = "<%=@item.id.to_s%>"
content = "<%=escape_javascript(@content)%>"

# draw splitted items
_(<%==@added_items.to_json%>).each (item) =>
  $('.main_table').prepend($(item))
  $('.main_table').find($(item).attr('id')).highlight()

# update edited item

datatable = $('.main_table').dataTable()
if datatable
  datatable.fnUpdateRawHTML(content, $('.main_table').find('[data-item-id=' + replace_id + ']').get(0), 0)
else
  $('.main_table').find('[data-item-id=' + data.replace_id + ']').replace(content)
$('.main_table').find('[data-item-id=' + data.replace_id + ']').highlight('fast');

