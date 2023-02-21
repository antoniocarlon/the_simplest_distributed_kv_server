FROM ubuntu:jammy

RUN apt-get update
RUN apt-get install -y openssl xxd bc socat netcat

EXPOSE 7776

CMD mkdir -p database; socat tcp-l:7776,reuseaddr,fork system:"/bin/bash ./kvnode/server.sh"
