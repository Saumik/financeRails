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

  def run_processing_rule
    @processing_rule = ProcessingRule.find(params[:processing_rule_id])
    @processing_rule.perform_all

    render :nothing => true
  end

  def add_processing_rule
    @processing_rule = ProcessingRule.create(params[:processing_rule].merge(:type => 'process', :item_type => params[:item_type]))
    @processing_rule.perform_all

    render :nothing => true
  end

  def rename_payee
    LineItem.rename_payee(params[:payee][:name], params[:payee][:replacement])
    render :nothing => true
  end
end
