class PlannedItemsController < ApplicationController
  def create
    @item = current_user.planned_items.create(params[:planned_item])

    respond_to do |format|
      format.js { render layout: false }
    end
  end
  def new
    @item = PlannedItem.new

    respond_to do |format|
      format.js { render layout: false }
    end
  end
  def edit
    @item = current_user.planned_items.find(params[:id])
    respond_to do |format|
      format.js { render layout: false }
    end
  end
  def update
    @item = PlannedItem.find(params[:id])
    @item.attributes = params[:planned_item]
    @item.save

    render :layout => false
  end
end
