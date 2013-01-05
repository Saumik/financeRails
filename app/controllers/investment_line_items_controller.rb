class InvestmentLineItemsController < ApplicationController
  def create
    investment_account = current_user.accounts.find(params[:investment_line_item][:account_id])
    redirect_to controller: :investment, action: :index unless investment_account.present?

    @item = investment_account.investment_line_items.create params[:investment_line_item]
    if @item.type == InvestmentLineItem::TYPE_STATUS
      current_user.update_asset_by_symbol(@item.symbol)
    end

    render layout: false
  end

  def edit
    @item = InvestmentLineItem.find(params[:id])
    render layout: false
  end

  def update
    @item = InvestmentLineItem.find(params[:id])
    @item.attributes = params[:investment_line_item]
    @item.save

    current_user.update_asset_by_symbol(@item.symbol)

    respond_to do |format|
      format.js { render :layout => false }
    end
  end
end