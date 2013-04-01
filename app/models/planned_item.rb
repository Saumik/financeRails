class PlannedItem
  include Mongoid::Document

  # income - date range
  # expense - date

  TYPE_INCOME = :income
  TYPE_EXPENSE = :expense

  field :type, type: Symbol, default: TYPE_INCOME
  field :event_date_start, type: Date, default: Time.now.to_date
  field :event_date_end, type: Date, default: Time.now.to_date
  field :category_name, type: String
  field :description, type: String
  field :amount, type: Integer

  belongs_to :user

  def income?
    type == TYPE_INCOME
  end

  def beginning_month_in_year(year)
    if event_date_start.year == year
      event_date_start.month
    else
      1
    end
  end

  def end_month_in_year(year)
    if event_date_end.year == year
      event_date_end.month
    else
      12
    end
  end
end
