window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.budgets ||= {}

class window.financeRails.views.budgets.BudgetView extends Backbone.View
  el: 'body'
  events:
    'click .open_create_budget_item': 'onOpenCreateBudgetItem'
    'click .edit_btn': 'onClickEdit'
    'ajax:success .btn.delete': 'onDeleteOk'

  initialize: (options) ->
    _.bindAll @
    @render()

  render: ->
    $('.inner-nav .budgets').addClass('active')

  onOpenCreateBudgetItem: (e) ->
    dlg = new financeRails.views.budgets.BudgetItemDlg();
    dlg.openDialog();

  onClickEdit: (e) ->
    dlg = new financeRails.views.budgets.BudgetItemDlg();
    dlg.openDialog({id: $(e.currentTarget).parents('tr').data('id')});

  onDeleteOk: (e) ->
    window.location.reload();

  closeNearestModal: (e) ->
    $(e.target).closest('.modal').modal('hide')
    window.location.reload();
