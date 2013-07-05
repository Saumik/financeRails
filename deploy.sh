cd ~/www/financeRails/public/
git pull
bundle install --path ../shared/bundle/
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt