class LineItemsController < ApplicationController
  # Fixing payee issue:
  # use finance_rails2_production
  # db.line_items.find({account_id: '5015e0d99e65db9218000004'}).sort({'_id': -1})
  # db.line_items.update({account_id: '5015e0d99e65db9218000004'}, { $set: {account_id: ObjectId('5015e0d99e65db9218000004')}}, false, true)
  def index
    if @account.present?
      @new_item = @account.line_items.build
      @items = @account.line_items.default_sort
    else
      @new_item = current_user.accounts.first.line_items.build
      @items = current_user.line_items.default_sort
    end

    @first_item = @items.last
    @last_item = @items.first

    params[:month] ||= @last_item.event_date.month
    params[:year] ||= @last_item.event_date.year


    query_date_begin = Date.new(params[:year].to_i, params[:month].to_i, 1).beginning_of_month
    query_date_end = query_date_begin.end_of_month
    @active_date = query_date_begin
    @items = @items.where(:event_date => query_date_begin..query_date_end)

    respond_to do |format|
      format.html {  }
      format.js { render :layout => false }
    end
  end

  def create
    render :nothing => true and return if params[:line_item][:amount].to_i == 0

    @account = current_user.accounts.find(params[:line_item][:account_id])
    changed_line_item = @account.line_items.build(params[:line_item])
    changed_line_item.source = LineItem::SOURCE_MANUAL
    changed_line_item.tags.reject!(&:blank?)
    changed_line_item.save

    @changed_line_items = []
    @changed_line_items << changed_line_item

    changed_line_item.account.reset_balance
    changed_line_item.account.touch

    if params[:always_assign]
      ProcessingRule.create_category_rename_rule(all_processing_rules, changed_line_item.payee_name, changed_line_item.category_name)
    end

    changed_line_item.reload
    @item = changed_line_item
    @line_item = changed_line_item.clone_new

    render :json => {:prepend => true, :content => render_to_string('_item', :layout => false, :locals => {:item => @item}) }
  end

  def edit
    @item = LineItem.find(params[:id])

    render :layout => false
  end

  def update
    @item = LineItem.find(params[:id])

    original_payee_name = @item.payee_name
    @item.attributes = params[:line_item]
    @item.account_id = Moped::BSON::ObjectId.from_string(params[:line_item][:account_id])
    @item.tags.reject!(&:blank?)
    @item.original_payee_name = original_payee_name if @item.payee_name != original_payee_name and @item.original_payee_name.blank?
    @item.save

    if params[:always_assign] and @item.category_name.present? and @item.payee_name.present?
      ProcessingRule.create_rename_and_assign_rule_if_not_exists(ProcessingRule.get_category_name_rules, original_payee_name, @item.payee_name, @item.category_name)
    end

    @item.account.reset_balance
    @item.account.touch

    @response_params = {:replace_id => params[:id], :content => render_to_string('_item', :layout => false, :locals => {:item => @item})}

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def destroy
    @item = LineItem.find(params[:id])
    @item.delete
    @account.reset_balance
    @account.touch

    @data_response = {:remove_id => params[:id]}
    respond_to do |format|
      format.js { render :layout => false}
    end
  end

  #noinspection RubyArgCount
  def show

  end

  def search_overlay
    search_params = {}
    if params[:month].present? and params[:year].present?
      search_params[:in_month_of_date] = Date.new(params[:year].to_i, params[:month].to_i, 1)
    end
    if params[:categories].present?
      search_params[:matching_category_prefix] = params[:categories][0] if params[:categories].length == 1
      search_params[:categories] = params[:categories] if params[:categories].length > 1
    end
    if params[:payee_name].present?
      search_params[:payee_name] = params[:payee_name]
    end
    @line_items = LineItem.search_with_filters(current_user, search_params)
    @spanned_line_items = LineItem.search_spanned_line_items_with_filters(current_user, search_params.merge(support_spanned: true))
  end

  def split
    @item = LineItem.find(params[:id])

    render :layout => false
  end

  def perform_split
    @item = LineItem.find(params[:id])

    @added_items = []
    (0..params[:amount_of_items].to_i-1).each do |index|
      new_item = @item.split_from_item(params[:line_item][:splitted][index.to_s])
      @item.amount -= new_item.amount.to_f
      @added_items << (render_to_string('_item', :layout => false, :locals => {:item => new_item}))
    end

    @item.save
    @item.account.touch

    @content = render_to_string('_item', :layout => false, :locals => {:item => @item})
    @data_response = {replace_id: @item.id.to_s, content: @content}
    respond_to do |format|
      format.js { render :layout => false }
      format.any { render :text => "Invalid format", :status => 403 }
    end
  end

  def category_names
    render :json => {results: current_user.categories }
  end

  def payee_names
    render :json => {results: current_user.payees}
  end

  def payee_data
    render :json => {results: current_user.all_last_data_for_payee }
  end

  def mass_rename
    perform_mass_rename if request.post?
    @payees = current_user.line_items.all_unrenamed_payees(current_user)
  end

  def ignore_rename
    current_user.line_items.where(payee_name: params[:payee_name], original_payee_name: nil).each do |line_item|
      line_item.original_payee_name = line_item.payee_name
      line_item.save
    end

    redirect_to mass_rename_line_items_path
  end

  def cache_refresh
    keys = $redis.keys 'cache:*'
    $redis.del keys
    redirect_to line_items_path
  end

  private

  def perform_mass_rename
    category_processing_rules = ProcessingRule.get_category_name_rules(current_user)
    payee_rules = ProcessingRule.get_payee_rules(current_user)
    params[:mass_rename].each do |(index, mass_rename_item)|
      unless mass_rename_item[:category_name].blank?
        LineItem.mass_rename_and_assign_category(current_user, mass_rename_item[:original_payee_name], mass_rename_item[:payee_name], mass_rename_item[:category_name])
        ProcessingRule.create_rename_and_assign_rule_if_not_exists(current_user, category_processing_rules, payee_rules, mass_rename_item[:original_payee_name], mass_rename_item[:payee_name], mass_rename_item[:category_name])
      end
    end
    @account.touch
  end
end
