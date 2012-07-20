window.financeRails ||= {}
window.financeRails.views ||= {}

class window.financeRails.views.PayeeView extends Backbone.View
  el: 'body'
  events:
    'click .open_rename_payee': 'onOpenRenamePayee'
    'click .add_processing_rule': 'onAddProcessingRule'
    'click #add_processing_rule_overlay .same': 'onClickSame'
    'ajax:success #rename_payee form': 'closeNearestModal'
    'ajax:success #add_processing_rule_overlay form': 'closeNearestModal'

  initialize: ->
    _.bindAll @
    @render()

  render: ->
    $('.inner-nav .payee').addClass('active')

  onOpenRenamePayee: (e) ->
    $('#rename_payee').modal();
    @payee_name = $(e.srcElement).attr('data-payee-name')
    $('#payee_name').val(@payee_name)
    $('#payee_replacement').val(@payee_name)
    $('#payee_replacement').focus();

  onAddProcessingRule: (e) ->
    $('#add_processing_rule_overlay').modal();
    $('#add_processing_rule_overlay').centerModalInWindow();
    @current_data_name = $(e.srcElement).attr('data-name')
    $('form .expression').val(@current_data_name)

  onClickSame: ->
    $('#processing_rule_payee').val(@current_data_name)

  closeNearestModal: (e) ->
    $(e.target).closest('.modal').modal('hide')
    window.location.reload();