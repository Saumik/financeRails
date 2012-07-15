class UsersController < ApplicationController
  def login
    @user = User.where(:email => params[:user][:email]).first

    if(@user.valid_password?(params[:user][:password]))
      if sign_in(:user, @user)
        redirect_to '/'
      end
    else
      redirect_to :controller => :sessions, :action => :new
    end
  end
end
