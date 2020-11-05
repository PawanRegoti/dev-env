FROM debian:stretch-slim AS build
WORKDIR /root

RUN apt-get update && apt-get install -y binutils gcc

ADD wrapper.c /root/
RUN gcc -shared  -ldl -fPIC -o wrapper.so wrapper.c



FROM mcr.microsoft.com/mssql/server:2019-CU2-ubuntu-16.04
COPY --from=build /root/wrapper.so /root/


CMD LD_PRELOAD=/root/wrapper.so /opt/mssql/bin/sqlservr

