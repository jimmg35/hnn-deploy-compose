#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE $APP_DB_NAME;
  GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME TO $APP_DB_USER;
  \connect $APP_DB_NAME $APP_DB_USER
  BEGIN;

	\i /docker-entrypoint-initdb.d/seed/hnn-database.sql

  COMMIT;
EOSQL


# sleep 1m	

# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#   \connect $APP_DB_NAME $APP_DB_USER
#   BEGIN;
# 	\i /docker-entrypoint-initdb.d/seed/ndvi2018.sql
#   COMMIT;
# EOSQL
