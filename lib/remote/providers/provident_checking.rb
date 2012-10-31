class Remote::Providers::ProvidentChecking < Remote::Providers::Base
  def initialize(account_password)
    @account_password = account_password
  end
  def fetch
    begin
      agent = open_browser

      # Step 1: Login
      open_page(agent, "http://www.providentcu.org/index.asp?i=home")

      report_command('set id:username')
      agent.text_field(:id => 'username').set 'mosheBergmanSF'

      report_command('click id:soButton')
      agent.link(:id => 'soButton').click()

      page_changed(agent)

      # Step 2: Password

      report_command('fill type:password')
      agent.text_field(:type => 'password').when_present.set @account_password

      report_command('click value:Sign On')
      agent.button(:value => 'Sign On').click()

      page_changed(agent)

      #if agent.title == 'Security Challenge'
            #  agent.text_field(:type => 'password').when_present.set 'Miri'
            #  agent.button(:value => 'Continue').click()
            #end

      # Step 3: Select Account

      report_command('click id:summaryofbalancesondeposit, text: Super Reward Ckg')
      agent.element(:id => 'summaryofbalancesondeposit').link(:text => 'SUPER REWARD CKG').click()

      page_changed(agent)

      report_command('Select 92')
      agent.radio(:value => '92').click()

      report_command('click Spreadsheet')
      agent.link(:text => 'Spreadsheet').click()

      sleep(10.seconds)

      report_command('close')

      close_browser(agent)
    rescue Watir::Exception::Error => e
      report_error_message(e.message)
      close_browser(agent)
      return
    end

    csv_file = Dir.glob(Rails.configuration.downloads_path + "/*.csv").sort_by do |f| File.new(f).ctime end.last
    file_content = File.read(csv_file)
    ::Importers::ProvidentChecking.new.import file_content
  end
end