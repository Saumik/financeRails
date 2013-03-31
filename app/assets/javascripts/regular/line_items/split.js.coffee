window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.SplitFormView extends Backbone.View
  domain: financeRails.views.line_items
  el: '.split_form_area'
  events:
    'click .btn.add-item': 'onAddItem'
    'click .btn.remove-item': 'onRemoveItem'
    'change .amount': 'updateAmount'

  initialize: (options) ->
    _.bindAll @
    @itemsVisible = 1
    @formViews = []
    @amount_left = @initialAmount = options.amount_left

    $('.item').each (index, item) =>
      @formViews.push new @domain.FormView($.extend(@options, {el: '#' + $(item).attr('id')}))

    financeRails.common.autocomplete_category(@$el.find('.category_name'))

    @render()

  render: ->
    @$el.find('#amount-left').text("$#{@amount_left}")
    @$el.find(".item").show();
    @$el.find(".item:gt(#{@itemsVisible-1})").hide();
    @$el.find(".item:gt(#{@itemsVisible-1}) input").val('');
    @$el.find(".amount_of_items").val(@itemsVisible);

  onAddItem: ->
    return if @itemsVisible == 5
    @itemsVisible += 1
    @render()

  onRemoveItem: ->
    return if @itemsVisible == 1
    @itemsVisible -= 1
    @render()

  updateAmount: ->
    @amount_left = @initialAmount
    @$el.find("input.amount").each (index, item) =>
      value = parseInt($(item).val())
      @amount_left -= value if value
    @render()