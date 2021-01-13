#!/bin/bash

source ./helpers/helper.sh
source ./databases/mssql.sh
source ./databases/mongo.sh
source ./databases/postgres.sh

EXPORT_FOLDER="exports"
BACKUP_FOLDER="backups"

mkdir -p $EXPORT_FOLDER
mkdir -p $BACKUP_FOLDER

while :; do
  case $1 in
    --uploadToAzure)
      UPLOAD_TO_AZURE=true
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

echo "starting backup"

IFS='|' read -ra POSTGRES_CONNECTION_STRING_LIST <<< $(echo $POSTGRES_CONNECTION_STRINGS | sed 's/ //g')
IFS='|' read -ra MONGODB_CONNECTION_STRING_LIST <<< $(echo $MONGODB_CONNECTION_STRINGS | sed 's/ //g')
IFS='|' read -ra MSSQL_CONNECTION_STRING_LIST <<< $(echo $MSSQL_CONNECTION_STRINGS | sed 's/ //g')

for POSTGRES_CONNECTION_STRING in "${POSTGRES_CONNECTION_STRING_LIST[@]}"; do
  drawLine
  exportPostgresDatabase $POSTGRES_CONNECTION_STRING
done

for MONGODB_CONNECTION_STRING in "${MONGODB_CONNECTION_STRING_LIST[@]}"; do
  drawLine
  exportMongoDatabase $MONGODB_CONNECTION_STRING
done

for MSSQL_CONNECTION_STRING in "${MSSQL_CONNECTION_STRING_LIST[@]}"; do
  drawLine
  exportMssqlDatabase $MSSQL_CONNECTION_STRING
done

drawLine

echo "archiving backups..."
ZIP_FILE_NAME="backup_$(date +"%Y-%m-%d_%H-%M").zip"
ZIP_FILE_LOCATION="./$EXPORT_FOLDER/$ZIP_FILE_NAME"
zip -r $ZIP_FILE_LOCATION "$BACKUP_FOLDER"
if [[ -a $ZIP_FILE_LOCATION ]]; then 
  echo "archive created at $ZIP_FILE_LOCATION"
  
  if [[ -z $AZURE_CONTAINER_NAME ]] || 
  [[ -z $AZURE_STORAGE_ACCOUNT ]] ||
  [[ -z $AZURE_STORAGE_KEY ]] ||
  [[ -z $AZURE_STORAGE_CONNECTION_STRING ]]; then
    echo "skipping azure blob upload as azure storage credentials are not available"
  elif [[ $UPLOAD_TO_AZURE = true ]]; then
    echo "uploading to Azure BLOB Storage: $AZURE_CONTAINER_NAME"
    ( az storage blob upload -c $AZURE_CONTAINER_NAME -n $ZIP_FILE_NAME -f $ZIP_FILE_LOCATION > /dev/null ) & spinner
  fi
fi

drawLine

removeTempFolder
