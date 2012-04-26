class LineItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpannedLineItem

  TYPE = %w[income expense]
  INCOME = 0
  EXPENSE = 1

  TRANSFER_IN = 'Transfer In'
  TRANSFER_OUT = 'Transfer Out'

  field :type, :type => Integer, :default => 1
  field :amount, :type => BigDecimal, :default => 0
  field :event_date, :type => Date, :default => Time.now.to_date
  field :category_name
  field :payee_name
  field :original_payee_name
  field :comment

  field :balance, :type => BigDecimal

  has_and_belongs_to_many :processing_rules, inverse_of: nil

  scope :default_sort, desc(:event_date, :created_at)

  def type_name
    TYPE[type].capitalize
  end

  def income?
    type == INCOME
  end

  def expense?
    type == EXPENSE
  end

  # 1 for income, -1 for expense
  def multiplier
    type == EXPENSE ? -1 : 1
  end

  def event_date_string(str)
    event_date = Date.parse(str)
  end

  def self.reset_balance
    current_balance = 0

    default_sort.reverse.each do |item|

      if(!item.virtual)
        current_balance += item.amount * item.multiplier
      end

      if(item.balance != current_balance)
        item.balance = current_balance
        item.save
      end
    end
  end

  def clone_all
    attribute_values = attributes.select {|a| !%w(id, _id, created_at).include? a}
    attribute_values.delete('_id')
    LineItem.new attribute_values
  end

  def clone_new
    LineItem.new(:event_date => event_date)
  end

  def self.payee_names
    LineItem.only(:payee_name).collect(&:payee_name).delete_if(&:nil?).uniq.sort
  end

  def has_processing_rule_of_type(type)
    processing_rules.any? do |processing_rule|
      processing_rule.type == type
    end
  end
end
