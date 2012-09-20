# Overlay plugin
# Currently uses modal from twitter bootstrap
#
# Required parameters:
# overlaySelector: the selector of the overlay

$ = jQuery
$.fn.overlay = (options) ->
  options = $.extend(defaults, options)
  defaults =
    overlaySelector: '#overlay'

  options = $.extend(defaults, options)

  overlayIndex = 0
  $el = null
  $glass = null

  closeOverlay = (e) ->
    $el.remove();
    $glass.trigger('glass:close')

  @each ->
    $(options.overlaySelector).remove();

    overlayIndex = $('.overlay').length

    $el = $(this)
    $('body').append($el)

    # set classes
    $el.removeClass('hide')
    $el.addClass('overlay')

    # set z-index
    $el.css('z-index', 1000+(overlayIndex*10))
    $glass = $('body').glass({zIndex: 1000+(overlayIndex*10)-5, onClickGlass: closeOverlay})

    # center
    $el.centerModalInWindow();

    # subscribe to events
    $el.bind('overlay:close', closeOverlay)
    $el.find('[data-dismiss="modal"]').click(closeOverlay)
