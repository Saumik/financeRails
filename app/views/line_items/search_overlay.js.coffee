$('.search-line-item-overlay').remove()

$('<%= escape_javascript(render(:partial => 'search_overlay'))%>')
  .appendTo('body')

$('.search-line-item-overlay').modal();
$('.search-line-item-overlay').centerModalInWindow();