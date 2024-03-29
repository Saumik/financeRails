class LineItemsReportPresenter
  attr_reader :months, :current_user, :active_year
  def initialize(current_user, filters, active_year)
    @active_year = (active_year || Time.now.year).to_i
    @line_items = current_user.line_items.where(event_date: Date.new(@active_year, 1, 1).beginning_of_year..Date.new(@active_year, 1, 1).end_of_year).asc(:event_date).to_a

    @filters = filters

    @current_user = current_user
    if @line_items.length > 0
      first_date = @line_items.first.event_date.beginning_of_month
      last_date = @line_items.last.event_date.end_of_month
    else
      last_date = first_date = Time.now
    end
    @months = []
    @section_to_type = {:income => LineItem::INCOME, :expenses => LineItem::EXPENSE}
    current_month = first_date
    while current_month <= last_date do
      @months << [current_month.month, current_month.year]
      current_month = current_month.advance(:months => 1)
    end

    @filters[:avg_from] ||= Date.new(@months.first[1], @months.first[0], 1)
    @filters[:avg_until] ||= Date.new(@months.last[1], @months.last[0], 1)

    @month_totals = {}
    @category_avgs = {}

    @total_income = @line_items.select { |li| LineItem::INCOME_CATEGORIES.include? li.category_name }.sum(&:signed_amount)
  end

  def line_items_year_range
    (current_user.line_items.min(:event_date).year)..(current_user.line_items.max(:event_date).year)
  end

  def report_sections
    [:income, :expenses]
  end

  def categories_matching(section)
    @cached_categories ||= {}
    @cached_categories[section] ||= LineItem.send(section.to_s + '_items').to_a
    @cached_categories[section].collect(&:category_name).uniq.delete_if(&:blank?).sort
  end

  def root_categories_matching(section)
    categories_matching(section).inject({}) do |result, name|
      root_category_name = name.split(':').first
      result[root_category_name] ||= []
      result[root_category_name] << name
      result
    end
  end

  def child_categories_of(section, category_name)
    categories_matching(section).select { |name| name.split(':').first == category_name }.uniq
  end

  def amount_of_type_in_month(section, category_name, contains_categories, month, year, count_for_total)
    contains_categories ||= [category_name]
    current_date = Date.new(year, month, 1)
    current_filters = @filters.merge({:categories => contains_categories,
                                   :in_month_of_date => current_date,
                                     :in_year => @active_year})

    LineItem.inline_sum_with_filters(@current_user, @line_items, current_filters, LineItemReportProcess.new).tap do |amount|
      @month_totals["#{section}:#{month}:#{year}"] ||= 0
      @month_totals["#{section}:#{month}:#{year}"] += amount.to_f.abs if count_for_total
      @category_avgs["#{section}:#{category_name}:#{count_for_total}"] ||= 0
      if current_date <= @filters[:avg_until]
        @category_avgs["#{section}:#{category_name}:#{count_for_total}"] += amount.to_f.abs
      end
    end
  end

  def avg_amount_of_type_in_month(section, category_name, count_for_total)
    @category_avgs["#{section}:#{category_name}:#{count_for_total}"] / (@filters[:avg_until].month - @filters[:avg_from].month + 1)
  end

  def total_amount_of_type_in_month(section, category_name, count_for_total)
    @category_avgs["#{section}:#{category_name}:#{count_for_total}"]
  end

  def percent_of_expenses_from_income(section, category_name, count_for_total)
    ((@category_avgs["#{section}:#{category_name}:#{count_for_total}"].to_f / @total_income.to_f) * 100).to_i.to_s + '%'
  end

  def month_section_total(section, month, year)
    current_date = Date.new(year, month, 1)
    total = @month_totals["#{section}:#{month}:#{year}"] || 0.0

    @category_avgs["#{section}:section-total"] ||= 0
    if current_date <= @filters[:avg_until]
      @category_avgs["#{section}:section-total"] += total
    end

    total
  end

  def section_total_avg(section)
    @category_avgs["#{section}:section-total"] / (@filters[:avg_until].month - @filters[:avg_from].month + 1)
  end

  def section_total_sum(section)
    @category_avgs["#{section}:section-total"]
  end

  def section_avg_gain
    section_total_avg(:income) - section_total_avg(:expenses)
  end

  def total_gain
    section_total_sum(:income) - section_total_sum(:expenses)
  end

  def month_total(month, year)
    (@month_totals["income:#{month}:#{year}"] || 0.0).to_f - (@month_totals["expenses:#{month}:#{year}"] || 0.0).to_f
  end

  def total_label_section(section)
    'Total ' + section.to_s.capitalize
  end

  def section_class(section)
    section.to_s
  end
end