jQuery.fn.centerModalInWindow = function () {
    if($(this).hasClass('auto-resize')) {
        $(this).css('width', $(window).width() - 200);
    }
    var top = (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop();
    var left = ($(window).width() - $(this).outerWidth()) / 2;
    this.css({
        'position': 'absolute',
        'left': left < 0 ? 0 : left,
        'top': top < 30 ? 30 : top,
        'margin': 0
    });
    return this;
}
jQuery.fn.highlight = function() {
    var o = $(this[0])

    o.effect('highlight', {}, 3000)
}

jQuery.fn.fadeOut= function() {
    var o = $(this[0])

    o.effect('fadeOut', {}, 3000)
}