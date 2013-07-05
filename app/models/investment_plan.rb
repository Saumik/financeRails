class InvestmentPlan
  include Mongoid::Document

  belongs_to :user
  embeds_many :investment_allocation_plans

  def portfolio_size
    portfolio_size ||= user.investment_assets.sum(&:worth)    
  end
end
