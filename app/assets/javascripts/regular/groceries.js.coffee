window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.groceries ||= {}

class window.financeRails.views.GroceriesView extends Backbone.View
  el: '.groceries_section'
  domain: financeRails.views.groceries
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