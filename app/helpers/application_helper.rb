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

  def currency(amount)
    '<span class="dollar">$</span>' + format_number(amount).to_i.to_s
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
