require 'ostruct'

class PayeeController < ApplicationController
  def index
    @processing_rules = ProcessingRule.get_payee_rules.to_a
    @payees = LineItem.payee_names.collect do |payee_name|
      OpenStruct.new(
        payee_name: payee_name,
        processing_rules: @processing_rules.select {|processing_rule| processing_rule.matches? (payee_name) }
      )
    end
  end

  def add_processing_rule
    @processing_rule = ProcessingRule.create(params[:processing_rule].merge(:type => 'process', :item_type => 'payee'))

    LineItem.all.each do |line_item|
      if !line_item.has_processing_rule_of_type(@processing_rule.type) and @processing_rule.matches?(line_item)
        @processing_rule.perform(@line_item)
      end
    end

    render :nothing => true
  end
end
