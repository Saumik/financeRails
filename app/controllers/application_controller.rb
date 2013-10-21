class ApplicationController < ActionController::Base
  include DateTimeHelpers
  protect_from_forgery

  before_filter :authenticate_user!, :except => [:login]
  before_filter :prepare_account, :except => [:login]
  before_filter :prepare_backup_list, :except => [:login]

  def prepare_account
    if params[:account_id].present? and params[:account_id] == '-1'
      session[:account_id] = nil
      return
    end

    if params[:account_id].present?
      session[:account_id] = params[:account_id]
    end

    if session[:account_id].present? and user_signed_in? and action_name != 'new'
      
      begin
        @account = current_user.accounts.find(session[:account_id])
      rescue Mongoid::Errors::DocumentNotFound
        session[:account_id] = @account = nil
      end
    end
  end

  def prepare_backup_list
    @backup_folders = Dir.glob('dumps/*').collect { |folder| folder.split('/').last }
  end

  def convert_to_date(str)
    Date.strptime(str, I18n.translate("date.formats.#{format}"))
  end
end
