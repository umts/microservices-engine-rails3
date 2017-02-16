#!/bin/sh

if [ "$RAILS_VERSION" = "3" ]; then
  bundle install --without newruby --jobs=3 --retry=3
else
  bundle install --jobs=3 --retry=3
fi
