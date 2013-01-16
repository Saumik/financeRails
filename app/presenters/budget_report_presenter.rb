class BudgetReportPresenter
  attr_reader :months, :current_user, :active_year, :grouped_items

  def initialize(current_user, active_year)
    @active_year = (active_year || Time.now.year).to_i
    @budget_items = BudgetItem.where(budget_year: @active_year).default_sort
    @line_items = current_user.line_items.where(event_date: Date.new(@active_year, 1, 1).beginning_of_year..Date.new(@active_year, 1, 1).end_of_year).to_a
    @current_user = current_user
    @totals = {}

    @grouped_items = {}
    @line_items.each do |line_item|
      next unless line_item.grouped_label.present?
      item = @grouped_items[line_item.grouped_label] ||= {amount: 0, month: 12, label: line_item.grouped_label}
      item[:amount] += line_item.signed_amount
      item[:month] = [item[:month], line_item.event_date.month].min
    end
    @grouped_items = @grouped_items.values.sort_by {|item| item[:month]}
  end

  def months
    1..12
  end

  def budget_year_range
    (BudgetItem.min(:budget_year).to_i)..(BudgetItem.max(:budget_year).to_i)
  end

  def budget_items
    @budget_items
  end

  def grouped_item_label(grouped_item)
    item = grouped_item
    "#{grouped_item[:label]} (#{Date.new(@active_year, item[:month]).strftime('%B')}): Total: #{item[:amount]*-1}"
  end

  def in_future?(month)
    month > Time.now.month and @active_year == Time.now.year
  end

  def future_amount(budget_item)
    @totals[budget_item.name] ||= 0
    @totals[budget_item.name] -= budget_item.estimated_min_monthly_amount

    budget_item.estimated_min_monthly_amount
  end

  def future_income(month)
    found_income = current_user.planned_items.where(:event_date_begin.gt => Date.new(@active_year, month, 1), :event_date_end.lt => Date.new(@active_year, month, 1).end_of_month ).first
    income_for_month = found_income ? found_income.amount : 0
    @totals['Income'] ||= 0
    @totals['Income'] += income_for_month
    income_for_month
  end

  def total_expenses_for_budget_item_in_month(budget_item, month)
    #noinspection RubyArgCount
    current_date = Date.new(@active_year, month, 1)
    amount = LineItem.inline_sum_with_filters(@current_user, @line_items, {
                                              :categories => budget_item.categories,
                                              :in_month_of_date => current_date
                                              }, LineItemReportProcess.new)
    @totals[budget_item.name] ||= 0
    @totals[budget_item.name] += amount
    amount * -1
  end

  def total_expenses_for_budget_item_in_year(budget_item)
    @totals[budget_item.name] * -1
  end

  def amount_left_budget_item_in_year(budget_item)
    @totals[budget_item.name] + budget_item.limit.to_i.to_f * 12
  end

  def total_limit
    @budget_items.collect(&:limit).compact.sum
  end

  def income_at(month)
    income_for_month = @line_items.select { |li| li.event_date.month == month and LineItem::INCOME_CATEGORIES.include? li.category_name }.sum(&:signed_amount)
    @totals['Income'] ||= 0
    @totals['Income'] += income_for_month
    income_for_month
  end

  def total_income
    @totals['Income']
  end

  def percent_expense(budget_item)
    (((@totals[budget_item.name] * -1).to_f / @totals['Income'].to_f) * 100).to_i.to_s + '%'
  end
end