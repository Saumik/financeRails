module ApplicationHelper
  def format_number(num)
    number_with_precision(num, :precision => 2)
  end
end
