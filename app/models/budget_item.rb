class BudgetItem
  include Mongoid::Document

  field :categories, type: Array
  field :name, type: String
  field :limit, type: Integer

  def self.existing_categories
    BudgetItem.all.collect(&:categories).flatten
  end
end
