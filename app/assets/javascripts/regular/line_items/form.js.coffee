window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.FormView extends Backbone.View
  events:
    'change .typeahead': 'onChangeTypeAhead'

  initialize: (options) ->
    _.bindAll @
    financeRails.common.autocomplete_category(@$el.find('.category_name'))
    financeRails.common.autocomplete_payee(@$el.find('.payee_name'))
    financeRails.common.autocomplete_amount_category_from_payee(@$el.find('.category_name'), @$el.find('.payee_name'), @$el.find('.amount'))
    @$el.find('.event_date').focus()
    @$el.find('.event_date').select()
    @$el.find('.event_date').datepicker()
    @$el.find('.original_event_date').datepicker()
    @render()

  render: ->


  onChangeTypeAhead: (e) ->
    $(e.currentTarget).next('input').first().focus()
