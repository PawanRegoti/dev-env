# dev-env
A simple solution to start the various docker-based micro-services in dev environment

Copy the .env.example as .env file and update the values yourself.

You can add services to run by adding `<config-name>` (you can get this by config file names `dc.<config-name>.yml`) to `DC_BUILD` environment variable in .env file.

For eg: If you have following config files,

`dc.mssql.yml`

`dc.mongo.yml`

Then you can run both by setting following environment variable in .env file

`DC_BUILD= il-mssql, mongo`

## How to run it ?

Make sure docker desktop is running (if you are using Windows, it is preferable to have WSL2 integration to your docker)

You need something to run bash commands like `Git Bash or ComEmu or Cmder`.
Go to root of this directory in your bash terminal.

Let's start,

### Start the docker cluster using `./up` bash command.

* You can start specific services by `./up <service-name1> <service-name2>` (if you are using ComEmu or Cmder you can run it as `sh up <service-name1> <service-name2>`)

* For eg: `./up mssql mongo` runs international ledgers and inventory app

* You can see the status of your container in dashboard of docker desktop. If you are using WSL, Linux or Mac you can use `ctop` (https://ctop.sh/) to have comprehensive information of your containers.


### Stop the docker cluster using `./stop` bash command.

* You can stop specific services by `./stop <service-name1> <service-name2>`

* For eg: `./stop mssql mongo` stop international ledgers and inventory app


### Delete the docker cluster using `./down` bash command.

* ~~`./down <service-name1> <service-name2>`~~ (this doesn't work)


### See logs of the docker cluster using `./logs` bash command.

* You can see logs of specific services by `./logs <service-name1> <service-name2>`

* For eg: `./logs mssql mongo` shows logs of international ledgers and inventory app

