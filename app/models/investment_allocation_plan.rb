class InvestmentAllocationPlan
  include Mongoid::Document

  field :name, type: String
  field :percent, type: Float

  embedded_in :investment_plan
  embedded_in :investment_allocation_plan
  embeds_many :investment_assets

  embeds_many :investment_allocation_plans

  def children_count
    level2_count = investment_allocation_plans.length
    level3_count = investment_assets.length

    if level3_count > 0
      level3_count
    else
      investment_allocation_plans.collect(&:leaf_count).sum
    end
  end

  def leaf_count
    investment_assets.length
  end

  def actual_percent
    if investment_allocation_plan.present?
      percent * investment_allocation_plan.percent
    else
      percent
    end
  end

  def total_amount
    if investment_assets.length > 0
      investment_assets.collect(&:worth).sum
    else
      investment_allocation_plans.collect(&:total_amount).sum
    end
  end

  def total_gap
    if investment_assets.length > 0
      investment_assets.collect { |asset| asset.total_gap }.sum
    else
      investment_allocation_plans.collect { |plan| plan.total_gap }.sum
    end
  end


  def deep_collect_investment_assets
    (investment_allocation_plans.collect(&:deep_collect_investment_assets) + investment_assets.to_a).flatten.uniq
  end

  def self.find_in_array(collection, id)
    id = Moped::BSON::ObjectId.from_string(id)
    collection.find { |item| item.id == id }
  end
end
