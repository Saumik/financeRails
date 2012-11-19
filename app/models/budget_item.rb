class BudgetItem
  include Mongoid::Document

  field :categories, type: Array
  field :name, type: String
  field :limit, type: Integer
  field :budget_year, type: Integer
  field :starting_budget, type: BigDecimal, default: 0
  field :estimated_min_monthly_amount, type: Integer, default: 0

  scope :default_sort, asc(:name)

  def self.existing_categories
    BudgetItem.all.collect(&:categories).flatten
  end
end
