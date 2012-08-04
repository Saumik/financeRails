jQuery.fn.centerModalInWindow = function () {
    this.css({
        'position': 'fixed',
        'left': '50%',
        'top': '50%',
    });
    this.css({
        'margin-left': -this.width() / 2 + 'px',
        'margin-top': -this.height() / 2 + 'px'
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