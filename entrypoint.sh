#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

rake assets:precompile
rake db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile).
# exec "$@"
