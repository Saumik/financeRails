require 'spanned_line_item_support'

class LineItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpannedLineItemSupport

  TYPE = %w[income expense]
  INCOME = 0
  EXPENSE = 1

  SOURCE_IMPORT = 0
  SOURCE_MANUAL = 1

  TRANSFER_IN = 'Transfer In'
  TRANSFER_OUT = 'Transfer Out'
  TAG_EXCLUDE_FROM_REPORTS = 'Exclude from Reports'
  TAG_CASH = 'Cash'
  TAGS = [TAG_CASH, TAG_EXCLUDE_FROM_REPORTS]
  INCOME_CATEGORIES = ['Salary']
  TRANSFER_CASH_CATEGORY_NAME = 'Transfer:Cash'

  around_update :on_around_update_assign_old_payee_name

  belongs_to :account
  has_one :imported_line, :dependent => :destroy

  field :type, :type => Integer, :default => 1
  field :amount, :type => BigDecimal, :default => 0
  field :event_date, :type => Date, :default => Time.now.to_date
  field :category_name, :type => String
  field :payee_name, :type => String
  field :original_payee_name
  field :comment, :type => String
  field :account_id
  field :tags, :type => Array, :default => []
  field :source, :type => Integer, :default => 0

  field :balance, :type => BigDecimal

  has_and_belongs_to_many :processing_rules, inverse_of: nil

  scope :default_sort, desc(:event_date, :created_at, :id)

  def type_name
    TYPE[type].capitalize
  end

  def income?
    type == INCOME
  end

  def self.income_items
    where(:category_name.in => INCOME_CATEGORIES)
  end

  def self.expense_items
    where(:category_name.nin => INCOME_CATEGORIES)
  end

  class << self
    alias :expenses_items :expense_items
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

  def clone_all
    attribute_values = attributes.select {|a| !%w(id, _id, created_at).include? a}
    attribute_values.delete('_id')
    LineItem.new attribute_values
  end

  def clone_new
    LineItem.new(:event_date => event_date)
  end

  # splitted_item_fields should have the fields :amount, :category_name
  def split_from_item(splitted_item_fields)
    new_item = clone_all
    new_item.amount = splitted_item_fields[:amount].to_f
    new_item.category_name = splitted_item_fields[:category_name]
    new_item.save!
    new_item
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

  def self.all_unrenamed_payees(account_or_user)
    account_or_user.line_items.where(source: SOURCE_IMPORT, original_payee_name: nil).inject({}) do |result, line_item|
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

  def self.sum_with_filters(user_or_account, filters = {}, post_process = nil)
    filter_chain = get_filters(user_or_account, filters)
    items = filter_chain.default_sort.to_a
    items = add_spanned_items(filters, items)
    items = post_process.present? ? post_process.perform_after(items) : items
    items.sum(&:signed_amount)
  end

  def self.search_with_filters(user_or_account, filters = {})
    filter_chain = get_filters(user_or_account, filters)
    filter_chain.default_sort
  end

  private
  def self.get_filters(user_or_account, filters = {})
    filter_chain = user_or_account.line_items
    filter_chain = in_month_of_date(filters[:in_month_of_date], filter_chain) if filters[:in_month_of_date].present?
    filter_chain = send(filters[:section].to_s + '_items') if filters[:section].present?
    filter_chain = where(:category_name.in => filters[:categories]) if filters[:categories].present?
    filter_chain = filter_chain.where(category_name: /^#{filters[:matching_category_prefix]}.*/) if filters[:matching_category_prefix].present?
    filter_chain = filter_chain.where(:type => filters[:type]) if filters[:type].present?
    filter_chain = add_spanning_filters(filter_chain, filters)
    filter_chain
  end
  public

  # end reporting functions
  # ---------------------------

  # ---------------------------
  # Mobile support functions

  def self.serialize_from_mobile(params)
    params.symbolize_keys!
    {:type => params[:type],
                        :amount => params[:amount],
                        :event_date => params[:event_date],
                        :category_name => params[:category_name],
                        :payee_name => params[:payee_name],
                        :comment => params[:comment],
                        :source => SOURCE_MANUAL}
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
