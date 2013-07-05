content = '<%= escape_javascript(render(:partial => 'new'))%>'
$(content).overlay({overlaySelector: '.new_modal_dialog'})