#!/bin/sh

if [ "$RAILS_VERSION" = "5" ]; then
  bundle exec rails db:create db:migrate
elif [ "$RAILS_VERSION" = "4" ]; then
  bundle exec rake db:create
  bundle exec rake db:migrate
elif [ "$RAILS_VERSION" = "3" ]; then
  bundle exec rake db:create
  bundle exec rake db:migrate
else
  bundle exec rails db:create db:migrate
fi
