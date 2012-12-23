class InvestmentPlan
  include Mongoid::Document

  belongs_to :user
  embeds_many :investment_allocation_plans
end
