module ApplicationHelper
  def format_number(num)
    number_with_precision(num, :precision => 2)
  end

  def with_comma_separated(arr)
    results = []
    arr.each do |item|
      results << yield(item)
    end
    results.join(',')
  end

  def month_name(m)
    Date::MONTHNAMES[m]
  end

  def currency(amount)
    number_to_currency(amount)
  end
end
