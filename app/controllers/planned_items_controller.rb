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
end
