window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.SearchLineItems extends Backbone.View
  el: 'body'
  events:
    'financeRails:line-item-modified': 'onLineItemModified'

  initialize: (options) ->

  onLineItemModified: (e, data) ->
    $('[data-item-id=' + data.replace_id + ']', @$el).replaceWith(data.content)
    $('[data-item-id=' + data.replace_id + ']', @$el).highlight('fast')

