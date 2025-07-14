#!/usr/bin/env bash
# Exit on error
set -o errexit
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
# If you have a paid instance type, we recommend moving
# database migrations like this one from the build command
# to the pre-deploy command:
bundle exec rails db:migrate