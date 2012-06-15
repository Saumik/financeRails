module DateTimeHelpers
  def months_between(start_month, end_month)
    months = []
    ptr = start_month
    while ptr <= end_month do
      months << ptr
      ptr = ptr >> 1
    end
    months
  end
end