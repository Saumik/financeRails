class BrowserPageView
  include Mongoid::Document
  field :url, type: String
  field :title, type: String
  field :html, type: String
  field :success, type: Boolean
  field :error_message, type: String

  field :commands, type: Array

  embedded_in :browser_session
end
