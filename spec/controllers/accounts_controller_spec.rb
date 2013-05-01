require 'spec_helper'

describe AccountsController do
  login_user

  def valid_attributes
    {:name => 'Account Name', :account_password => 'mypassword', :mobile_password => 'mobilepass', :import_format => 'ProvidentChecking'}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AccountsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET show" do
    it "assigns the requested account as @account" do
      account = FactoryGirl.create(:account)
      subject.current_user.accounts << account
      get :show, {:id => account.to_param}, valid_session
      assigns(:account).should eq(account)
    end
  end

  describe "GET new" do
    it "assigns a new account as @account" do
      get :new
      assigns(:account).should be_a_new(Account)
    end
  end

  describe "GET edit" do
    it "assigns the requested account as @account" do
      account = FactoryGirl.create(:account)
      subject.current_user.accounts << account
      get :edit, {:id => account.to_param, fomrat: :js}
      assigns(:account).should eq(account)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Account" do
        expect {
          post :create, {:account => valid_attributes}
          puts response.inspect
        }.to change(Account, :count).by(1)
        assigns(:account).should be_a(Account)
        assigns(:account).should be_persisted
        response.should redirect_to(Account.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved account as @account" do
        # Trigger the behavior that occurs when invalid params are submitted
        Account.any_instance.stub(:save).and_return(false)
        post :create, {:account => {}}
        assigns(:account).should be_a_new(Account)
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested account as @account" do
        account = FactoryGirl.create(:account)
        subject.current_user.accounts << account
        put :update, {:id => account.to_param, :account => valid_attributes, :format => :js}
        assigns(:account).should eq(account)
        response.should be_success
      end
    end
  end
end
