source 'http://rubygems.org'

gem 'rails', '3.2.15'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'
gem "mongoid", '3.0.16'

gem "headless"
gem "watir-webdriver"
gem 'execjs'
gem 'therubyracer'
gem 'rabl'
gem 'json'
gem 'american_date'

gem 'formtastic', " ~> 2.2.1"
gem 'formtastic-bootstrap', '2.0.0'
gem 'slim'
gem 'haml-rails'
gem 'simple_form'

gem 'coffeebeans'
gem 'jquery-rails'
gem 'devise'
gem 'cache_digests'
gem 'redis-rails'
gem 'httparty'

# Use unicorn as the web server
# gem 'unicorn'

# gem 'sprockets', :git => 'https://github.com/sstephenson/sprockets.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'handlebars_assets'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'susy'
end

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem "cucumber-rails", :require => false
  gem "capybara"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem 'rr', '1.0.4'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'guard-livereload'
  gem 'ci_reporter'
end

group :test, :development do
  gem "rspec-rails", '2.12.0'
  gem 'rack-livereload'
end