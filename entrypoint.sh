#!/bin/sh
set -e

# Чекаємо БД (якщо задано)
if [ -n "$DB_HOST" ]; then
  echo "Waiting for database at $DB_HOST:$DB_PORT..."
  until nc -z "$DB_HOST" "$DB_PORT"; do
    sleep 1
  done
fi

python manage.py migrate --noinput
echo "Starting Django development server on 0.0.0.0:8000"
python manage.py runserver 0.0.0.0:8000
