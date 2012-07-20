class ExternalController < ApplicationController

  def first_match(match_data)
    match_data[1] if match_data != nil
  end

  def import
  end

  def process_confirm_import
    @account = current_user.accounts.find(params[:account][:id])
    redirect_to :import and return unless @account.present?
    data = params[:upload].read

    if params[:upload].original_filename.ends_with? '.qif'
      import_from_money(data)
    elsif params[:upload].original_filename.ends_with? '.json'
      import_from_json(data)
    elsif params[:upload].original_filename.ends_with? '.csv'
      import_from_provident data
    end

    cache_client = Dalli::Client.new('127.0.0.1:11211')
    cache_client.set 'imported_1', @imported_data.collect { |line_item| line_item.to_json_as_imported }
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
    @account = current_user.accounts.find(params[:account_id])
    redirect_to :import and return unless @account.present?

    cache_client = Dalli::Client.new('127.0.0.1:11211')

    all_processing_rules = ProcessingRule.all
    cache_client.get('imported_1').each do |json_str|
      unless @account.imported_line?(json_str)
        line_item = @account.line_items.create(JSON.parse(json_str))
        ProcessingRule.perform_all_matching(all_processing_rules, line_item)

        @account.imported_lines.create(:imported_line => json_str, :line_item_id => line_item.id)
      end
    end

    LineItem.reset_balance

    cache_client.delete 'imported_1'
    redirect_to :controller => 'line_items', :action => :index, :account_id => @account.id
  end

  def import_json
    db_name = Rails.configuration.mongoid.database.name
    dump_folder = @backup_folders[params[:position].to_i]
    import_folder = "#{Dir.pwd}/dumps/#{dump_folder}"
    command = "mongorestore -d #{db_name} --drop #{import_folder}/"
    output = `#{command}`

    result=$?.success?

    flash[:notice] = "Executed #{command}"
    if result
      flash[:success] = "Imported #{dump_folder}"
    else
      flash[:error] = "Failed to import"
    end

    redirect_to :controller => :line_items, :action => :index
  end

  def export_json
    db_name = Rails.configuration.mongoid.database.name
    date_str = Time.now.strftime("%d-%m-%Y--%H-%M")
    result_folder = "#{Dir.pwd}/dumps/dump-#{db_name}-#{date_str}"
    command = "mongodump -d #{db_name} -o #{result_folder}"
    `mkdir #{Dir.pwd}/dumps/`
    `mkdir #{result_folder}`
    `#{command}`
    result=$?.success?
    if result
      `mv #{result_folder}/#{db_name}/* #{result_folder}`
      `rmdir #{result_folder}/#{db_name}`
    end

    flash[:notice] = "Output: #{command}"
    if result
      flash[:success] = "Exported the file to #{result_folder}"
    else
      flash[:error] = "Failed to export"
    end

    redirect_to :controller => :line_items, :action => :index
  end

end
