window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.report ||= {}

class window.financeRails.views.report.ReportView extends Backbone.View
  el: 'body'
  #events:

  initialize: ->
    _.bindAll @
    @render()

  render: ->
    $('.inner-nav .report').addClass('active')
    $('tr.total').first().find('td').css('border-top', '1px solid #999');
