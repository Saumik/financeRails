window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.MassRenameView extends Backbone.View
  el: '.line_items_section'
  domain: financeRails.views.line_items
  events:
    'change .category_name': 'onChangeCategoryName'
    'change .payee_name': 'onChangePayeeName'
    'change .typeahead': 'onChangeTypeAhead'

  initialize: (options) ->
    @unrenamed_payees = _(_($('.original_payee_name')).map((item) -> $(item).val())).union(_($('.payee_name')).map((item) -> $(item).val()))
    @original_payees = _(options.payees).clone()
    @original_categories = _(options.categories).clone()
    @payees = options.payees
    @categories = options.categories
    @last_data_for_payee = options.last_data_for_payee
    @render()

  render: ->
    @$el.find('.payee_name').typeahead({source: @payees, show_current: true})
    @$el.find('.category_name').typeahead({source: @categories, show_current: true})
    $('.inner-nav .mass_rename').addClass('active')

  onChangeTypeAhead: (e) ->
    current_id = $(e.currentTarget).prop('id')
    all_inputs = $('input')
    input = _(all_inputs).find((item) -> $(item).prop('id') == current_id)
    next_input_index = all_inputs.toArray().indexOf(input) + 1
    all_inputs[next_input_index].focus()

  onChangePayeeName: (e) ->
    payee_name = $(e.currentTarget).val();
    last_value = @last_data_for_payee[payee_name]
    payees = @payees = _(_($('.payee_name')).map((item) -> $(item).val())).union(@original_payees)
    _(@$el.find('.payee_name').typeahead()).each((typeahead) -> $(typeahead).data('typeahead').source = payees)
    if last_value
      category_name_item = @$el.find('#' + $(e.currentTarget).prop('id').replace('payee_name', 'category_name'))
      category_name_item.val(last_value.category_name)
      category_name_item.focus();

  onChangeCategoryName: (e) ->
    categories = @categories = _(_($('.category_name')).map((item) -> $(item).val())).union(@original_categories)
    _(@$el.find('.category_name').typeahead()).each((typeahead) -> $(typeahead).data('typeahead').source = categories)
    payee_name = @$el.find('#' + $(e.currentTarget).prop('id').replace('category_name', 'payee_name')).val()
    @last_data_for_payee[payee_name] = {category_name: $(e.currentTarget).val()}