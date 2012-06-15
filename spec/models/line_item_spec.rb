require 'spec_helper'

describe LineItem do
  describe '#reset_balance' do
    before do

    end
    it 'should work for regular line items' do
      line_item_1 = FactoryGirl.create :line_item_1
      line_item_2 = FactoryGirl.create :line_item_2
      LineItem.reset_balance
      line_item_2.reload
      line_item_2.balance.to_i.should == 0
    end
    it 'should work for spanned line items' do
      line_item_1 = FactoryGirl.create :line_item_1
      line_item_2 = FactoryGirl.create :line_item_2
      line_item_2.span(3)
      LineItem.reset_balance
      line_item_2.reload
      line_item_2.balance.to_i.should == 0
      line_item_2.master.should == true
      line_item_2.spanned.should_not be_nil
      puts LineItem.all.collect(&:to_json).inspect
      line_item_2.spanned.line_items.length.should == 3
    end
  end
  describe '#rename_payee' do
    it 'should rename the payee name'
    it 'should put under original_payee_name the old name'
    it 'unless it already contains a value'
  end
  describe "#expense_in_month" do
    it 'should return expenses on months' do
      line_item_1 = FactoryGirl.create :line_item_1
      line_item_2 = FactoryGirl.create :line_item_2
      line_item_3 = FactoryGirl.create :line_item_3

      LineItem.expense_in_month(line_item_1.event_date.to_date, ['Shopping']).to_i.should == 0
      LineItem.expense_in_month(line_item_3.event_date.to_date, ['Shopping']).to_i.should == 100
    end
  end
end
