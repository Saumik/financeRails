window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.line_items ||= {}

class window.financeRails.views.line_items.IndexView extends Backbone.View
  el: '.line_items_section'
  domain: financeRails.views.line_items
  events:
    #{new_item}
    'ajax:success .create_area': 'onCreateServerOk'
    'financeRails:line-item-modified': 'onLineItemModified'
    #'click .month_selector li': 'onClickChangeMonth'
    'click .import_toggle': 'onToggleImportRemote'
    'click .create_toggle': 'onToggleCreate'
    'keyup #search': 'onChangeSearch'

  initialize: (options) ->
    # {new_item}
    @form_view = new @domain.FormView($.extend(options, {el: '.create_area'}))
    @render()

  render: ->
    $('.display-tooltip').tooltip()
#    $('.main_table').dataTable( {
#      #"bProcessing": true
#      #"bServerSide": true
#      #"sAjaxSource": '/line_items/get_line_items_data_table'
#      "bSort" : false
#      "iDisplayLength": 20,
#      "aoColumns": [
#          { "mDataProp": "type" },
#          { "mDataProp": "event_date" },
#          { "mDataProp": "amount" },
#          { "mDataProp": "payee_name" },
#          { "mDataProp": "category_name" },
#          { "mDataProp": "balance" },
#          { "mDataProp": "links" }
#      ],
#      # Changes for twitter bootstrap support
#      "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
#      "sPaginationType": "bootstrap",
#      "oLanguage": {
#          "sLengthMenu": "_MENU_ Records per page"
#      }
#    } );


  #{new_item}
  onClickCreate: (e) ->
    $('.create_area form').submit()

  onCreateServerOk: (e, data, xhr) ->
    @$el.find('.main_table').prepend(data.content)
    @$el.find('[data-item-id=' + data.replace_id + ']').highlight('fast');

  onLineItemModified: (e, data) ->
    @$el.find('[data-item-id=' + data.replace_id + ']').replaceWith(data.content)
    @$el.find('[data-item-id=' + data.replace_id + ']').highlight();

#  onClickChangeMonth: (e) ->
#    active_month = $(e.currentTarget).data('date')
#    $('#items_list tbody tr').addClass('hide')
#    $('#items_list tbody tr[data-date=' + active_month + ']').removeClass('hide')
#    $('.month_selector li').removeClass('active');
#    $(e.currentTarget).addClass('active')

  onToggleImportRemote: (e) ->
    $('.fetch_area').toggleClass('hide')

  onToggleCreate: (e) ->
    $('.create_area').toggleClass('hide')

  onChangeSearch: (e) ->
    term = $(e.currentTarget).val()
    if(term.length == 0)
      $('.month_selector li.active').click()
      return

#    $('#items_list tbody tr').addClass('hide')
#    $('#items_list td.category_name,#items_list td.payee_name').each (index, item) ->
#      if $(item).text().match(new RegExp(term, "i"))
#        $(item).parent().removeClass('hide')
#    true