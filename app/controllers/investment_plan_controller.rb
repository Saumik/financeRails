class InvestmentPlanController < ApplicationController
  MODEL_CLASS = InvestmentPlan
  PARAMS_OBJECT = :investment_plan

  def edit
    @item = current_user.investment_plan
    raise Mongoid::Errors::DocumentNotFound.new(MODEL_CLASS, params, [params[:id]]) if @item.nil?
    render layout: false
  end

  def update
    @item = current_user.investment_plan
    raise Mongoid::Errors::DocumentNotFound.new(MODEL_CLASS, params, [params[:id]]) if @item.nil?
    @item.attributes = params[PARAMS_OBJECT]
    @item.save

    respond_to do |format|
      format.js { render :layout => false }
    end
  end


end
