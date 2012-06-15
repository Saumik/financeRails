class UsersController < ApplicationController
  def login
    sign_in(:user, User.find(params[:id]))
  end
end
