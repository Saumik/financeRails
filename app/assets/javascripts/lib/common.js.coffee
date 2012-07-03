window.financeRails ||= {}

class CommonFunctions
  closeNearestModal: (e) ->
    $(e.target).closest('.modal').modal('hide')

window.financeRails.common = new CommonFunctions();