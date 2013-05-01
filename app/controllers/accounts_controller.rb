class AccountsController < ApplicationController
  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = current_user.accounts.find(params[:id])
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = current_user.accounts.new
  end

  # GET /accounts/1/edit
  def edit
    @account = current_user.accounts.find(params[:id])

    respond_to do |format|
      format.js {}
    end
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = current_user.accounts.build()
    @account.name = params[:account][:name]
    @account.store_password(params[:account][:mobile_password], params[:account][:account_password])
    @account.import_format = params[:account][:import_format]

    if @account.save
      redirect_to @account, notice: 'Account was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      @account.name = params[:account][:name]
      @account.store_password(params[:account][:mobile_password], params[:account][:account_password])
      @account.import_format = params[:account][:import_format]
      if @account.save
        format.js { }
      else
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def fetch
    @account = Account.find(params[:id])
    account_password = @account.retrieve_password(params[:fetch][:mobile_password])

    downloader = Remote::Downloader.new
    line_items_jsonified = downloader.fetch(Remote::Providers.const_get(@account.import_format).new(account_password))
    @account.import_line_items(line_items_jsonified)
    @account.reset_balance
    @account.touch

    flash[:success] = "#{line_items_jsonified.length} line items were imported"
    redirect_to :controller => 'line_items', :action => :index, :account_id => @account.id
  end
end
