class ProcessingRule
  include Mongoid::Document

  field :expression
  field :replacement
  field :type
  field :item_type

  PAYEE_TYPE = "payee"

  def wildcard_match(exp, matcher)
    !!Regexp.new(exp.gsub('*', '.*')).match(matcher)
  end

  def matches?(item)
    if type == PAYEE_TYPE
      if item.instance_of?(LineItem)
        wildcard_match(expression, item.payee_name)
      else
        wildcard_match(expression, item)
      end
    else
      false
    end
  end

  def self.get_payee_rules
    where(:type => 'process', :item_type => PAYEE_TYPE)
  end

  def perform(item)
    item.processing_rules << self

    if type == PAYEE_TYPE
      item.original_payee_name = item.payee_name
      item.payee_name = replacement
    end
  end
end
