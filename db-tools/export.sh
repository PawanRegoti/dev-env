#!/bin/bash

source ./helpers/helper.sh
source ./databases/mssql.sh
source ./databases/mongo.sh
source ./databases/postgres.sh

BACKUP_FOLDER="backups"
mkdir -p $BACKUP_FOLDER 

while :; do
  case $1 in
    -d | --database)
      DATABASE_TYPE="$2"
      shift
      ;;
    -s | --uri | --sourceConnectionString) 
      SOURCE_CONNECTION_STRING="$2"
      shift
      ;;
    -t | --target) 
      TARGET="$2"
      shift
      ;;
    --) # End of all options.
      break
      ;;
    -?*)
      echo 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *) # Default case: No more options, so break out of the loop.
      break
  esac
  # shift to next set of arguments
  shift
done

if [[ -z "$DATABASE_TYPE" ]]; then
  echo "database type not provided, give it using '-d' or '--database' argument"
  exit 1
fi

if [[ -z "$SOURCE_CONNECTION_STRING" ]]; then
  echo "source connection string not provided, give it by '-s' or '--uri' or '--sourceConnectionString' argument"
  exit 1
fi

echo "starting backup"

case $DATABASE_TYPE in
  "mssql" | "sql")
    exportMssqlDatabase $SOURCE_CONNECTION_STRING $TARGET
    ;;
  "mongo" | "mongodb")
    exportMongoDatabase $SOURCE_CONNECTION_STRING $TARGET
    ;;
  "postgres" | "postgresql")
    exportPostgresDatabase $SOURCE_CONNECTION_STRING $TARGET
    ;;
  *)
    echo "Unknown database type: $DATABASE_TYPE"
    ;;
esac

drawLine
