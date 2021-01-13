#!/bin/bash

source ../helpers/helper.sh

validateAzureCredentials
( az storage blob download -c $AZURE_CONTAINER_NAME $@  > /dev/null) & spinner
