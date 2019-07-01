#!/bin/bash
# wait-for-postgres.sh

set -e

# get command from args
cmd="$@"

# PostgreSQL connection details
pg_host="db"
pg_port="5432"
pg_user="ckan"

# Apache Solr connection details
solr_host="solr"
solr_port="8983"

# Redis connection details
redis_host="redis"
redis_port="6379"

until psql -h "${pg_host}" -U "${pg_user}" -c '\q'; do
  >&2 echo "Postgres is NOT READY - sleeping"
  sleep 1
done

until curl -f "http://${solr_host}:${solr_port}"; do
  >&2 echo "Solr is not ready - sleeping"
  sleep 1
done

until redis-cli -h "${redis_host}" -p "${redis_port}" <<< ping | grep "PONG"; do
  >&2 echo "Redis is not ready - sleeping"
  sleep 1
done

>&2 echo "All services ready - executing command"
exec $cmd

