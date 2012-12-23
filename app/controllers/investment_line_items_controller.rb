class InvestmentLineItemsController < ApplicationController
  def create
    investment_account = current_user.accounts.find(params[:investment_line_item][:account_id])
    redirect_to controller: :investment, action: :index unless investment_account.present?

    @item = investment_account.investment_line_items.create params[:investment_line_item]
    if @item.type == InvestmentLineItem::TYPE_STATUS
      investment_asset = current_user.investment_assets.find {|ia| @item.symbol == ia.symbol}
      if investment_asset.present?
        method_call = "update_on_#{@item.type.to_s}"
        if investment_asset.respond_to? method_call
          investment_asset.send(method_call)
          investment_asset.save
        end
      end
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

    respond_to do |format|
      format.js { render :layout => false }
    end
  end
end