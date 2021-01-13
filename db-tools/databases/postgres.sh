#!/bin/bash

getPostgresDatabaseName() {
  POSTGRES_DATABASE_NAME=$(echo $1 | rev | cut -d/ -f1 | rev)
}

exportPostgresDatabase() {
  getPostgresDatabaseName $1
  local TARGET_FILE=$2

  # fast exit if database name is empty
  if [ -z $POSTGRES_DATABASE_NAME ]; then
    echo "Unable to find database for $POSTGRES_DATABASE_NAME"
    return
  fi

  if [[ -z $TARGET_FILE ]]; then
    TARGET_FILE="./$BACKUP_FOLDER/$POSTGRES_DATABASE_NAME.dump"
  fi

  echo "initializing export of $POSTGRES_DATABASE_NAME"
  (pg_dump -Fc $1 > $TARGET_FILE ) & spinner
  # alternate way of exporting
  # PGPASSWORD=password pg_dump -d postgres -U postgres -h localhost -p 5432 > './backups/postgres.txt'
  echo "backup of $POSTGRES_DATABASE_NAME completed successfully"
  echo "output file: $TARGET_FILE"
}

importPostgresDatabase() {
  getPostgresDatabaseName $1
  local SOURCE_FILE=$2

  # fast exit if database name is empty
  if [ -z $POSTGRES_DATABASE_NAME ]
    then
      echo "Unable to find database for $1"
      return
  fi

  if [[ -z $SOURCE_FILE ]]; then
    SOURCE_FILE="./$BACKUP_FOLDER/$POSTGRES_DATABASE_NAME.dump"
  fi

  echo "source file $SOURCE_FILE"
  echo "initializing import to $POSTGRES_DATABASE_NAME"
  (pg_restore --clean --if-exists -d $1 $SOURCE_FILE ) & spinner
  echo "import to $POSTGRES_DATABASE_NAME completed successfully"
}
