class BudgetReportPresenter
  attr_reader :months
  def initialize
    @budget_items = BudgetItem.all
    last_date = LineItem.desc(:event_date).first.event_date.end_of_month
    if last_date.month == Date.today.month
      last_date = (Date.today - 1.month).end_of_month
    end
    #first_date = LineItem.where(:event_date.gt => last_date.beginning_of_year).asc(:event_date).first.event_date.beginning_of_month
    first_date = LineItem.asc(:event_date).first.event_date.beginning_of_month
    @months = []
    current_month = first_date
    while current_month <= last_date do
      @months << [current_month.month, current_month.year]
      current_month = current_month.advance(:months => 1)
    end
    @totals = {}
  end
  def budget_items
    @budget_items
  end

  def total_expenses_for_budget_item_in_month(budget_item, month, year)
    #noinspection RubyArgCount
    current_date = Date.new(year, month, 1)
    amount = LineItem.sum_with_filters({:categories => budget_item.categories, :in_month_of_date => current_date}, LineItemReportProcess.new)
    @totals[budget_item.name] ||= 0
    @totals[budget_item.name] += amount
    amount * -1
  end

  def total_expenses_for_budget_item_in_year(budget_item)
    @totals[budget_item.name] * -1
  end

  def amount_left_budget_item_in_year(budget_item)
    @totals[budget_item.name] + budget_item.limit.to_i.to_f * @months.length
  end

  def total_limit
    @budget_items.collect(&:limit).compact.sum
  end
end