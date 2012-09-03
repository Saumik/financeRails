$('.search-line-item-overlay').remove()

source = "<%= escape_javascript(render(:partial => 'search_overlay'))%>"
$('body').append(source)

$('.search-line-item-overlay').modal();
$('.search-line-item-overlay').centerModalInWindow();