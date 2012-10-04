class LineItemsReportPresenter
  attr_reader :months, :current_user
  def initialize(current_user, filters)
    @filters = filters
    @current_user = current_user
    first_date = LineItem.asc(:event_date).first.event_date.beginning_of_month
    last_date = LineItem.desc(:event_date).first.event_date.end_of_month
    @months = []
    @section_to_type = {:income => LineItem::INCOME, :expenses => LineItem::EXPENSE}
    current_month = first_date
    while current_month <= last_date do
      @months << [current_month.month, current_month.year]
      current_month = current_month.advance(:months => 1)
    end
    @month_totals = {}
  end
  def report_sections
    [:income, :expenses]
  end

  def categories_matching(section)
    categories = LineItem.send(section.to_s + '_items')
    categories.to_a.collect(&:category_name).uniq.delete_if(&:blank?).sort
  end

  def root_categories_matching(section)
    categories_matching(section).collect { |name| name.split(':').first }.uniq
  end

  def child_categories_of(section, category_name)
    categories_matching(section).select { |name| name.split(':').first == category_name }.uniq
  end

  def total_amount_of_type_in_month(section, category_name, month, year, count_for_total)
    current_date = Date.new(year, month, 1)
    current_filters = @filters.merge({:matching_category_prefix => category_name,
                                   :in_month_of_date => current_date})
    LineItem.sum_with_filters(current_user, current_filters,
                              LineItemReportProcess.new).tap do |amount|
      @month_totals["#{section}:#{month}:#{year}"] ||= 0
      @month_totals["#{section}:#{month}:#{year}"] += amount.to_f.abs if count_for_total
    end
  end

  def month_section_total(section, month, year)
    @month_totals["#{section}:#{month}:#{year}"] || 0.0
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