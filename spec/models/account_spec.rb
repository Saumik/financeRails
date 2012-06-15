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
end
