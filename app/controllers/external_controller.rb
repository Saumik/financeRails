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

    #if params[:upload].original_filename.ends_with? '.qif'
    #  import_from_money(data)
    #elsif params[:upload].original_filename.ends_with? '.json'
    #  import_from_json(data)
    #els
    if params[:upload].original_filename.downcase.ends_with? '.csv'
      @imported_data = Importers.const_get(@account.import_format).new.import(data, params[:upload].original_filename.downcase)
    end

    $redis.set("import-data:#{current_user.id}", @imported_data.to_json)
  end

  def import_from_json(data)
    @imported_data = JSON.parse(data).collect {|line_item_hash| LineItem.new(line_item_hash)}
  end

  def do_import
    @account = current_user.accounts.find(params[:account_id])
    redirect_to :import and return unless @account.present?

    if params[:commit] == 'Perform Import'
      line_items_jsonified = JSON.parse($redis.get("import-data:#{current_user.id}"))
      @account.import_line_items(current_user, line_items_jsonified)
      flash[:success] = "#{line_items_jsonified.length} line items were imported"
    elsif params[:commit] == 'Delete Previous Import'
      imported_lines = @account.imported_lines.where(:imported_line.in => cache_client.get('imported_1'))
      amount_removed = 0
      imported_lines.each do |imported_line|
        if imported_line.line_item
          imported_line.line_item.destroy
          amount_removed += 1
        end
      end
      flash[:success] = "#{amount_removed} imported items were removed"
    end

    $redis.del("import-data:#{current_user.id}")

    if @account.investment_account?
      redirect_to :controller => 'investment', :action => :index
    else
      @account.reset_balance
      @account.touch

      redirect_to :controller => 'line_items', :action => :index, :account_id => @account.id
    end
  end

  def import_json
    db_name = Rails.configuration.mongoid.sessions["default"]["database"]
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

    randomize_data if Rails.env.development?

    redirect_to :controller => :line_items, :action => :index
  end

  def export_json
    db_name = Rails.configuration.mongoid.sessions["default"]["database"]
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

  def download_backup
    folder_name = params[:folder_name].match(/^[A-Z0-9a-z\-_]+$/).to_s
    redirect_to :back and return if folder_name.blank?
    full_path = "#{Dir.pwd}/dumps/#{folder_name}"
    `tar -cf #{full_path}.tgz -C #{full_path} .`
    result=$?.success?
    if result
      send_file "#{full_path}.tgz"
    else
      flash[:error] = "Error while zipping #{full_path}.tgz"
      redirect_to :back
    end
  end

  private

  def randomize_data
    LineItem.all.each do |line_item|
      line_item.amount = random_float(line_item.amount)
      line_item.save
    end

    BudgetItem.all.each do |budget_item|
      budget_item.limit = random_number(budget_item.limit)
      budget_item.save
    end

    InvestmentLineItem.each do |investment_item|
      investment_item.number = random_number(investment_item.number)
      investment_item.amount = random_float(investment_item.number)
      investment_item.total_amount = investment_item.number * investment_item.amount
      investment_item.save
    end

    PlannedItem.each do |planned_item|
      planned_item.amount = random_number(planned_item.amount)
      planned_item.save
    end

    current_user.accounts.each do |account|
      account.reset_balance
    end
  end

  def random_number(num)
    (num * (1+rand)).round.to_i
  end

  def random_float(num)
    (num * (1+rand)).round(2)
  end

end