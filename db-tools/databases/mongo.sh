#!/bin/bash

getMongoDatabaseName() {
  MONGO_DATABASE_NAME=$(echo $1 | cut -d? -f1 | rev | cut -d/ -f1 | rev)
}

exportMongoDatabase() {
  getMongoDatabaseName $1
  local TARGET_DIR=$2

  # fast exit if database name is empty
  if [ -z $MONGO_DATABASE_NAME ]; then
    echo "Unable to find database for $MONGO_DATABASE_NAME"
    return
  fi

  if [[ -z $TARGET_DIR ]]; then
    TARGET_DIR="./$BACKUP_FOLDER/dump"
  fi

  if [[ "$TARGET_DIR" != *"/dump" ]]; then
    echo "target directory must end with '/dump', for example './backups/dump'"
  fi

  echo "output dir: $TARGET_DIR"
  echo "initializing export of $MONGO_DATABASE_NAME"
  (mongodump --forceTableScan --uri $1 -o $TARGET_DIR ) & spinner
}

importMongoDatabase() {
  getMongoDatabaseName $1
  local SOURCE_DIR=$2

  # fast exit if database name is empty
  if [ -z $MONGO_DATABASE_NAME ]
    then
      echo "Unable to find database for $1"
      return
  fi

  if [[ -z $SOURCE_DIR ]]; then
    SOURCE_DIR="./$BACKUP_FOLDER/dump"
  fi

  if [[ "$SOURCE_DIR" != *"/dump" ]]; then
    echo "source directory must end with '/dump', for example './backups/dump'"
  fi

  echo "initializing import to $MONGO_DATABASE_NAME"

  (mongorestore --drop --uri $1 $SOURCE_DIR ) & spinner
}
