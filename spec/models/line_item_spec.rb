require 'spec_helper'

describe LineItem do
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
  describe '#mass_rename_and_assign_category' do
    let!(:account) {FactoryGirl.create :account}
    it 'should assign category and rename payee' do
      line_item = FactoryGirl.create :line_item_6, :account_id => account.id
      LineItem.mass_rename_and_assign_category(account, line_item.payee_name, 'Safeway', 'Shopping')
      line_item.reload
      line_item.payee_name.should == 'Safeway'
      line_item.category_name.should == 'Shopping'
      line_item = FactoryGirl.create :line_item_6, :account_id => account.id, :payee_name => 'Safeway 2'
      LineItem.mass_rename_and_assign_category(account, line_item.payee_name, 'Safeway', 'Shopping')
      line_item.reload
      line_item.payee_name.should == 'Safeway'
      line_item.category_name.should == 'Shopping'
    end
  end
  describe '#split_from_item' do
    it 'should create another line item from existing' do
      line_item_1 = FactoryGirl.create :line_item_1
      new_item = line_item_1.split_from_item(amount: '20', category_name: 'Groceries')
      new_item.reload
      new_item.payee_name = line_item_1.payee_name
      new_item.amount.should == 20
      new_item.category_name.should == 'Groceries'
      new_item.id.should_not == line_item_1.id
      LineItem.count.should == 2
    end
  end
  describe '#clone_all' do
    it 'should not affect the original item' do
      line_item_1 = FactoryGirl.create :line_item_1
      original_id = line_item_1.id

      line_item_1.clone_all
      line_item_1.id.should == original_id
    end
  end
  describe 'spanned line item support' do
    before :each do
      @item1 = FactoryGirl.create :spanned_line_item
      @item2 = FactoryGirl.create :spanned_line_item
      @item3 = FactoryGirl.create :line_item_6
    end
    it 'should sum spanned line items as normal when spanned is not present' do
      LineItem.sum_with_filters(in_month_of_date: @item1.span_until ).to_i.should == 0
      LineItem.sum_with_filters(in_month_of_date: @item1.event_date ).to_i.should == -300
    end
    it 'should sum spanned line items for spanning period when spanned is true' do
      LineItem.sum_with_filters(in_month_of_date: @item1.span_until, support_spanned: true).to_i.should == -100
      LineItem.sum_with_filters(in_month_of_date: @item1.event_date, support_spanned: true).to_i.should == -200
    end
  end
end
