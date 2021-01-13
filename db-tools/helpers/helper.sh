#!/bin/bash

drawLine() {
  echo "================================================="
}

validateAzureCredentials() {
  if [[ -z $AZURE_CONTAINER_NAME ]] || 
  [[ -z $AZURE_STORAGE_ACCOUNT ]] ||
  [[ -z $AZURE_STORAGE_KEY ]] ||
  [[ -z $AZURE_STORAGE_CONNECTION_STRING ]]; then
    echo "azure storage credentials are not available"
    exit 1
  fi
}

spinner() {
    local pid=$!
    local delay=0.10
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}

        printf "\r👀 %c working \r" "$spinstr"

        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
}

removeTempFolder() {
  echo "removing temporary directory: $BACKUP_FOLDER"
  rm -rf "$BACKUP_FOLDER"

  drawLine
}
