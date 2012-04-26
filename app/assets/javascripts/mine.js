jQuery.fn.highlight = function() {
    var o = $(this[0])
    
    o.effect('highlight', {}, 3000)
}

jQuery.fn.fadeOut= function() {
    var o = $(this[0])

    o.effect('fadeOut', {}, 3000)
}