class BrowserSession
  include Mongoid::Document
  field :session_start, type: DateTime
  field :session_end, type: DateTime

  embeds_many :browser_page_views

  def self.open_session
    BrowserSession.create(session_start: Time.now)
  end

  def create_page_view()
    browser_page_views.create
  end
end
