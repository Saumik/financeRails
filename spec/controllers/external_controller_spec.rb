require 'spec_helper'

describe ExternalController do
  login_user

  describe '#do_import' do
    it 'should import successfully' do
      FactoryGirl.create :processing_rule_category_1, user: subject.current_user
      FactoryGirl.create :processing_rule_payee_1, user: subject.current_user
      line_item = FactoryGirl.build :line_item_6, account: subject.current_user.accounts.first

      $redis.set "import-data:#{subject.current_user.id}", [line_item.to_json_as_imported].to_json

      post :do_import, :account_id => subject.current_user.accounts.first.id, :commit => 'Perform Import'

      line_item = LineItem.last
      line_item.should be_present
      line_item.payee_name.should == 'Safeway'
    end
  end
end
