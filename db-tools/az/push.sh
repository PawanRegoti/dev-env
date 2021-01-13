#!/bin/bash

source ../helpers/helper.sh

validateAzureCredentials
( az storage blob upload -c $AZURE_CONTAINER_NAME $@ > /dev/null) & spinner
