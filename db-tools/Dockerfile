FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install -y curl wget
RUN apt-get install -y zip unzip
RUN apt-get install -y mongo-tools
RUN apt-get install -y postgresql-client-12
RUN apt-get install -y libunwind8 libicu66
RUN apt-get install -y unixodbc gnupg
RUN apt-get install -y azure-cli jq

RUN mkdir /opt/sqlpackage && \
  cd /opt/sqlpackage && \
  wget -q -O sqlpackage.zip https://download.microsoft.com/download/5/d/1/5d1fc310-e111-4856-946a-c945a6d25708/sqlpackage-linux-x64-en-US-15.0.4897.1.zip && \
  unzip -q sqlpackage.zip && \
  rm sqlpackage.zip && \
  chmod +x sqlpackage && \
  ln -s /opt/sqlpackage/sqlpackage /usr/local/bin/sqlpackage

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
RUN apt-get update
RUN ACCEPT_EULA=y apt-get install -y mssql-tools && \
  chmod +x /opt/mssql-tools/bin/sqlcmd && \
  chmod +x /opt/mssql-tools/bin/bcp && \
  ln -s /opt/mssql-tools/bin/sqlcmd /usr/local/bin/sqlcmd && \
  ln -s /opt/mssql-tools/bin/bcp /usr/local/bin/bcp

WORKDIR /usr/src/app

COPY ./ /usr/src/app/

RUN chmod -R +x *

ENTRYPOINT ["tail", "-f", "/dev/null"]
