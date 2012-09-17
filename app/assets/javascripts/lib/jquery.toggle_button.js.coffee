# Toggle Button, uses icon plus and minus to expand other items
# Mark the items to expand using data-expand
# Mark the items matching the above, using data-child-of
#
# Icon will be added only if there are actually child elements present in the document
#
# Requirements:
# Class .hidden to allow hiding elements in advance
# http://programmers.stackexchange.com/questions/125893/when-should-i-use-a-css-class-over-inline-styling
#
# Example:
# <a class="categories_toggle" expand="Children">
# <ul class="hidden" data-child-of="Children"><li>Children 1</li></ul>
#
# Options
# context - to limit search scope

$ = jQuery
$.fn.toggleButton = (options) ->
  defaults =
    plusIconClass: 'icon-plus-sign'
    minusIconClass : 'icon-minus-sign'
    context: 'body'

  options = $.extend(defaults, options)
  $el = $(options.context)

  # Event handlers
  onClickToggle = (e) ->
    expand = $(this).data('expand')
    if $(this).hasClass(options.plusIconClass)
      $('.child_row[data-child_of=' + expand + ']', $el).removeClass('hidden')
      $(this).removeClass(options.plusIconClass).addClass(options.minusIconClass)
    else
      $('.child_row[data-child_of=' + expand + ']', $el).addClass('hidden')
      $(this).removeClass(options.minusIconClass).addClass(options.plusIconClass)

  @each ->
    expand = $(this).data('expand')
    if($('.child_row[data-child_of=' + expand + ']', $el).length > 0)
      $(this).bind('click', onClickToggle)
      $(this).addClass(options.plusIconClass)