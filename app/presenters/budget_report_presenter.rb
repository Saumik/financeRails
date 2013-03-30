class BudgetReportPresenter
  attr_reader :months, :current_user, :active_year, :grouped_items, :expense_box, :income_box, :planned_items

  def initialize(current_user, active_year)
    @active_year = (active_year || Time.now.year).to_i
    @budget_items = BudgetItem.where(budget_year: @active_year).default_sort
    @planned_items = current_user.planned_items.where(:event_date_start.lt => Date.new(@active_year, 1, 1).end_of_year, :event_date_end.gt => Date.new(@active_year, 1, 1).beginning_of_year)
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

    category_to_budget = {}
    @budget_items.each do |budget_item|
      budget_item.categories.each do |category_name|
        category_to_budget[category_name] = budget_item
      end
    end

    # prepare expense box
    @expense_box = Box.new
    @budget_items.each do |budget_item|
      @expense_box.add_row(budget_item)
    end
    @expense_box.set_columns(1..12, [:expense, :future_expense, :planned_expense])
    # prepare income box
    @income_box = Box.new
    @income_box.add_row(:income)
    @income_box.set_columns(1..12, [:amount, :future_income])
    # add expenses/income
    @line_items.each do |line_item|
      if !LineItemReportProcess.should_ignore?(line_item)
        if line_item.expense?
          next if line_item.spanned
          @expense_box.add_to_value(category_to_budget[line_item.category_name], line_item.event_date.month, :expense, line_item.signed_amount)
        elsif LineItem::INCOME_CATEGORIES.include? line_item.category_name
          @income_box.add_to_value(:income, line_item.event_date.month, :amount, line_item.signed_amount)
        else
          @expense_box.add_to_value(category_to_budget[line_item.category_name], line_item.event_date.month, :expense, line_item.signed_amount*-1)
        end
      end
    end
    # add spanned items
    current_user.line_items.where(spanned: true).each do |spanned_item|
      next if spanned_item.span_from.year != @active_year and spanned_item.span_until.year != @active_year
      month_from = spanned_item.span_from.month
      month_from = 1 if spanned_item.span_from.year != @active_year
      month_until = spanned_item.span_until.month
      month_until = 1 if spanned_item.span_until.year != @active_year
      (month_from..month_until).each do |month|
        @expense_box.add_to_value(category_to_budget[spanned_item.category_name], month, :expense, spanned_item.spanned_amount * -1)
      end
    end
    # add future expenses
    if @active_year == Time.now.year
      current_month = Time.now.month
      @budget_items.each do |budget_item|
        (current_month..12).each do |future_month|
          @expense_box.add_to_value(budget_item, future_month, :future_expense, budget_item.estimated_min_monthly_amount)
        end
      end
      # add planned items
      @planned_items.each do |planned_item|
        (planned_item.beginning_month_in_year(@active_year)..planned_item.end_month_in_year(@active_year)).each do |month|
          if planned_item.income?
            @income_box.add_to_value(:income, month, :future_income, planned_item.amount)
          else
            @expense_box.add_to_value(category_to_budget[planned_item.category_name], month, :planned_expense, planned_item.amount)
          end
        end
      end
    end
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

  def planned_amount(budget_item, month)

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
    @expense_box.row_totals(budget_item)[:expense]*-1 +
            @expense_box.row_totals(budget_item)[:future_expense] +
            @expense_box.row_totals(budget_item)[:planned_expense]
  end

  def amount_left_budget_item_in_year(budget_item)
    budget_item.limit.to_i.to_f * 12 - total_expenses_for_budget_item_in_year(budget_item)

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
    @income_box.row_totals(:income)[:amount] + @income_box.row_totals(:income)[:future_income]
  end

  def percent_expense(budget_item)
    ((total_expenses_for_budget_item_in_year(budget_item).to_f / total_income.to_f) * 100).to_i.to_s + '%'
  end
end