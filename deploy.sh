cd /srv/www/finance.moshebergman.com/public_html/
git pull
bundle install --path ../bundle/
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt