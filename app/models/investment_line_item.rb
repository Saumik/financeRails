class InvestmentLineItem
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE_STATUS = :status
  TYPE_BUY = :buy
  TYPE_SELL = :sell
  TYPE_DEPOSIT = :deposit
  TYPE_DIVIDEND = :dividend
  TYPE_INTEREST = :interest

  # Status: symbol, amount (last price), worth
  # purchase: symbol, number, amount (last price), cost (total cost), fee
  # sell: symbol, number, amount (last price), cost (total earning), fee
  # interest: amount
  # deposit: amount
  # dividend
  field :type, type: Symbol, default: TYPE_STATUS
  field :event_date, type: Date, default: Time.now.to_date
  field :symbol, type: String
  field :number, type: Integer, default: 0
  field :amount, type: BigDecimal, default: 0
  field :total_amount, type: BigDecimal, default: 0
  field :fee, type: BigDecimal, default: 0

  scope :default_sort, desc(:event_date, :created_at, :id)

  belongs_to :account
  has_one :imported_line

  def type_name
    type.capitalize
  end

  def to_json_as_imported
    to_json(:only => [:type, :event_date, :symbol, :number, :amount, :total_amount, :fee])
  end
end
