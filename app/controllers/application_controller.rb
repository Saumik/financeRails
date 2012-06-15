class ApplicationController < ActionController::Base
  include DateTimeHelpers
  protect_from_forgery

  before_filter :authenticate_user!
end
