data = <%==@data_response.to_json%>
$('[data-item-id=' + data.remove_id + ']').remove();