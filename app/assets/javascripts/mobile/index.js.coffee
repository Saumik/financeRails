window.financeRails ||= {}
window.financeRails.views ||= {}
window.financeRails.views.mobile ||= {}

class window.financeRails.views.mobile.Index extends Backbone.View
  el: '.mobile'
  domain: financeRails.views.mobile
  localStorageKey: 'line_items_app'
  currentData: []
  modifiedIndices: []
  currentIndex: null
  events:
    'click .add-btn': 'onClickAdd'
    'click a.view-item': 'onClickViewItem'
    'click #add-line-item-form .submit-btn': 'onSubmitAddLineItem'
    'click .select-payee': 'onClickSelectPayee'
    'click .select-category': 'onClickSelectCategory'
    'financeRails:pagechange #add-line-item': 'onPageChangeAddLineItem'
    'financeRails:pagechange #main-page': 'onPageChangeMainPage'
    'financeRails:pagechange #view-item': 'onPageChangeViewItem'

  initialize: (options) ->
    _.bindAll @
    $(document).bind('pagechange', @onPageChange);
    @currentData = JSON.parse(localStorage.getItem(@localStorageKey)) || []
    @sync()
    @render()
    @delegateEvents()

  render: ->
    if location.hash is '#main-page' or location.hash is ''
      $('.line_items').html('')
      for item in @currentData
        $('.line_items').append('<li><a class="view-item" data-item-index="' + @currentData.indexOf(item) + '" href="#view-item">
               <span class="event_date">' + moment(item.line_item.event_date).format('M/D') + '</span>
               <span class="amount">$' + item.line_item.amount + '</span>
                <span class="payee_name">' + item.line_item.payee_name + '</span></a></li>')
      $('.line_items').listview('refresh');

  sync: ->
    if navigator.onLine
      dataToSend = JSON.stringify(_(@currentData).filter((item) -> item.modified))

      $.ajax({
        url: '/mobile/sync'
        data: {client_data: dataToSend}
        type: 'POST'
        dataType: 'json'
        success: @onGotSyncData
      });

  onGotSyncData: (data, textStatus, jqXHR) ->
    localStorage.setItem(@localStorageKey, JSON.stringify(data))
    @currentData = data
    @render()

  onClickAdd: (e) ->

  onSubmitAddLineItem: (e) ->
    e.preventDefault();
    item = $('#add-line-item-form').serializeObject();
    item.modified = true
    @currentData.push item
    @modifiedIndices.push @currentData.length - 1
    @sync()
    $.mobile.changePage('#main-page')

  onClickViewItem: (e) ->
    @currentIndex = $(e.currentTarget).data('item-index');

  onPageChangeMainPage: (e, options) ->
    @render();

  onPageChangeAddLineItem: (e) ->
    $('#add-line-item-form #payee_name').val(@selectedPayee) if @selectedPayee
    $('#add-line-item-form #category_name').val(@selectedCategory) if @selectedCategory


  onPageChangeViewItem: (e, options) ->
    $.mobile.changePage('#main-page') if !@currentData[@currentIndex]
    $('#view-item .type').html(@currentData[@currentIndex].line_item.type == 0 ? 'Income' : 'Expense')
    $('#view-item .event_date').html(moment(@currentData[@currentIndex].line_item.event_date).format('M/D/YYYY'))
    $('#view-item .amount').html('$' + @currentData[@currentIndex].line_item.amount)
    $('#view-item .payee_name').html(@currentData[@currentIndex].line_item.payee_name)
    $('#view-item .category_name').html(@currentData[@currentIndex].line_item.category_name)
    $('#view-item .comment').html(@currentData[@currentIndex].line_item.comment)

  onPageChange: (e, data) ->
    @delegateEvents();
    if data.options
      data.toPage.trigger('financeRails:pagechange', data.options)

  onClickSelectPayee: (e) ->
    @selectedPayee = $(e.currentTarget).text();
    history.back();

  onClickSelectCategory: (e) ->
    @selectedCategory = $(e.currentTarget).text();
    history.back();
