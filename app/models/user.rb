class User
  include Mongoid::Document
  include User::LineItemAggregateMethods

  has_many :accounts
  has_many :planned_items
  has_one :default_account, class_name: 'Account'

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  if Rails.env.production?
    devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  else
    devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :registerable
  end

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  field :mobile_password,    :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :last_date, :type => Date
  field :default_account_id

  has_one :investment_plan

  # cross accounts functions
  def line_items
    LineItem.where(:account_id.in => accounts.collect(&:id))
  end

  def investment_line_items
    InvestmentLineItem.where(:account_id.in => accounts.collect(&:id))
  end

  def investment_allocation_plans
    first_level = investment_plan.investment_allocation_plans
    second_level = first_level.collect(&:investment_allocation_plans).flatten
    third_level = second_level.collect(&:investment_allocation_plans).flatten
    first_level + second_level + third_level
  end

  def investment_assets
    investment_allocation_plans.collect(&:deep_collect_investment_assets).flatten
  end

  def cash_balance
    income_cash = line_items.where(:category_name => LineItem::TRANSFER_CASH_CATEGORY_NAME).collect(&:amount).sum
    line_items_cash = line_items.where(:tags => LineItem::TAG_CASH).collect(&:signed_amount).sum
    income_cash + line_items_cash
  end

  def update_asset_by_symbol(symbol)
    investment_asset = investment_assets.find {|ia| symbol == ia.symbol}
    investment_asset.update_from_last_status(investment_line_items) if investment_asset.present?
  end

  def set_mobile_password(password)
    self.mobile_password = ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
  end
end
