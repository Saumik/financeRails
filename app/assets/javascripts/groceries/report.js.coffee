class ReportView extends Backbone.View
  el: '.report'
  #events:

  initialize: (options) ->
    _.bindAll @
    @render()

  render: ->
    number_of_columns = @$el.find('table thead th').length
    @$el.find('.store_name').attr('colspan', number_of_columns)

window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.groceries ||= {}
window.financeRails.views.groceries.ReportView = ReportView