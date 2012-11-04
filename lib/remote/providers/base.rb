class Remote::Providers::Base
  def open_browser
    download_directory = Rails.configuration.downloads_path

    profile = Selenium::WebDriver::Chrome::Profile.new
    profile['download.prompt_for_download'] = false
    profile['download.default_directory'] = download_directory

    agent = Watir::Browser.new :chrome, :profile => profile
    @browser_session = BrowserSession.open_session
    agent
  end

  def open_page(agent, url)
    @current_page = @browser_session.create_page_view
    agent.goto(url)
    @current_page.title = agent.title
    @current_page.html = agent.html
    @current_page.url = agent.url
    @current_page.save
  end

  def page_changed(agent)
    @current_page = @browser_session.create_page_view
    @current_page.title = agent.title
    @current_page.html = agent.html
    @current_page.url = agent.url
    @current_page.save
  end

  def report_command(str)
    @current_page.commands ||= []
    @current_page.commands << str
  end

  def report_error_message(msg)
    @current_page.error_message = msg
    @current_page.save
  end

  def close_browser(agent)
    agent.close
    File.delete("#{RAILS_ROOT}/chromedriver.log")
    @browser_session.session_end = Time.now
    @browser_session.save
    @current_page.save
  end
end