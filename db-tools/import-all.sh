#!/bin/bash

source ./helpers/helper.sh
source ./databases/mssql.sh
source ./databases/mongo.sh
source ./databases/postgres.sh

IMPORT_FOLDER="imports"
BACKUP_FOLDER="backups"

mkdir -p $IMPORT_FOLDER

while :; do
  case $1 in
    -s | --source) 
      SOURCE="$2"
      shift
      ;;
    -b | --blob)
      BLOB="$2"
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

if [[ -n "$BLOB" ]] && [[ -n "$SOURCE" ]] || [[ -z "$BLOB" ]] && [[ -z "$SOURCE" ]]; then
  echo "only one of these arguments must be given '-s' or '-b'" 
  exit 1
fi

if [[ -n "$BLOB" ]]; then
  validateAzureCredentials
  BLOB_EXISTS=$( az storage blob exists -c $AZURE_CONTAINER_NAME -n $BLOB | jq -r '.exists' )
  if [[ "$BLOB_EXISTS" == "true" ]]; then
    SOURCE="./$IMPORT_FOLDER/$BLOB"
    drawLine
    echo "downloading blob $BLOB to $SOURCE"
    ( az storage blob download -c $AZURE_CONTAINER_NAME -n $BLOB -f $SOURCE > /dev/null ) & spinner
  fi
fi

if [[ -z "$SOURCE" ]]; then
  echo "file cannot be read"
  exit 1
fi

# remove existing directory
rm -rf $BACKUP_FOLDER

drawLine
echo "extracting backups..."
unzip -o $SOURCE
drawLine

echo "starting restore"

IFS=',' read -ra POSTGRES_CONNECTION_STRING_LIST <<< $(echo $POSTGRES_CONNECTION_STRINGS | sed 's/ //g')
IFS=',' read -ra MONGODB_CONNECTION_STRING_LIST <<< $(echo $MONGODB_CONNECTION_STRINGS | sed 's/ //g')
IFS=',' read -ra MSSQL_CONNECTION_STRING_LIST <<< $(echo $MSSQL_CONNECTION_STRINGS | sed 's/ //g')

for POSTGRES_CONNECTION_STRING in "${POSTGRES_CONNECTION_STRING_LIST[@]}"; do
  drawLine
  importPostgresDatabase $POSTGRES_CONNECTION_STRING
done

for MONGODB_CONNECTION_STRING in "${MONGODB_CONNECTION_STRING_LIST[@]}"; do
  drawLine
  importMongoDatabase $MONGODB_CONNECTION_STRING
done

for MSSQL_CONNECTION_STRING in "${MSSQL_CONNECTION_STRING_LIST[@]}"; do
  drawLine
  importMssqlDatabase $MSSQL_CONNECTION_STRING
done

drawLine


echo "removing temporary directory: $BACKUP_FOLDER"
rm -rf "$BACKUP_FOLDER"
drawLine
