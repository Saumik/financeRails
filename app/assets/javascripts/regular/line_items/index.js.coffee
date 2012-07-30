window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.IndexView extends Backbone.View
  el: '.line_items_section'
  domain: financeRails.views.line_items
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
    $('.main_table').dataTable( {
      #"bProcessing": true
      #"bServerSide": true
      #"sAjaxSource": '/line_items/get_line_items_data_table'
      "bSort" : false
      "iDisplayLength": 20,
      "aoColumns": [
          { "mDataProp": "type" },
          { "mDataProp": "event_date" },
          { "mDataProp": "amount" },
          { "mDataProp": "payee_name" },
          { "mDataProp": "category_name" },
          { "mDataProp": "balance" },
          { "mDataProp": "links" }
      ],
      # Changes for twitter bootstrap support
      "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
      "sPaginationType": "bootstrap",
      "oLanguage": {
          "sLengthMenu": "_MENU_ Records per page"
      }
    } );


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