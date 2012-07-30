class CreateBudgetItemDlg extends Backbone.View
  el: '#create_budget_item_modal'
  active_categories: []
  events:
    'click .add_category': 'onAddCategory'
    'ajax:success #create_budget_item_modal form': 'closeNearestModal',

  initialize: ->
    _.bindAll @

  openDialog: ->
    $el = $(@el)
    $el.modal()
    $el.centerModalInWindow()
    $('.category_name').focus

  render: ->
    $('.included_categories').html(HandlebarsTemplates['templates/budgets/dlg_budget_category']({categories: @active_categories}))

  onAddCategory: (e) ->
    clicked_item = $(e.currentTarget)
    clicked_item.hide

    @active_categories.push {name: clicked_item.parent().attr('data-name')}
    @render()

    category_names = _(@active_categories).map (category) -> category.name

    $.pjax {
      url: '/budgets/expense_summary?categories=' + encodeURI(JSON.stringify(category_names)),
      container: '.expense-data',
      push: false
    }

  closeNearestModal: (e) ->
      $(e.target).closest('.modal').modal('hide')
      window.location.reload();

window.CreateBudgetItemDlg = CreateBudgetItemDlg