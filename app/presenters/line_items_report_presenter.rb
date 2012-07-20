class LineItemsReportPresenter
  attr_reader :months
  def initialize
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
    LineItem.where(:type => @section_to_type[section]).to_a.collect(&:category_name).uniq.delete_if(&:blank?)
  end

  def total_amount_of_type_in_month(section, category_name, month, year)
    current_date = Date.new(year, month, 1)
    LineItem.sum_with_filters(:type => @section_to_type[section], :categories => [category_name], :in_month_of_date => current_date).tap do |amount|
      @month_totals["#{section}:#{month}:#{year}"] ||= 0
      @month_totals["#{section}:#{month}:#{year}"] += amount.to_f.abs
    end
  end

  def month_section_total(section, month, year)
    @month_totals["#{section}:#{month}:#{year}"] || 0.0
  end

  def month_total(month, year)
    (@month_totals["income:#{month}:#{year}"] || 0.0).to_f - (@month_totals["expense:#{month}:#{year}"] || 0.0).to_f
  end

  def total_label_section(section)
    'Total ' + section.to_s.capitalize
  end

  def section_class(section)
    section.to_s
  end
end