window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.budgets ||= {}

class window.financeRails.views.budgets.BudgetView extends Backbone.View
  el: 'body'
  #events:

  initialize: (options) ->
    _.bindAll @
    @render()

  render: ->
    $('.inner-nav .budgets').addClass('active')
    $('.categories_popover').popover({trigger: 'hover'});

  closeNearestModal: (e) ->
    $(e.target).closest('.modal').modal('hide')
    window.location.reload();
