window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.FormView extends Backbone.View
  events:
      'change .typeahead': 'onChangeTypeAhead',
      'change .payee_name': 'onChangePayeeName'

  initialize: (options) ->
    _.bindAll @
    @el = options.el
    @payees = options.payees
    @categories = options.categories
    @last_data_for_payee = options.last_data_for_payee
    @render()

  render: ->
    @$el.find('.event_date').focus()
    @$el.find('.event_date').select()
    @$el.find('.payee_name').typeahead({source: @payees, show_current: true})
    @$el.find('.category_name').typeahead({source: @categories, show_current: true})

  onChangeTypeAhead: (e) ->
    $(e.currentTarget).next('input').first().focus()

  onChangePayeeName: (e) ->
    payee_name = $(e.currentTarget).val();
    last_value = @last_data_for_payee[payee_name]

    if last_value and @$el.find('.amount').length == 0
      @$el.find('.amount').val(last_value.amount)

    if last_value and @$el.find('.category_name').length == 0
      @$el.find('.category_name').val(last_value.category_name)

    @$el.find('.amount').focus();
    @$el.find('.amount').select();
