#http://watirwebdriver.com/browser-downloads/
# chrome web driver: chromedriver_mac_23.0.1240.0.zip, in usr/local/bin
# use agent.html to get HTML

namespace :account do
  task :fetch do
    headless = nil
    if Rails.env.production?
      headless = Headless.new
      headless.start
    end

    agent = Watir::Browser.new :chrome
    puts 'opened browser, going to website'
    agent.goto("http://www.providentcu.org/index.asp?i=home")
    agent.text_field(:id => 'username').set 'mosheBergmanSF'
    agent.link(:id => 'soButton').click()
    agent.text_field(:type => 'password').when_present.set ''
    agent.button(:value => 'Sign On').click()

    #if agent.title == 'Security Challenge'
    #  agent.text_field(:type => 'password').when_present.set 'Miri'
    #  agent.button(:value => 'Continue').click()
    #end

    agent.element(:id => 'summaryofbalancesondeposit').link(:text => 'SUPER REWARD CKG').click()

    agent.radio(:value => '92').click()
    agent.link(:text => 'Spreadsheet').click()

    agent.close

    if Rails.env.production?
      headless.destroy
    end

    Dir.glob("~/Downloads/*.csv").sort_by do |f| File.new(f).ctime end.last
  end
end