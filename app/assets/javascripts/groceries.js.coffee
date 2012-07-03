class GroceriesView extends Backbone.View
  el: '.groceries_section'
  #events:

  initialize: (options) ->
    _.bindAll @
    if @$el.hasClass('index')
      @inner_view = new financeRails.views.groceries.IndexView(options);
      @active_selector = 'index'
    else if(@$el.hasClass('report'))
      @inner_view = new financeRails.views.groceries.ReportView(options);
      @active_selector = 'report'
    @render()

  render: ->
    $('.inner-nav .' + @active_selector).addClass('active')
window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.GroceriesView = GroceriesView