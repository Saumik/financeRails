class PayeeView extends Backbone.View
  el: 'body'
  events:
    'click .add_processing_rule': 'onAddProcessingRule'
    'click #add_processing_rule_overlay .same': 'onClickSame'
    'click #add_processing_rule_overlay .submit': 'onClickSubmit'
    'ajax:success #add_processing_rule_overlay form': 'onFormSuccess'

  initialize: ->
    _.bindAll @
    @render()

  render: ->

  onAddProcessingRule: (e) ->
    $('#add_processing_rule_overlay').on 'shown', (e) ->
      modal = $(this)
      modal.css('margin-top', (modal.outerHeight() / 2) * -1)
           .css('margin-left', (modal.outerWidth() / 2) * -1)
      return this

    $('#add_processing_rule_overlay').modal();
    @current_data_name = $(e.srcElement).attr('data-name')
    $('#processing_rule_expression').val(@current_data_name)

  onClickSame: ->
    $('#processing_rule_payee').val(@current_data_name)

  onClickSubmit: ->
    $('#add_processing_rule_overlay form').submit()

  onFormSuccess: ->
    $('#add_processing_rule_overlay').modal('hide')

window.PayeeView = PayeeView