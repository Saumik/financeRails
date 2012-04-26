class ExternalController < ApplicationController

  def first_match(match_data)
    match_data[1] if match_data != nil
  end

  def import
  end

  def process_confirm_import

    data = params[:upload].read

    if params[:upload].original_filename.ends_with? '.qif'
      import_from_money(data)
    elsif params[:upload].original_filename.ends_with? '.json'
      import_from_json(data)
    elsif params[:upload].original_filename.ends_with? '.csv'
      import_from_provident data
    end

    cache_client = Dalli::Client.new('127.0.0.1:11211')
    cache_client.set 'imported_1', @imported_data.collect(&:to_json)
  end

  def import_from_money(data)
    @imported_data = []

    balance = 0

    data.split('^').each do |transaction_string|

      amount = first_match(transaction_string.match(/^T([^\n]+)/))

      next if amount == nil

      amount = amount.delete(',').to_f

      category_full_name = first_match(transaction_string.match(/^L([^\n]+)/)) || ""
      date_parts = transaction_string.match(/D([0-9]+)\/([0-9]+)'([0-9]+)/)
      payee_name = first_match(transaction_string.match(/^P([^\n]+)/)) || ""
      comment = first_match(transaction_string.match(/^M([^\n]+)/)) || ""

      date_day = date_parts[1]
      date_month = date_parts[2]
      date_year = date_parts[3]

      # category can be of format [Saving] this means it's transfer
      transfer_name = first_match(category_full_name.match(/^\[(.+)\]/))

      if (transfer_name != nil)
        payee_name = category_full_name

        if (amount > 0)
          category_full_name = LineItem::TRANSFER_IN
        else
          category_full_name = LineItem::TRANSFER_OUT
        end
      end

      balance += amount

      line_item = LineItem.new
      line_item.type = amount > 0 ? LineItem::INCOME : LineItem::EXPENSE
      line_item.amount = amount.abs
      line_item.category_name = category_full_name.strip
      line_item.payee_name = payee_name.strip
      line_item.event_date = Date.new(date_year.to_i, date_month.to_i, date_day.to_i)
      line_item.comment = comment.strip
      line_item.balance = balance


      @imported_data << line_item

    end
  end

  def import_from_json(data)
    @imported_data = JSON.parse(data).collect {|line_item_hash| LineItem.new(line_item_hash)}
  end

  def import_from_provident(data)
    require 'csv'
    @imported_data = []
    CSV.new(data, :headers => :first_row).each do |row|
      date = row['Date']
      description = row['Description']
      comments = row['Comments']
      check_number = row['Check Number']
      amount = row['Amount']
      balance = row['Balance']

      amount_money = amount.scan(/[0-9.\-]+/).join.to_f
      
      line_item = LineItem.new
      line_item.type = amount.include?('(') ? LineItem::EXPENSE : LineItem::INCOME
      line_item.amount = amount_money.abs
      line_item.comment = description unless check_number.blank?
      line_item.payee_name = description if check_number.blank?
      line_item.event_date = Date.strptime(date, '%m/%d/%Y')

      @imported_data << line_item
    end
  end

  def do_import
    LineItem.delete_all

    cache_client = Dalli::Client.new('127.0.0.1:11211')

    cache_client.get('imported_1').each do |json_str|
      LineItem.create(JSON.parse(json_str))
    end

    LineItem.reset_balance

    cache_client.delete 'imported_1'
    redirect_to :controller => 'line_items', :action => :index
  end

  def export_json
    date_str = Time.now.strftime("%d-%m-%Y")

    send_data LineItem.all.to_json, :filename => "export_#{date_str}.json"
  end

end
