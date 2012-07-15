class GroceriesTotalReport < ReportPageGenerator
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
  def header_columns
    @months
  end
  def first_column_title
    'Item Name'
  end
  def dataset(params)

  end
end