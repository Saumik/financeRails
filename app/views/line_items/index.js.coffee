content = '<%= escape_javascript(render(:partial => 'items'))%>'

$('#items_list tbody').html(content);