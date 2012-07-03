class GroceryLineItem
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE_WEIGHT = 'lb'
  TYPE_REGULAR = ''

  field :event_date, :type => Date, :default => Time.now.to_date
  field :name, :type => String
  field :store, :type => String
  field :price_per_unit, :type => BigDecimal, :default => 0
  field :units, :type => BigDecimal, :default => 0

  field :unit_type, :type => String

  scope :default_sort, desc(:event_date, :created_at)

  def amount
    units * price_per_unit
  end

  def self.all_store_names
    GroceryLineItem.only(:store).collect(&:store).to_a.uniq.compact
  end

  def self.all_item_names
    GroceryLineItem.only(:name).collect(&:name).to_a.uniq.compact
  end

  def self.all_last_prices
    GroceryLineItem.all.inject({}) do |result, item|
      result[item.store.to_s + ':' + item.name.to_s] = { amount: item.amount.to_f, units: item.units.to_f, price_per_unit: item.price_per_unit.to_f, unit_type: item.unit_type }
      result
    end
  end

  def self.items_for_store(store)
    GroceryLineItem.where(:store => store).collect(&:name).to_a.uniq.compact
  end

  def self.total_amount_of_store_item_in_month(store, item, month, year)
    GroceryLineItem.where(:store => store, :name => item).keep_if {|item| item.event_date.month == month && item.event_date.year == year}.sum(&:amount)
  end
end
