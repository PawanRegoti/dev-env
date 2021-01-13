#!/bin/bash

source ../helpers/helper.sh

validateAzureCredentials
( az storage blob list -c $AZURE_CONTAINER_NAME $@ | jq '.[]' | jq '.name' ) & spinner
