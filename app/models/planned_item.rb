class PlannedItem
  include Mongoid::Document

  # income - date range
  # expense - date

  TYPE_INCOME = :income
  TYPE_EXPENSE = :expense

  field :type, type: Symbol, default: TYPE_INCOME
  field :event_date_from, type: Date
  field :event_date_until, type: Date
  field :amount, type: Integer

  belongs_to :user
end
