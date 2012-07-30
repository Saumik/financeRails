require 'spec_helper'

class ExternalControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  describe '#do_import' do
    user = FactoryGirl.create(:user)
    account = FactoryGirl.create(:account, :user_id => user.id)
    FactoryGirl.create :processing_rule_category_1
    FactoryGirl.create :processing_rule_payee_1
    line_item = FactoryGirl.build :line_item_2

    stub(Dalli::Client).new { mock!.get { [line_item].to_json } }

    sign_in user

    post 'external/do_import', :account_id => account.id
  end
end
