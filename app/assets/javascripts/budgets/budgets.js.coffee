window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.budgets ||= {}

class window.financeRails.views.budgets.BudgetView extends Backbone.View
  el: 'body'
  events:
    'click .open_create_budget_item': 'onOpenCreateBudgetItem'

  initialize: ->
    _.bindAll @
    @render()

  render: ->
    $('.inner-nav .budgets').addClass('active')

  onOpenCreateBudgetItem: (e) ->
    dlg = new CreateBudgetItemDlg();
    dlg.openDialog();

  onAddProcessingRule: (e) ->
    $('#add_processing_rule_overlay').modal();
    $('#add_processing_rule_overlay').centerModalInWindow();
    @current_data_name = $(e.srcElement).attr('data-name')
    $('form .expression').val(@current_data_name)

  closeNearestModal: (e) ->
    $(e.target).closest('.modal').modal('hide')
    window.location.reload();
