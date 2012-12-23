class InvestmentAsset
  include Mongoid::Document

  field :name, type: String
  field :symbol, type: String
  field :percent, type: Float
  field :last_price, type: BigDecimal
  field :number, type: Integer
  field :currency, type: Symbol

  embedded_in :investment_allocation_plan

  belongs_to :account

  def children_count
    1
  end

  def worth
    last_price * number * currency_conversion
  end

  def currency_conversion
    if currency == :ils
      0.27
    else
      1
    end
  end

  def actual_percent
    percent * investment_allocation_plan.actual_percent
  end

  PORTFOLIO_SIZE = 60000
  def total_gap
    worth - PORTFOLIO_SIZE * (actual_percent)
  end

  def update_on_status(amount, number)
    investment_asset.last_price = amount
    investment_asset.number = number
  end

  def update_on_buy(amount, number)
    investment_asset.last_price = amount
    investment_asset.number += number
  end

  def update_on_sell(amount, number)
    investment_asset.last_price = amount
    investment_asset.number -= number
  end

  def self.find_in_array(collection, id)
    id = Moped::BSON::ObjectId.from_string(id)
    collection.find { |item| item.id == id }
  end
end
