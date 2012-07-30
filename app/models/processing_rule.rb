class ProcessingRule
  include Mongoid::Document

  field :expression
  field :replacement
  field :type
  field :item_type

  PAYEE_TYPE = "payee"
  CATEGORY_TYPE = "category"

  def wildcard_match(exp, matcher)
    !!Regexp.new('^' + exp.gsub('*', '.*') + '$').match(matcher)
  end

  def matches?(item)
    return false if type != 'process'
    if item_type == PAYEE_TYPE or item_type == CATEGORY_TYPE
      if item.instance_of?(LineItem)
        wildcard_match(expression, item.payee_name)
      else
        wildcard_match(expression, item)
      end
    else
      false
    end
  end

  def results_in?(item)
    return false if type != 'process'
    payee_name = item.instance_of?(LineItem) ? item.payee_name : item
    category_name = item.instance_of?(LineItem) ? item.category_name : item

    item_type == PAYEE_TYPE and replacement == payee_name or
        item_type == CATEGORY_TYPE and replacement == category_name
  end

  def self.get_payee_rules
    where(:type => 'process', :item_type.in => [PAYEE_TYPE ])
  end

  def self.get_category_name_rules
    where(:type => 'process', :item_type.in => [CATEGORY_TYPE ])
  end

  def perform(item)
    return if item.has_processing_rule_of_type(item_type)

    item.processing_rules << self

    if item_type == PAYEE_TYPE
      item.original_payee_name = item.payee_name
      item.payee_name = replacement
      item.save
    elsif item_type == CATEGORY_TYPE
      item.category_name = replacement
      item.save
    end
  end

  def perform_all
    LineItem.all.each do |line_item|
      if matches?(line_item)
        perform(line_item)
      end
    end
  end

  def self.all_matching(processing_rules, line_item)
    processing_rules.find_all { |rule| rule.matches?(line_item) }
  end

  def self.perform_all_matching(processing_rules, line_item)
    processing_rules.find_all { |rule| rule.matches?(line_item) }.each { |rule| rule.perform(line_item) }
  end

  def self.create_category_rename_rule(existing_rules, payee_name, category_name)
    return if existing_rules.any? { |rule| rule.matches? payee_name }
    ProcessingRule.create(:type => 'process', :item_type => ProcessingRule::CATEGORY_TYPE, :expression => payee_name, :replacement => category_name)
  end

  def self.create_rename_and_assign_rule_if_not_exists(category_processing_rules, original_payee_name, payee_name, category_name)
    ProcessingRule.create(:type => 'process', :item_type => PAYEE_TYPE, :expression => original_payee_name, :replacement => payee_name)
    unless category_processing_rules.any? { |rule| rule.matches?(payee_name) }
      category_processing_rules << ProcessingRule.create(:type => 'process', :item_type => CATEGORY_TYPE, :expression => payee_name, :replacement => category_name)
    end
  end

  def to_s
    item_type.capitalize + ' Process: ' + expression.to_s + ' > ' + replacement
  end
end
