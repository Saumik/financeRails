require 'spec_helper'

describe Account do
  describe '#store_password and retrieve_password' do
    let(:account) { Account.new }
    let(:user_password) {'mypassword'}
    let(:account_password) { 'accountpassword' }
    it 'should store the password and than retrieve it' do
      account.store_password(user_password, account_password)
      account.retrieve_password(user_password).should == account_password
    end
  end
  describe '#reset_balance' do
    let(:account) { FactoryGirl.create :account }
    before do

    end
    it 'should work for regular line items' do
      line_item_1 = FactoryGirl.create :line_item_1, account: account
      line_item_2 = FactoryGirl.create :line_item_2, account: account
      account.reset_balance
      line_item_2.reload
      line_item_2.balance.to_i.should == 0
    end
    #it 'should work for spanned line items' do
    #  line_item_1 = FactoryGirl.create :line_item_1
    #  line_item_2 = FactoryGirl.create :line_item_2
    #  line_item_2.span(3)
    #  LineItem.reset_balance
    #  line_item_2.reload
    #  line_item_2.balance.to_i.should == 0
    #  line_item_2.master.should == true
    #  line_item_2.spanned.should_not be_nil
    #  puts LineItem.all.collect(&:to_json).inspect
    #  line_item_2.spanned.line_items.length.should == 3
    #end
  end
end
