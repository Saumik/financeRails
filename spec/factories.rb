FactoryGirl.define do
  saved_single_instances = {}
  #Find or create the model instance
  single_instances = lambda do |factory_key|
    begin
      saved_single_instances[factory_key].reload
    rescue NoMethodError, ActiveRecord::RecordNotFound
      #was never created (is nil) or was cleared from db
      saved_single_instances[factory_key] = Factory.create(factory_key)  #recreate
    end

    return saved_single_instances[factory_key]
  end

  def create_as_matrix(base_factory_name)
    items = yield
    column_names = items.shift
    factory_name = nil
    items.each do |column_values|
      factory_entries_hash = {}
      column_names.each_with_index do |column_name, index|
        factory_name = column_values[index] and next if column_name == :name
        factory_entries_hash[column_name] = column_values[index]
      end
      factory = FactoryGirl::Factory.new(factory_name, :class => base_factory_name)
      factory_entries_hash.each do |key,value|
        factory.definition.declare_attribute(FactoryGirl::Declaration::Static.new(key, value))
      end
      FactoryGirl.register_factory(factory)
    end
  end


  factory :processing_rule do
    type 'process'

    factory :processing_rule_payee_1 do
      item_type 'payee'
      expression 'Safe*'
      replacement 'mb'
    end
    factory :processing_rule_category_1 do
      item_type 'category'
      expression 'Safeway'
      replacement 'Dining'
    end
  end

  factory :line_item do
    factory :line_item_simple do
      payee_name 'Moshe Bergman'
      type 0
      amount 100
    end
  end

  factory :user do
    email 'test@test.com'
    password 'mypassword'
    password_confirmation 'mypassword'
  end

  #noinspection RubyArgCount
  create_as_matrix(:line_item) do [
    [:name, :type, :amount, :event_date, :category_name, :payee_name],
    [:line_item_1, LineItem::INCOME, 100, Date.new(2012, 1, 1), 'Shopping', 'Safeway'],
    [:line_item_2, LineItem::EXPENSE, 100, Date.new(2012, 1, 2), 'Shopping', 'Safeway'],
    [:line_item_3, LineItem::INCOME, 100, Date.new(2012, 2, 1), 'Shopping', 'Safeway'],
    [:line_item_4, LineItem::INCOME, 100, Date.new(2012, 1, 1), 'Shopping', 'Safeway'],
    [:line_item_5, LineItem::INCOME, 100, Date.new(2012, 1, 1), 'Shopping', 'Safeway']
  ] end
end