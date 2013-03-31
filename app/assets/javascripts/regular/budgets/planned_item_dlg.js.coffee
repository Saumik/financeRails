window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.budgets ||= {}

class window.financeRails.views.budgets.PlannedItemDlg extends Backbone.View
  initialize: (options) ->
    @$el = $(options.el)
    financeRails.common.autocomplete_category(@$el.find('#planned_item_category_name'))
    financeRails.common.depend_date_picker(@$el.find('#planned_item_event_date_start'), @$el.find('#planned_item_event_date_end'))