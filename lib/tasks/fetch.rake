#http://watirwebdriver.com/browser-downloads/

agent = Watir::Browser.new :chrome
agent.goto("http://www.providentcu.org/index.asp?i=home")
agent.text_field(:id => 'username').set 'mosheBergmanSF'
agent.link(:id => 'soButton').click()
agent.text_field(:type => 'password').set 'XXX'
agent.button(:value => 'Sign On').click()

agent.element(:id => 'summaryofbalancesondeposit').link(:text => 'SUPER REWARD CKG').click()

agent.radio(:value => '92').click()
agent.link(:text => 'Spreadsheet')


Dir.glob("/Users/moshebergman/Downloads/*.csv").sort_by do |f| File.new(f).ctime end.last