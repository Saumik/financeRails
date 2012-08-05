window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.budgets ||= {}

class window.financeRails.views.budgets.BudgetItemDlg extends Backbone.View
  el: '#budget_item_modal'
  active_categories: []
  events:
    'click .add_category': 'onAddCategory'
    'ajax:success #budget_item_modal form': 'reloadPage',

  initialize: ->
    _.bindAll @

  openDialog: (options) ->
    $el = $(@el)
    $el.modal()
    $el.centerModalInWindow()
    $('.category_name').focus

    if(options.id)
      @loadExisting(options.id)
      @$el.find('form').prop('method', 'put')
      @$el.find('form').prop('action', '/budgets/' + options.id)

  render: ->
    $('.included_categories').html(HandlebarsTemplates['templates/budgets/dlg_budget_category']({categories: @active_categories}))
    category_names = _(@active_categories).map (category) -> category.name
    $.pjax {
      url: '/budgets/expense_summary?categories=' + encodeURI(JSON.stringify(category_names)),
      container: '.expense-data',
      push: false
    }

  onAddCategory: (e) ->
    clicked_item = $(e.currentTarget)
    clicked_item.hide

    @active_categories.push {name: clicked_item.parent().attr('data-name')}
    @render()

  loadExisting: (id) ->
    $.ajax({
      url: '/budgets/' + id + '/edit',
      dataType: 'json'
      success: @onLoadExistingOk
    })

  onLoadExistingOk: (data, textStatus, jqXHR) ->
    @id = data.id
    @active_categories = _(data.budget_item.categories).map((item) -> {name: item})
    @$el.find('input.name').val(data.budget_item.name)
    @$el.find('input.limit').val(data.budget_item.limit)
    @render()

  closeNearestModal: (e) ->
      $(e.target).closest('.modal').modal('hide')
      window.location.reload();

  reloadPage: (e) ->
    window.location.reload()