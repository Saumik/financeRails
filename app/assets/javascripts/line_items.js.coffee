window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.LineItemsView extends Backbone.View
  el: '.line_items_section'
  domain: financeRails.views.line_items
  #events:

  initialize: (options) ->
    _.bindAll @
    if @$el.hasClass('index')
      @inner_view = new @domain.IndexView(options);
      @active_selector = 'index'
    else if(@$el.hasClass('report'))
      @inner_view = new @domain.ReportView(options);
      @active_selector = 'report'
    @render()

  render: ->
    $('.inner-nav .' + @active_selector).addClass('active')