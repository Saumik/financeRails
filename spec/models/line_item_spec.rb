require 'spec_helper'

describe LineItem do
  before :each do
    @user = FactoryGirl.create :user_with_account
    @account = @user.accounts.first

  end
  describe '#rename_payee' do
    it 'should rename the payee name'
    it 'should put under original_payee_name the old name'
    it 'unless it already contains a value'
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
      @item1 = FactoryGirl.create :spanned_line_item, account: @account
      @item3 = FactoryGirl.create :line_item_6, account: @account
    end
    it 'should sum spanned line items as normal when spanned is not present' do
      LineItem.sum_with_filters(@account, in_month_of_date: @item1.span_until ).to_i.should == 0
      LineItem.sum_with_filters(@account, in_month_of_date: @item1.event_date ).to_i.should == -200
    end
    it 'should sum spanned line items for spanning period when spanned is true' do
      LineItem.sum_with_filters(@account, in_month_of_date: @item1.span_until, support_spanned: true).to_i.should == -50
      LineItem.sum_with_filters(@account, in_month_of_date: @item1.event_date, support_spanned: true).to_i.should == -150
    end
  end

  describe '#inline_sum_with_filters' do
    it 'should support spanned line items' do
      @item3 = FactoryGirl.create :line_item_6, account: @account
      @line_items = LineItem.all.to_a

      LineItem.inline_sum_with_filters(@user, @line_items, {}, nil).to_f.should == @item3.signed_amount.to_f

      @item1 = FactoryGirl.create :spanned_line_item, account: @account

      @line_items = LineItem.all.to_a
      expected_output = @item3.signed_amount - 50.0
      LineItem.inline_sum_with_filters(@user, @line_items, {support_spanned: true, in_year: 2012, in_month_of_date: Date.new(2012, 1, 1)}, nil).to_f.should == expected_output
    end
  end
  describe '#after_create' do
    it 'should save original event date' do
      event_date = Date.today + 1.day
      li = LineItem.create(event_date: event_date)
      li.original_event_date.should == event_date
    end
  end
end
