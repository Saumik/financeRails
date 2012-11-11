class BudgetItem
  include Mongoid::Document

  field :categories, type: Array
  field :name, type: String
  field :limit, type: Integer
  field :budget_year, type: Integer
  field :starting_budget, type: BigDecimal, default: 0

  def self.existing_categories
    BudgetItem.all.collect(&:categories).flatten
  end
end
