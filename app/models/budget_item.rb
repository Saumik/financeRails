class BudgetItem
  include Mongoid::Document

  field :categories, type: Array
  field :name, type: String
  field :limit, type: Integer
  field :budget_year, type: Integer, default: Time.now.year
  field :starting_budget, type: BigDecimal, default: 0
  field :estimated_min_monthly_amount, type: Integer, default: 0

  scope :default_sort, asc(:name)

  belongs_to :user

  def self.existing_categories(current_user, year = Time.now.year)
    current_user.budget_items.where(budget_year: year).collect(&:categories).flatten
  end
end
