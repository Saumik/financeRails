window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.SearchLineItems extends Backbone.View
  el: 'body'
  events:
    'click .open-search-line-items': 'onOpenSearchLineItems'
  initialize: (options) ->
