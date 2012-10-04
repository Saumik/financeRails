class LineItemsController < ApplicationController

  def index
    unless @account.present?
      render 'common/select_account' and return
    end

    @new_item = @account.line_items.build

    @items = @account.line_items.default_sort

    @items = @items.where(:tags => params[:tag]) if(params[:tag])

  end

  def create
    render :nothing => true and return if params[:line_item][:amount].to_i == 0

    changed_line_item = @account.line_items.build(params[:line_item])
    changed_line_item.source = LineItem::SOURCE_MANUAL
    changed_line_item.tags.reject!(&:blank?)
    changed_line_item.save

    @changed_line_items = []
    @changed_line_items << changed_line_item

    @account.reset_balance

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
    @item.tags.reject!(&:blank?)
    @item.original_payee_name = original_payee_name if @item.payee_name != original_payee_name and @item.original_payee_name.blank?
    @item.save

    if params[:always_assign] and @item.category_name.present? and @item.payee_name.present?
      ProcessingRule.create_rename_and_assign_rule_if_not_exists(ProcessingRule.get_category_name_rules, original_payee_name, @item.payee_name, @item.category_name)
    end

    @account.reset_balance

    @response_params = {:replace_id => params[:id], :content => render_to_string('_item', :layout => false, :locals => {:item => @item})}.to_json

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def destroy
    @item = LineItem.find(params[:id])
    @item.delete
    @account.reset_balance

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
    search_params[:in_month_of_date] = Date.new(params[:year].to_i, params[:month].to_i, 1) if params[:month].present? and params[:year].present?
    if params[:categories].present?
      search_params[:matching_category_prefix] = params[:categories] if params[:categories].length == 1
      search_params[:categories] = params[:categories] if params[:categories].length > 1
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

    @content = render_to_string('_item', :layout => false, :locals => {:item => @item})
    @data_response = {replace_id: @item.id.to_s, content: @content}
    respond_to do |format|
      format.js { render :layout => false }
      format.any { render :text => "Invalid format", :status => 403 }
    end
  end

  def autocomplete_payee
    query = params[:q]
    limit = params[:limit].to_i || 10

    results = LineItem.only(:payee_name).collect(&:payee_name).uniq.compact.keep_if {|item| item.downcase.include?(query)}[0, limit]

    render :text => results.join("\n")
  end

  def autocomplete_category
    query = params[:q]
    limit = params[:limit].to_i || 10

    results = LineItem.only(:category_name).collect(&:category_name).uniq.compact.keep_if {|item| item.downcase.include? query}[0, limit]

    render :text => results.join("\n")
  end

  respond_to :json

  def get_line_items_data_table
    #Rails.logger.info request.env.inspect

    display_start = params[:iDisplayStart].to_i
    display_length = params[:iDisplayLength].to_i

    @line_items = LineItem.regular.default_sort.skip(display_start).limit(display_length)

    @dt_params = {:echo => params[:sEcho].to_i, :total_records => LineItem.count, :total_display_records =>  @line_items.length}

    @line_items_json = @line_items.collect {|line_item| render_to_string line_item}.join(',')
  end

  def get_category_for_payee
    line_item = LineItem.where(:payee_name => params[:payee]).last

    raise ActionController::RoutingError.new('Not Found') if line_item.nil?

    render :text => line_item.category_name
  end

  def mass_rename
    perform_mass_rename if request.post?
    @payees = @account.line_items.all_unrenamed_payees(current_user)
  end

  private

  def perform_mass_rename
    category_processing_rules = ProcessingRule.get_category_name_rules
    params[:mass_rename].each do |(index, mass_rename_item)|
      unless mass_rename_item[:category_name].blank?
        LineItem.mass_rename_and_assign_category(@account, mass_rename_item[:original_payee_name], mass_rename_item[:payee_name], mass_rename_item[:category_name])
        ProcessingRule.create_rename_and_assign_rule_if_not_exists(category_processing_rules, mass_rename_item[:original_payee_name], mass_rename_item[:payee_name], mass_rename_item[:category_name])
      end
    end
  end
  end
