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

  def total_gap(portfolio_size)
    puts actual_percent
    worth - (portfolio_size * actual_percent)
  end

  def total_dividend(items)
    items.sum { |item| item.symbol == symbol && item.type == InvestmentLineItem::TYPE_DIVIDEND ? item.total_amount : 0 }
  end

  def total_gain(items)
    total_purchase = items.sum {|item| item.symbol == symbol && item.type == InvestmentLineItem::TYPE_BUY ? item.total_amount : 0 }
    total_sold = items.sum {|item| item.symbol == symbol && item.type == InvestmentLineItem::TYPE_SELL ? item.total_amount : 0 }

    worth - total_purchase - total_sold
  end

  def update_from_last_status(investment_line_items)
    last_status = investment_line_items.select {|ila| ila.type == InvestmentLineItem::TYPE_STATUS and ila.symbol == symbol}.sort_by(&:event_date).last
    if last_status.present?
      self.number = last_status.number
      self.last_price = last_status.amount
      save
    end
  end

  def self.find_in_array(collection, id)
    id = Moped::BSON::ObjectId.from_string(id)
    collection.to_a.find { |item| item.id == id }
  end
end
