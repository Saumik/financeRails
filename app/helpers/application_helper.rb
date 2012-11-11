module ApplicationHelper
  def format_number(num)
    number_with_precision(num, :precision => 2, :strip_insignificant_zeros => true)
  end

  def date_format(date)
    date.strftime('%m/%d/%Y')
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

  def month_year_short(date)
    date.month.to_s + date.year.to_s
  end

  def months_between(start_month, end_month)
    months = []
    ptr = start_month
    while ptr <= end_month.end_of_month do
      months << ptr
      ptr = ptr >> 1
    end
    months
  end

  def date_in_month_of(date, date_for_month)
    date.year == date_for_month.year && date.month == date_for_month.month
  end

  def currency(amount)
    '<span class="dollar">$</span>' + format_number(amount).to_s
  end

  def currency_abs(amount)
    '<span class="dollar">$</span>' + format_number(amount.abs)
  end

  def sign_and_currency(amount)
    amount > 0 ? '+' + currency(amount) : '-' + currency(amount)
  end

  def capitalize_words(str)
   str.split(' ').map {|w| w.capitalize }.join(' ')
  end
end
