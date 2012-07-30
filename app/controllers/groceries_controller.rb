class GroceriesController < ApplicationController
  MAIN_OBJECT = GroceryLineItem
  FORM_NAME = 'grocery_line_item'

  def create
    prepare_params_form
    @item = MAIN_OBJECT.create(params[FORM_NAME])
    render :json => {:prepend => true, :content => render_to_string('_item', :layout => false, :locals => {:item => @item}) }
  end

  def index
    @new_item = MAIN_OBJECT.new
    @items = MAIN_OBJECT.all.reverse
  end

  def show

  end

  def edit
    @item = MAIN_OBJECT.find(params[:id])
    render :layout => false
  end

  def update
    prepare_params_form
    @item = MAIN_OBJECT.find(params[:id])
    @item.update_attributes(params[FORM_NAME])
    render :json => {:replace_id => params[:id], :content => render_to_string('_item', :layout => false, :locals => {:item => @item})}
  end

  def destroy
    @item = MAIN_OBJECT.find(params[:id])
    @item.destroy
    render :json => {:remove_id => params[:id]}
  end

  def report
    @presenter = GroceryReportPresenter.new
  end

  private

  def prepare_params_form
    params['grocery_line_item']['price_per_unit'] = params['grocery_line_item']['price_per_unit'].to_f
    params['grocery_line_item']['units'] = params['grocery_line_item']['units'].to_f
  end
end
