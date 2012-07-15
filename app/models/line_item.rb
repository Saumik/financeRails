require 'spanned_line_item_support'

class LineItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpannedLineItemSupport

  belongs_to :account
  has_one :imported_line, :dependent => :destroy

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
  field :account_id

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

  def signed_amount
    amount * multiplier
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

  def self.payees
    LineItem.only(:payee_name).collect(&:payee_name).delete_if(&:nil?).uniq.sort
  end

  def self.categories
    LineItem.only(:category_name).collect(&:category_name).delete_if(&:nil?).uniq.sort
  end

  def self.all_last_data_for_payee
    LineItem.all.inject({}) do |result, item|
      result[item.payee_name.to_s] = { amount: item.amount.to_f, category_name: item.category_name }
      result
    end
  end

  def has_processing_rule_of_type(item_type, ignore_rule = nil)
    processing_rules.any? do |processing_rule|
      processing_rule.item_type == item_type and (ignore_rule.nil? or processing_rule != ignore_rule)
    end
  end

  def self.rename_payee(old_name, new_name)
    @line_items = LineItem.where(:payee_name => old_name)
    @line_items.each do |item|
      item.original_payee_name ||= old_name
      item.payee_name = new_name
      item.save
    end
  end

  def self.expense_in_month(date, categories)
    LineItem.where(
        :event_date => {'$gte' => date.beginning_of_month.to_datetime,'$lt' => date.end_of_month.to_datetime},
        :category_name.in => categories
                ).default_sort.to_a.sum(&:signed_amount)
  end

  def self.all_unrenamed_payees
    LineItem.where(:original_payee_name => nil).collect(&:payee_name).uniq.sort
  end

  def to_json_as_imported
    to_json(:only => [:amount, :event_date, :payee_name, :type, :comments])
  end
end
