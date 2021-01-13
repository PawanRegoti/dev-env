#!/bin/bash

source ./helpers/helper.sh
source ./databases/mssql.sh
source ./databases/mongo.sh
source ./databases/postgres.sh

while :; do
  case $1 in
    -d | --database)
      DATABASE_TYPE="$2"
      shift
      ;;
    -t | --uri | --targetConnectionString) 
      TARGET_CONNECTION_STRING="$2"
      shift
      ;;
    -s | --source) 
      SOURCE="$2"
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

if [[ -z "$TARGET_CONNECTION_STRING" ]]; then
  echo "target connection string not provided, give it by '-t' or '--uri' or '--targetConnectionString' argument"
  exit 1
fi

if [[ -z "$SOURCE" ]]; then
  echo "source not provided, give it by '-s' or '--source' argument"
  exit 1
fi

if [[ ! -a "$SOURCE" ]]; then
  echo "unable to locate source, given in '-s' or '--source' argument"
  exit 1
fi

echo "starting restore"

case $DATABASE_TYPE in
  "mssql" | "sql")
    importMssqlDatabase $TARGET_CONNECTION_STRING $SOURCE
    ;;
  "mongo" | "mongodb")
    importMongoDatabase $TARGET_CONNECTION_STRING $SOURCE
    ;;
  "postgres" | "postgresql")
    importPostgresDatabase $TARGET_CONNECTION_STRING $SOURCE
    ;;
  *)
    echo "Unknown database key: $DATABASE_TYPE"
    ;;
esac

drawLine
