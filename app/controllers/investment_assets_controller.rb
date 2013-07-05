class InvestmentAssetsController < ApplicationController
  MODEL_CLASS = InvestmentAsset
  PARAMS_OBJECT = :investment_asset

  def new
    @item = MODEL_CLASS.new
    @investment_allocation_plans = current_user.investment_allocation_plans
    render layout: false
  end

  def create
    allocation_plan = current_user.investment_allocation_plans.to_a.find {|ap| ap.id.to_s == params[:investment_asset][:investment_allocation_plan].to_s }
    params[:investment_asset].delete(:investment_allocation_plan)
    allocation_plan.investment_assets.create(params[:investment_asset])

    render layout: false
  end

  def edit
    @item = MODEL_CLASS.find_in_array(current_user.investment_assets, params[:id])
    @investment_allocation_plans = current_user.investment_allocation_plans
    raise Mongoid::Errors::DocumentNotFound.new(MODEL_CLASS, params, [params[:id]]) if @item.nil?
    render layout: false
  end

  def update
    @item = MODEL_CLASS.find_in_array(current_user.investment_assets, params[:id])
    raise Mongoid::Errors::DocumentNotFound.new(MODEL_CLASS, params, [params[:id]]) if @item.nil?
    @item.attributes = params[PARAMS_OBJECT]
    @item.save

    respond_to do |format|
      format.js { render :layout => false }
    end
  end
end