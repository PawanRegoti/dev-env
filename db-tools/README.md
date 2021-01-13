# db-tools 🛠

docker-compose location: `../dc.db-tools.yml`

have a look at `../makefile` for some predefined functionalities (you can also type `make` in command-line to get help)

## export/import all databases defined in following environment variables

```
# .env or dc.db-tools.yml

# all connection strings are '|' separated (as ',' is being used in mssql connection string for port)

# postgres://<user>:<password>@<host>:<port>/<database_name>
POSTGRES_CONNECTION_STRINGS=connection-string-1,connection-string-2,connection-string-3

# mongodb://<user>:<password>@<host>:<port>/<database_name>
# mongodb+srv://<user>:<password>@<host>:<port>/<database_name>
MONGODB_CONNECTION_STRINGS=connection-string-1,connection-string-2

# server=<host>:<port>;database=<database_name>;uid=<user>;pwd=<password>
# or
# server=<host>:<port>;database=<database_name>;uid=<user>;password=<password>
MSSQL_CONNECTION_STRINGS=connection-string-1,connection-string-2,connection-string-3
```

Export and Import to BLOB storage can be done by setting following environment variables:

```
AZURE_CONTAINER_NAME=dev-databases
AZURE_STORAGE_KEY=<key>
AZURE_STORAGE_ACCOUNT=<name>
AZURE_STORAGE_CONNECTION_STRING=<connection string>
```


### commands:

`docker exec -it db-tools ./export-all.sh` (output file: ./exports/backup_date_time.zip and Azure BLOB upload)

`docker exec -it db-tools ./import-all.sh`

```
arguments for import-all (must give one of the following):

-s | --source (source file in zip format, for eg: ./imports/backup_date_time.zip) 

-b | --blob (blob file name to be downloaded from Azure)

```

---

## export/import specific database

```
backup file formats:

mssql: ./<database_name>.bacpac
mongo: ./dump/ (mongo exports and imports using dump folder)
postgres: ./<database_name>.dump (this is a file 😅)
```

### export:

`docker exec -it db-tools ./export.sh -d <mssql|mongodb|postgres> --uri '<source connection string>' -t <target>` ( -t is optional,default target location: ./backups)

```
arguments:

-d | --database (database type, one of these values [mssql|mongodb|postgres])

-s | --uri | --sourceConnectionString (source connection string)

-t | --target (optional) (target file (in case of mongodb, target folder (should end with '/dump'))) 

```

### import:

`docker exec -it db-tools ./import.sh -d <mssql|mongodb|postgres> --uri '<target connection string>' -s <source>`

```
arguments:

-d | --database (database type, one of these values [mssql|mongodb|postgres])

-t | --uri | --targetConnectionString (target connection string)

-s | --source (source file (in case of mongodb, target folder (should end with '/dump'))) 

```

---

## Things to consider:

- Azure Database for PostgreSQL has a weird connection string in which username is defined as `<user@host>` which makes postgres connection string as `postgres://<user@host>:<password>@<host>:<port>/<database_name>`. You guessed it right, it's confusing and `psql` and `pg_dump` can't resolve it. But there is a workaround for it, 

  - open shell into `db-tools` container by executing this command: 
  
  `docker exec -it db-tools bash -c "PGPASSWORD=<password> pg_dump -Fc -d <database> -U <user@host> -h <host> -p <port> > './<target_file>.txt'"`


  for eg: `docker exec -it db-tools bash -c "PGPASSWORD=password pg_dump -Fc -d postgres -U postgres@example.postgres.database.azure.com -h example.postgres.database.azure.com -p 5432 > './postgres.dump'"` 
