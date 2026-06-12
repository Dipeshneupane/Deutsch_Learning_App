#!/bin/sh

set -e

if [ -n "${DATABASE_URL:-}" ] && [ -z "${DB_URL:-}" ]; then
  connection="${DATABASE_URL#postgresql://}"
  credentials="${connection%%@*}"
  host_and_db="${connection#*@}"

  db_user="${credentials%%:*}"
  db_password="${credentials#*:}"
  host_port="${host_and_db%%/*}"
  db_name="${host_and_db#*/}"
  db_host="${host_port%%:*}"
  db_port="${host_port#*:}"

  if [ "$db_port" = "$host_port" ]; then
    db_port="5432"
  fi

  export DB_URL="jdbc:postgresql://${db_host}:${db_port}/${db_name}"
  export DB_USERNAME="${db_user}"
  export DB_PASSWORD="${db_password}"
fi

exec java -jar /app/app.jar
