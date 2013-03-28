window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.budgets ||= {}

class window.financeRails.views.budgets.BudgetItemDlg extends Backbone.View
  active_categories: []
  events:
    'click .add_category': 'onAddCategory',
    'click .remove': 'onRemoveCategory'

  initialize: (options) ->
    _.bindAll @
    @$el = $(options.el)
    $('.category_name').focus()
    @active_categories = _(options.active_categories).map((category) -> {name: category}) || []
    @render();

  render: ->
    $('.included_categories').html(HandlebarsTemplates['budgets/dlg_budget_category']({categories: @active_categories}))
    category_names = _(@active_categories).map (category) -> category.name
    if category_names.length > 0
      $.ajax {
        url: '/budgets/expense_summary?categories=' + encodeURIComponent(JSON.stringify(category_names)),
        success: (data, textStatus, jqHR) ->
          $('.expense-data').html(data)
      }
    @delegateEvents()


  onAddCategory: (e) ->
    clicked_item = $(e.currentTarget)
    clicked_item.hide

    @active_categories.push {name: clicked_item.parent().attr('data-name')}
    @render()

  onRemoveCategory: (e) ->
    e.stopPropagation();
    e.preventDefault();
    $(e.currentTarget).parents('li').remove();

  closeNearestModal: (e) ->
      $(e.target).closest('.modal').modal('hide')
      window.location.reload();

  reloadPage: (e) ->
    window.location.reload()