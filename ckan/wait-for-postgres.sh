#!/bin/bash
# wait-for-postgres.sh

set -e

host="$1"
shift
user="$1"
shift
cmd="$@"

until psql -h "$host" -U "$user" -c '\q'; do
  >&2 echo "Postgres is not ready - sleeping"
  sleep 1
done

>&2 echo "Postgres is ready - executing command"
exec $cmd

