class BudgetTotalReport < ReportPageGenerator
  def initialize
    @budget_items = BudgetItem.all.collect(&:name)
    first_date = LineItem.asc(:event_date).first.event_date.beginning_of_month
    last_date = LineItem.desc(:event_date).first.event_date.end_of_month
    @months = []
    current_month = first_date
    while current_month <= last_date do
      @months << [current_month.month, current_month.year]
      current_month = current_month.advance(:months => 1)
    end
  end
end