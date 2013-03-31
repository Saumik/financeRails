$('.edit_modal_dialog').trigger('overlay:close')
$('#items_list').find('[data-item-id=<%=@response_params[:replace_id]%>]').replaceWith('<%==escape_javascript(@response_params[:content])%>')
$('#items_list').find('[data-item-id=<%=@response_params[:replace_id]%>]').highlight()