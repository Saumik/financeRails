class LineItemsController < ApplicationController
  def index
    @account = current_user.accounts.find(params[:account_id]) if params[:account_id]

    unless @account.present?
      render 'common/select_account' and return
    end

    @new_item = @account.line_items.build
    @items = @account.line_items.default_sort
  end

  def create
    changed_line_item = LineItem.create(params[:line_item])

    @changed_line_items = []
    if(params[:spanned])
      @changed_line_items += changed_line_item.span(params[:spanned_amount].to_i)
    else
      @changed_line_items << changed_line_item
    end

    LineItem.reset_balance

    all_processing_rules = ProcessingRule.all
    @changed_line_items.each do |line_item|
      ProcessingRule.perform_all_matching(all_processing_rules, line_item)
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
    @item.update_attributes(params[:line_item])
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
    @payees = LineItem.all_unrenamed_payees
  end
end
