require 'ostruct'

class PayeeController < ApplicationController
  before_filter :assign_section

  def index
    @processing_rules = ProcessingRule.get_payee_rules.to_a
    @payees = LineItem.payees.collect do |payee_name|
      OpenStruct.new(
        payee_name: payee_name,
        processing_rules: @processing_rules.select {|processing_rule| processing_rule.matches? (payee_name) or processing_rule.results_in? (payee_name) }
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

  def delete_processing_rule
    ProcessingRule.find(params[:id]).destroy()
    render :json => {:remove_id => params[:id]}
  end

  def rename_payee
    LineItem.rename_payee(params[:payee][:name], params[:payee][:replacement])
    render :nothing => true
  end

  private

  def assign_section
    @override_section = 'line_items'
  end
end
