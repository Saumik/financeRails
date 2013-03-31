window.financeRails ||= {}

class CommonFunctions
  closeNearestModal: (e) ->
    $(e.target).closest('.modal').modal('hide')

  autocomplete_category: ($el) ->
    if window.category_names
      $el.typeahead({source: window.category_names})
    else
      $.get '/line_items/category_names', {  }, (data) =>
        window.category_names = data.results
        $el.typeahead({source: window.category_names})

  autocomplete_payee: ($el) ->
    $.get '/line_items/payee_names', {  }, (data) =>
      window.payee_names = data.results
      $el.typeahead({source: window.payee_names})

  autocomplete_amount_category_from_payee: ($category, $payee, $amount) ->
    $.get '/line_items/payee_data', {  }, (data) =>
      window.last_data_for_payee = data.results

    $payee.on 'change', (e) ->
      payee_name = $payee.val();
      last_value = window.last_data_for_payee[payee_name]

      if last_value and ($amount.val().length == 0 || $amount.val() == '0.0')
        $amount.val(last_value.amount)

      if last_value and $category.val().length == 0
        $category.val(last_value.category_name)

      $amount.focus();
      $amount.select();


  depend_date_picker: ($el1, $el2) ->
    nowTemp = new Date()
    now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

    date1 = $el1.datepicker(
      onRender: (date) ->
        return date.valueOf() < now.valueOf() ? 'disabled' : ''
    ).on('changeDate', (ev) ->
      if (ev.date.valueOf() > date2.date.valueOf())
        newDate = new Date(ev.date)
        newDate.setDate(newDate.getDate())
        date2.setValue(newDate)

      date1.hide()
      $el2[0].focus()
    ).data('datepicker')
    date2 = $el2.datepicker(
      onRender: (date) ->
        return date.valueOf() < date1.date.valueOf() ? 'disabled' : '';
    ).on('changeDate', (ev) ->
      date2.hide()
    ).data('datepicker')


window.financeRails.common = new CommonFunctions();