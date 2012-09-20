$('.edit_modal_dialog').trigger('overlay:close')
$.event.trigger('financeRails:line-item-modified', <%==@response_params%>)