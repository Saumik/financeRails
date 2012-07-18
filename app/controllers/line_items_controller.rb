class LineItemsController < ApplicationController
  before_filter :prepare_account
  around_update :on_around_update_assign_old_payee_name

  def prepare_account
    if params[:account_id]
      session[:account_id] = params[:account_id]
    end

    if session[:account_id]
      @account = current_user.accounts.find(session[:account_id])
    end
  end

  def index
    unless @account.present?
      render 'common/select_account' and return
    end

    @new_item = @account.line_items.build
    @items = @account.line_items.default_sort
  end

  def create
    changed_line_item = LineItem.create(params[:line_item])

    @changed_line_items = []
    if params[:spanned]
      @changed_line_items += changed_line_item.span(params[:spanned_amount].to_i)
    else
      @changed_line_items << changed_line_item
    end

    LineItem.reset_balance

    all_processing_rules = ProcessingRule.all
    @changed_line_items.each do |line_item|
      ProcessingRule.perform_all_matching(all_processing_rules, line_item)
    end

    if params[:always_assign]
      ProcessingRule.create_category_rename_rule(changed_line_item.payee_name, changed_line_item.category_name)
    end

    @line_item = changed_line_item.clone_new
  end

  def edit
    @item = LineItem.find(params[:id])

    if(@item.spanned)
      @item = LineItem.find(@line_item.spanned.master_line_item_id)
    end

    render :layout => false
  end

  def update
    @item = LineItem.find(params[:id])

    original_item_name = @item.original_name
    @item.update_attributes(params[:line_item])

    if params[:always_assign] and @item.category_name.present? and @item.payee_name.present?
      ProcessingRule.create_rename_and_assign_rule_if_not_exists(ProcessingRule.get_category_name_rules, original_item_name, @item.payee_name, @item.category_name)
    end

    LineItem.reset_balance

    render :json => {:replace_id => params[:id], :content => render_to_string('_item', :layout => false, :locals => {:item => @item})}
  end

  def destroy
    @item = LineItem.find(params[:id])
    @item.delete
    LineItem.reset_balance
    render :json => {:remove_id => params[:id]}
  end

  def show

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
    @payees = @account.line_items.all_unrenamed_payees
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

  def on_around_update_assign_old_payee_name
    previous_name = payee_name
    yield
    if payee_name != previous_name and original_payee_name.blank?
      original_payee_name = previous_name
      save
    end
  end
end
