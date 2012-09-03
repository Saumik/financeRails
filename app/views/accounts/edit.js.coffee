$('.edit_account_area').remove()

$('<%= escape_javascript(render(:partial => 'edit'))%>')
  .appendTo('body')

$('.edit_account_area').modal();
$('.edit_account_area').centerModalInWindow();