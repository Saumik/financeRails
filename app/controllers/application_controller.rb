class ApplicationController < ActionController::Base
  include DateTimeHelpers
  protect_from_forgery

  before_filter :authenticate_user!, :except => [:login]
  before_filter :prepare_account, :except => [:login]
  before_filter :prepare_backup_list, :except => [:login]

  def prepare_account
    if params[:account_id]
      session[:account_id] = params[:account_id]
    end

    if session[:account_id]
      @account = current_user.accounts.find(session[:account_id])
    end
  end

  def prepare_backup_list
    @backup_folders = Dir.glob('dumps/*').collect { |folder| folder.split('/').last }
  end
end
