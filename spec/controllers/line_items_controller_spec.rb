require 'spec_helper'

describe LineItemsController do
  login_user

  describe '#perform_split' do
    it 'should work' do
      line_item_1 = FactoryGirl.create :line_item_1, account: subject.current_user.accounts.first
      original_amount = line_item_1.amount

      post :perform_split, {:line_item =>{
          :splitted=>{
              "0"=>{"amount"=>"10", "category_name"=>"Food:Groceries"},
              "1"=>{"amount"=>"", "category_name"=>""},
              "2"=>{"amount"=>"", "category_name"=>""},
              "3"=>{"amount"=>"", "category_name"=>""},
              "4"=>{"amount"=>"", "category_name"=>""}}},
          "amount_of_items"=>"1", :id => line_item_1.id
        }

      LineItem.count.should == 2
      line_item_1.reload
      line_item_1.amount.should == original_amount - 10
    end
  end
end