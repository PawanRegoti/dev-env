SHELL=/bin/bash

.PHONY: start stop logs clean

help:
	@echo ""
	@echo "dev-database's makefile"
	@echo "======================="
	@echo ""
	@echo "///////////////////////////////////////////////////////"
	@echo "///~example: make start                             ///"
	@echo "///~or                                              ///"
	@echo "///~example: make start IMAGES='postgres mongodb'   ///"
	@echo "///////////////////////////////////////////////////////"
	@echo ""
	@echo "# db-management"
	@echo "---------------------------------------"
	@echo "make start IMAGES='<I1 I2 I3...>'      Spins up given databases in containers (by default: starts all)"
	@echo "make stop IMAGES='<I1 I2 I3...>'       Spins down given database containers (by default: stops all)"
	@echo "make logs IMAGES='<I1 I2 I3...>'       Attaches to given databases logs (by default: attaches to all)"
	@echo "make clean                             Removes all the database containers"
	@echo ""
	@echo "# db-tools"
	@echo "---------------------------------------"
	@echo "make list-backups                      Lists the backups from BLOB storage"
	@echo ""
	@echo "make pull                              Downloads the backup from BLOB storage to a given file location"
	@echo "     TARGET=<where to save>"
	@echo "     NAME=<name of the blob>"
	@echo ""
	@echo "make push SOURCE=<file location>       Uploads the backup to BLOB storage from a given file location"
	@echo ""
	@echo "make export-all                        Creates a cumulative backup of all databases as zip and pushes it to BLOB storage"
	@echo "     TARGET=<local folder to save>     (optional) saves it locally instead of uploading to azure"
	@echo ""
	@echo "make import-all                        Restores all databases with provided backup"
	@echo "     NAME=<blob name>                  pulls the backup from BLOB storage"
	@echo "     ~or~                              ~or~"
	@echo "     SOURCE=<local backup file path>   uses local backup file"
	@echo ""
	@echo "make export                            Creates a backup of database"
	@echo "     DATABASE_TYPE=<db name>           one of these values [mssql|mongodb|postgres]"
	@echo "     URI='<connection string>'"
	@echo "     TARGET=<target file/folder>"
	@echo ""
	@echo "make import                            Restores database using given source file/folder"
	@echo "     DATABASE_TYPE=<db name>           one of these values [mssql|mongodb|postgres]"
	@echo "     URI='<connection string>'"
	@echo "     SOURCE=<source file/folder>"
	@echo ""
	@echo "make shift-backup NAME=<backup file>   Copies the backup to from exports folder to imports folder inside docker"
	@echo ""
	@echo ""

###
### db-management
###

start:
	@./up $$IMAGES

stop:
	@./stop $$IMAGES

logs:
	@./logs $$IMAGES

clean:
	@./down

###
### db-tools Utilities
###

list-backups:
	@docker exec -it db-tools bash -c "cd az; ./list.sh"

pull:
	@$(eval IMPORT_PATH = $$(shell echo "/usr/src/app/imports/${NAME}"))
	@docker exec -it db-tools bash -c "cd az; ./pull.sh -n ${NAME} -f '${IMPORT_PATH}'"
ifdef TARGET
	@echo "copying backup file from '${IMPORT_PATH}' to '$$TARGET'"
	@docker cp db-tools:${IMPORT_PATH} $$TARGET
else
	@echo "TARGET is not provided, so backup file is at: ${IMPORT_PATH}"
endif

push:
	@$(eval SOURCE_FILENAME = $$(shell echo $(SOURCE) | rev | cut -d/ -f1 | rev))
	@$(eval SOURCE_PATH = $$(shell echo "/usr/src/app/exports/${SOURCE_FILENAME}"))
	@echo "copying backup file from '$$SOURCE' to '${SOURCE_PATH}'"
	@docker cp $$SOURCE db-tools:${SOURCE_PATH}
	@docker exec -it db-tools bash -c "cd az; ./push.sh -n ${SOURCE_FILENAME} -f '${SOURCE_PATH}'"

export-all:
ifdef TARGET
	@mkdir -p $$TARGET
	@$(eval EXPORT_PATH = $$(shell echo "/usr/src/app/exports/"))
	@docker exec -it db-tools bash -c "rm -rf ${EXPORT_PATH}*"
	@docker exec -it db-tools bash -c "./export-all.sh"
	@echo "copying backup file from '${EXPORT_PATH}' to '$$TARGET'"
	@docker cp db-tools:${EXPORT_PATH} $$TARGET
else
	@docker exec -it db-tools bash -c "./export-all.sh --uploadToAzure"
endif

shift-backup:
	@echo "copying backup file from '/usr/src/app/exports/$$NAME' to '/usr/src/app/imports/$$NAME'"
	@docker exec -it db-tools bash -c "cp '/usr/src/app/exports/$$NAME' '/usr/src/app/imports/$$NAME'"

import-all:
ifdef SOURCE
	@$(eval IMPORT_FILENAME = $$(shell echo $(SOURCE) | rev | cut -d/ -f1 | rev))
	@$(eval IMPORT_PATH = $$(shell echo "/usr/src/app/imports/${IMPORT_FILENAME}"))
	@echo "copying backup file from '$$SOURCE' to '${IMPORT_PATH}'"
	@docker cp $$SOURCE db-tools:${IMPORT_PATH}
	@docker exec -it db-tools bash -c "./import-all.sh -s '${IMPORT_PATH}'"
else
	@docker exec -it db-tools bash -c "./import-all.sh -b $$NAME"
endif


export:
	@$(eval EXPORT_FILENAME = $$(shell echo $(TARGET) | rev | cut -d/ -f1 | rev))
	@$(eval EXPORT_PATH = $$(shell echo "/usr/src/app/exports/${EXPORT_FILENAME}"))
	@docker exec -it db-tools bash -c "./export.sh -d $$DATABASE_TYPE --uri '$$URI' -t '${EXPORT_PATH}'"
	@echo "copying backup file from '${EXPORT_PATH}' to '$$TARGET'"
	@docker cp db-tools:${EXPORT_PATH} $$TARGET
	@echo "backup saved at $$TARGET"

import:
	@$(eval IMPORT_FILENAME = $$(shell echo $(SOURCE) | rev | cut -d/ -f1 | rev))
	@$(eval IMPORT_PATH = $$(shell echo "/usr/src/app/imports/${IMPORT_FILENAME}"))
	@echo "copying backup file from '$$SOURCE' to '${IMPORT_PATH}'"
	@docker cp $$SOURCE db-tools:${IMPORT_PATH}
	@docker exec -it db-tools bash -c "./import.sh -d $$DATABASE_TYPE --uri '$$URI' -s '${IMPORT_PATH}'"
