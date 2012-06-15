class BudgetItem
  include Mongoid::Document

  field :categories, type: Array
  field :name, type: String
  field :limit, type: Integer
end
