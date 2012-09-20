$ = jQuery
$.fn.glass = (options) ->
  defaults =
    glassClass: 'modal-backdrop'
    zIndex: 1000
    closeOnClick: true

  options = $.extend(defaults, options)
  $el = null

  onClickGlass = (e) ->
    options.onClickGlass(e, $el)

  closeGlass = (e) ->
    $(this).remove()

  $el = $('<div class="' + options.glassClass + '"></div>')
  $('body').append($el)
  $el.click(onClickGlass)
  $el.bind('glass:close', closeGlass)
  $el.css('z-index', options.zIndex)
  $el