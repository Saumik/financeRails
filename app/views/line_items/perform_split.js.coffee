debugger
modal_class = '.split_form_area'
$(modal_class).modal('hide')

data = <%==@data_response.to_json%>

# draw splitted items
_(<%==@added_items.to_json%>).each (item) =>
  $('.main_table').prepend($(item))
  $('.main_table').find($(item).attr('id')).highlight()

# update edited item

if $('.main_table.dataTable').length > 0
  datatable = $('.main_table').dataTable();
  datatable.fnUpdateRawHTML(content, $('.main_table').find('[data-item-id=' + data.replace_id + ']').get(0), 0)
else
  $('.main_table').find('[data-item-id=' + data.replace_id + ']').replaceWith($(data.content))
$('.main_table').find('[data-item-id=' + data.replace_id + ']').highlight('fast');

