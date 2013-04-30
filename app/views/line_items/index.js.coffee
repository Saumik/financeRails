content = '<%= escape_javascript(render(:partial => 'items'))%>'

$('#items_list tbody').html(content);
$(".month_selector li").removeClass('active')
$(".month_selector li[data-date=<%="#{params[:month]}#{params[:year]}"%>]").addClass('active')