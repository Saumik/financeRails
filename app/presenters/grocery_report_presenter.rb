class GroceryReportPresenter
  attr_reader :months
  def initialize
    @store_names = GroceryLineItem.all_store_names
    first_date = GroceryLineItem.asc(:event_date).first.event_date.beginning_of_month
    last_date = GroceryLineItem.desc(:event_date).first.event_date.end_of_month
    @months = []
    current_month = first_date
    while current_month <= last_date do
      @months << [current_month.month, current_month.year]
      current_month = current_month.advance(:months => 1)
    end
  end
  def store_names
    @store_names
  end

  def items_for_store(store)
    GroceryLineItem.items_for_store(store)
  end

  def total_amount_of_store_item_in_month(store, item, month, year)
    GroceryLineItem.total_amount_of_store_item_in_month(store, item, month, year)
  end
end