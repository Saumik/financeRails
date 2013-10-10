cd /srv/www/finance.moshebergman.com/public_html/
git pull origin master
bundle install --path ../bundle/ --without development test
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt