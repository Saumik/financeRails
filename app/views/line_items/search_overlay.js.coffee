source = "<%= escape_javascript(render(:partial => 'search_overlay'))%>"
$(source).overlay({overlaySelector: '.search-line-item-overlay'});
view = new financeRails.views.line_items.SearchLineItems()