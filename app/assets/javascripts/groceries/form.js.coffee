class FormView extends Backbone.View
  events:
      'change .typeahead': 'onChangeTypeAhead',
      'change #grocery_line_item_name': 'onChangeLineItemName'

  initialize: (options) ->
    _.bindAll @
    @el = options.el
    @stores = options.stores
    @item_names = options.item_names
    @last_prices_for_item = options.last_prices_for_item
    @render()

  render: ->
    @$el.find('#grocery_line_item_store').typeahead({source: @stores})
    @$el.find('#grocery_line_item_name').typeahead({source: @item_names})

  onChangeTypeAhead: (e) ->
    $(e.currentTarget).next('input').first().focus()

  onChangeLineItemName: (e) ->
    store = $('#new_grocery_line_item .store').val();
    name = $('#new_grocery_line_item .name').val();
    last_value = @last_prices_for_item[store + ':' + name]
    if last_value
      $('#new_grocery_line_item .units').val(last_value.units)
      $('#new_grocery_line_item .price_per_unit').val(last_value.price_per_unit)
      $('#new_grocery_line_item .unit_type').val(last_value.unit_type)
      $('#new_grocery_line_item .units').focus();
      $('#new_grocery_line_item .units').select();

window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.groceries ||= {}
window.financeRails.views.groceries.FormView = FormView