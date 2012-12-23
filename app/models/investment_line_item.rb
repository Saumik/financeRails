class InvestmentLineItem
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE_STATUS = :status
  TYPE_BUY = :buy
  TYPE_SELL = :sell

  # Status: symbol, amount, worth
  # purchase: symbol, number, amount
  # sell: symbol, amount
  # interest: amount
  # deposit: amount
  field :type, type: Symbol, default: TYPE_STATUS
  field :event_date, type: Date, default: Time.now.to_date
  field :symbol, type: String
  field :number, type: Integer, default: 0
  field :amount, type: BigDecimal, default: 0

  belongs_to :account

  def type_name
    type.capitalize
  end
end
