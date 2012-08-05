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
    changed_line_item.tags.reject!(&:blank?)
    changed_line_item.save

    @changed_line_items = []
    if params[:spanned]
      @changed_line_items += changed_line_item.span(params[:spanned_amount].to_i)
    else
      @changed_line_items << changed_line_item
    end

    LineItem.reset_balance

    all_payee_rules = ProcessingRule.get_payee_rules
    all_category_rules = ProcessingRule.get_category_name_rules
    @changed_line_items.each do |line_item|
      ProcessingRule.perform_all_matching(all_payee_rules, line_item)
      ProcessingRule.perform_all_matching(all_category_rules, line_item)
    end

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

    if(@item.spanned)
      @item = LineItem.find(@line_item.spanned.master_line_item_id)
    end

    render :layout => false
  end

  def update
    @item = LineItem.find(params[:id])

    original_item_name = @item.original_name
    @item.attributes = params[:line_item]
    @item.tags.reject!(&:blank?)
    @item.save

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
end
