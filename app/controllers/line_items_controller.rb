class LineItemsController < ApplicationController
  def index
    @line_item = LineItem.new
    #@line_items = LineItem.list_all
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
      processing_rules = ProcessingRule.all_matching(all_processing_rules, line_item)
      processing_rules.each { |rule| rule.perform(line_item) }
    end

    @line_item = changed_line_item.clone_new
  end

  def edit
    @line_item = LineItem.find(params[:id])

    if(@line_item.spanned)
      @line_item = LineItem.find(@line_item.spanned.master_line_item_id)
      puts @line_item.spanned.master_line_item_id
    end
  end

  def update
    @changed_line_item = LineItem.find(params[:id])
    @changed_line_item.update_attributes(params[:line_item])
    LineItem.reset_balance

    @line_item = LineItem.new
    @line_item.event_date = @changed_line_item.event_date
  end

  def destroy
    @changed_line_item = LineItem.find(params[:id])
    @changed_line_item.delete
    LineItem.reset_balance

    @line_item = LineItem.new
    @line_item.event_date = @changed_line_item.event_date
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
end
