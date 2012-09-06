class UsersController < ApplicationController
  def login
    @user = User.where(:email => params[:user][:email]).first

    if(@user.valid_password?(params[:user][:password]))
      if sign_in(:user, @user)
        redirect_to '/'
      end
    else
      flash[:error] = 'Invalid username or password'
      redirect_to '/users/sign_in'
    end
  end
end
