#!/bin/bash

getMssqlDatabaseName() {
  IFS=';' read -ra MSSQL_CONNECTION_STRING_PARTS <<< $1
  for MSSQL_CONNECTION_STRING_PART in "${MSSQL_CONNECTION_STRING_PARTS[@]}"; do
    MSSQL_KEY=$(echo $MSSQL_CONNECTION_STRING_PART | cut -d = -f1 | sed -e 's/\(.*\)/\L\1/')
    MSSQL_VALUE=$(echo $MSSQL_CONNECTION_STRING_PART | cut -d = -f2)

    case $MSSQL_KEY in
      "server")
        MSSQL_SERVER=$MSSQL_VALUE
        ;;
      "database")
        MSSQL_DATABASE_NAME=$MSSQL_VALUE
        ;;
      "uid" | "userid")
        MSSQL_USERID=$MSSQL_VALUE
        ;;
      "pwd" | "password")
        MSSQL_PASSWORD=$MSSQL_VALUE
        ;;
      *)
        echo "Unknown mssql key: $MSSQL_CONNECTION_STRING_PART"
        ;;
    esac
  done
}

exportMssqlDatabase() {
  getMssqlDatabaseName $1
  local TARGET_FILE=$2

  # fast exit if database name is empty
  if [ -z $MSSQL_DATABASE_NAME ]; then
    echo "Unable to find database for $MSSQL_DATABASE_NAME"
    return
  fi

  echo "initializing export of $MSSQL_DATABASE_NAME"

  if [[ -z $TARGET_FILE ]]; then
    TARGET_FILE="./$BACKUP_FOLDER/$MSSQL_DATABASE_NAME.bacpac"
  fi

  echo "starting export to $TARGET_FILE"

  (sqlpackage /a:Export /scs:$1 /tf:$TARGET_FILE ) & spinner
}

importMssqlDatabase() {
  getMssqlDatabaseName $1
  local SOURCE_FILE=$2

  # fast exit if database name is empty
  if [ -z $MSSQL_DATABASE_NAME ]
    then
      echo "Unable to find database for $MSSQL_DATABASE_NAME"
      return
  fi

  echo "dropping database $MSSQL_DATABASE_NAME"
  MSSQL_DROP_QUERY="USE master; IF EXISTS (SELECT 1 FROM sys.databases WHERE name='"$MSSQL_DATABASE_NAME"') BEGIN ALTER DATABASE [${MSSQL_DATABASE_NAME}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [${MSSQL_DATABASE_NAME}]; END"

  if [[ -z $MSSQL_USERID ]]; then
    echo "trying to connect using integrated security"
    sqlcmd -S $MSSQL_SERVER -Q "$MSSQL_DROP_QUERY"
  else
    sqlcmd -S $MSSQL_SERVER -U $MSSQL_USERID -P $MSSQL_PASSWORD -Q "$MSSQL_DROP_QUERY"
  fi

  echo "initializing import to $MSSQL_DATABASE_NAME"

  if [[ -z $SOURCE_FILE ]]; then
    SOURCE_FILE="./$BACKUP_FOLDER/$MSSQL_DATABASE_NAME.bacpac"
  fi

  echo "starting import from $SOURCE_FILE"
  (sqlpackage /a:Import /tcs:$1 /sf:$SOURCE_FILE ) & spinner
}
