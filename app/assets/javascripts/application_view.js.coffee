window.financeRails ||= {}
window.financeRails.views ||= {}

class ApplicationView extends Backbone.View

  initialize: (options) ->

    # prepare items for future actions
    @options = options

  closeNearestModal: (e) ->
      $(e.target).closest('.modal').modal('hide')