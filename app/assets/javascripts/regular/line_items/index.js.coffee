window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.IndexView extends Backbone.View
  el: '.line_items_section'
  domain: financeRails.views.line_items
  events:
    #{new_item}
    'ajax:success .create_area': 'onCreateServerOk'
    'click .import_toggle': 'onToggleImportRemote'
    'click .create_toggle': 'onToggleCreate'
    'keyup #search': 'onChangeSearch'

  initialize: (options) ->
    # {new_item}
    @form_view = new @domain.FormView({el: '.create_area'})
    @convertTableToLi()
    @render()

  render: ->
    $('.display-tooltip').tooltip()

  #{new_item}
  onClickCreate: (e) ->
    $('.create_area form').submit()

  onCreateServerOk: (e, data, xhr) ->
    @$el.find('.main_table').prepend(data.content)
    @$el.find('[data-item-id=' + data.replace_id + ']').highlight('fast');

  onToggleImportRemote: (e) ->
    $('.fetch_area').toggleClass('hide')

  onToggleCreate: (e) ->
    $('.create_area').toggleClass('hide')

  onChangeSearch: (e) ->
    term = $(e.currentTarget).val()
    if(term.length == 0)
      $('.month_selector li.active').click()
      return
