require 'spanned_line_item_support'

class LineItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpannedLineItemSupport

  TAGS = ['Cash', 'Exclude from Reports']

  around_update :on_around_update_assign_old_payee_name

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
  field :category_name, :type => String
  field :payee_name, :type => String
  field :original_payee_name
  field :comment, :type => String
  field :account_id
  field :tags, :type => Array, :default => []

  field :balance, :type => BigDecimal

  has_and_belongs_to_many :processing_rules, inverse_of: nil

  scope :default_sort, desc(:event_date).asc(:created_at, :id)

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

  def original_name
    original_payee_name.present? ? original_payee_name : payee_name
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

  def self.valid_payees
    LineItem.only(:payee_name).where(:original_payee_name.ne => nil).collect(&:payee_name).delete_if(&:nil?).uniq.sort
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

  def self.mass_rename_and_assign_category(account, original_payee_name, payee_name, category_name)
    @line_items = account.line_items.where(:payee_name => original_payee_name, :original_payee_name => nil)
    @line_items.each do |item|
      item.original_payee_name ||= payee_name
      item.payee_name = payee_name
      item.category_name = category_name
      item.save
    end
  end

  def self.all_unrenamed_payees
    LineItem.where(:original_payee_name => nil).inject({}) do |result, line_item|
      result[line_item.payee_name] ||= line_item.category_name if line_item.payee_name.present?
      result
    end
  end

  def to_json_as_imported
    to_json(:only => [:amount, :event_date, :payee_name, :type, :comments])
  end

  def self.in_month_of_date(in_month_of_date, filter_chain = Mongoid::Criteria.new(LineItem))
    filter_chain.where(:event_date => {'$gte' => in_month_of_date.beginning_of_month.to_datetime,'$lte' => in_month_of_date.end_of_month.to_datetime})
  end

  # ---------------------------
  # Reporting Functions

  def self.sum_with_filters(filters = {})
    filter_chain = Mongoid::Criteria.new(LineItem)
    filter_chain = where(:category_name.in => filters[:categories]) if filters[:categories]
    filter_chain = in_month_of_date(filters[:in_month_of_date], filter_chain) if filters[:in_month_of_date]
    filter_chain = filter_chain.where(:type => filters[:type]) if filters[:type]
    filter_chain.default_sort.to_a.sum(&:signed_amount)
  end

  # end reporting functions
  # ---------------------------

  # ---------------------------
  # Mobile support functions

  def self.create_from_mobile(params)
    params.symbolize_keys!
    LineItem.create(:type => params[:type],
                    :amount => params[:amount],
                    :event_date => params[:event_date],
                    :category_name => params[:category_name],
                    :payee_name => params[:payee_name],
                    :comment => params[:comment]
                    )
  end

  # end mobile support functions
  # ---------------------------

  private

  def on_around_update_assign_old_payee_name
    previous_name = payee_name
    yield
    if payee_name != previous_name and original_payee_name.blank?
      original_payee_name = previous_name
      save
    end
  end
end
