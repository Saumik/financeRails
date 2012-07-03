window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.groceries ||= {}

class IndexView extends Backbone.View
  el: '.groceries_section'
  domain: financeRails.views.groceries
  events:
    #{new_item}
    'ajax:success .create_area': 'onCreateServerOk'
    # {edit_item}
    'ajax:success .btn.edit': 'onEditFormArrived',
    'click .edit_form_area .btn-primary.submit': 'onEditClickOk',
    'ajax:success .edit_form_area' : 'onEditServerOk'
    # {delete_item}
    'ajax:success .btn.delete': 'onDeleteOk'


  initialize: (options) ->
    # {new_item}
    @form_view = new @domain.FormView($.extend(options, {el: '.create_area'}))
    @render()

  render: ->

  #{new_item}
  onCreateServerOk: (e, data, xhr) ->
    @$el.find('.main_table').prepend(data.content)
    @$el.find('[data-item-id=' + data.replace_id + ']').highlight('fast');

  #{edit_item}
  onEditFormArrived: (e, data, xhr) ->
    $('.edit_form_area .modal-body').html(data)
    $('.edit_form_area').modal();
    $('.edit_form_area').centerModalInWindow();
    @form_view = new @domain.FormView($.extend(@options, {el: '.edit_form_area'}))

  onEditClickOk: (e) ->
    $('.edit_form').submit();

  onEditServerOk: (e, data, xhr) ->
    financeRails.common.closeNearestModal(e);
    @$el.find('[data-item-id=' + data.replace_id + ']').replaceWith(data.content)
    @$el.find('[data-item-id=' + data.replace_id + ']').highlight('fast');

  #{delete_item}
  onDeleteOk: (e, data, xhr) ->
    @$el.find('[data-item-id=' + data.remove_id + ']').remove();

window.financeRails.views.groceries.IndexView = IndexView