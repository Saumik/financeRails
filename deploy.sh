cd /srv/www/finance.moshebergman.com/public_html/
rvm use 1.9.3-p448@finance
git pull origin master
bundle install --path ../bundle/ --without development test
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt