class UsersController < ApplicationController
  def login
    @user = User.where(:email => params[:user][:email]).first

    if(@user.present? and @user.valid_password?(params[:user][:password]))
      if sign_in(:user, @user)
        redirect_to '/'
      end
    else
      flash[:error] = 'Invalid username or password'
      redirect_to '/users/sign_in'
    end
  end

  def my_profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    @user.default_account_id = params[:user][:default_account_id]

    if params[:user][:mobile_password].present?
      @user.set_mobile_password(params[:user][:mobile_password])
    end

    @user.save!

    flash[:success] = 'Profile was updated'
    redirect_to '/users/my_profile'
  end
end
