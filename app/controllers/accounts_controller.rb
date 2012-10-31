class AccountsController < ApplicationController
  respond_to :js, :only => :edit

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = Account.find(params[:id])
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    redirect_to url_for(:action => :new), :flash => { :error => "Your password does not match!" } and return unless current_user.valid_password?(params[:account][:user_password])
    @account = current_user.accounts.build()
    @account.name = params[:account][:name]
    @account.store_password(params[:account][:user_password], params[:account][:account_password])
    @account.import_format = params[:account][:import_format]

    if @account.save
      redirect_to @account, notice: 'Account was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      @account.name = params[:account][:name]
      @account.store_password(params[:account][:mobile_password], params[:account][:account_password])
      @account.import_format = params[:account][:import_format]
      if @account.save
        format.js { }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url }
      format.json { head :no_content }
    end
  end

  def fetch
    @account = Account.find(params[:id])
    account_password = @account.retrieve_password(params[:fetch][:mobile_password])

    downloader = Remote::Downloader.new
    line_items_jsonified = downloader.fetch(Remote::Providers.const_get(@account.import_format).new(account_password))
    @account.import_line_items(line_items_jsonified)

    flash[:success] = "#{line_items_jsonified.length} line items were imported"
    redirect_to :controller => 'line_items', :action => :index, :account_id => @account.id
  end
end
