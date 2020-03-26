#!/bin/bash

####################################
##
##  Generateur de docker-compose
##
####################################


## Variables ####################################################

DIR="${HOME}/generator"
USER_SCRIPT=${USER}

## Functions ####################################################

help(){

echo "USAGE :

  ${0##*/} [-h] [--help]
  
  Options :

    -h, --help : aides

    -p, --postgres : lance une instance postgres

    -i, --ip : affichage des ip

"
}

ip() {
for i in $(docker ps -q); do docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} - {{.Name}}" $i;done
}


parser_options(){

case $@ in	
	-h|--help)
	  help
	;;

	-p|--postgres)
	  postgres
	;;

	*)
        echo "option invalide, lancez -h ou --help"
esac
}

postgres(){

echo ""
echo "Installation d'une instance postgres..."
echo ""
echo "1 - Création du répertoire de datas.."
mkdir -p $DIR/postgres
echo ""
echo "
version: '3.7'
services:
  postgres:
    image: postgres:latest
    container_name: postgres
    environment:
    - POSTGRES_USER=myuser
    - POSTGRES_PASSWORD=password
    - POSTGRES_DB=mydb
    ports:
    - 5432:5432
    volumes:
    - postgres_data:/var/lib/postgres
    networks:
    - generator
volumes:
  postgres_data:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: ${DIR}/postgres
networks:
  generator:
    driver: bridge
    ipam:
      config:
        - subnet: 192.169.0.0/24


" >$DIR/docker-compose-postgres.yml

echo "2 - Run de l'instance..."
docker-compose -f $DIR/docker-compose-postgres.yml  up -d

echo ""
echo "
Credentials :
    - PORT : 5432
    - POSTGRES_USER: myuser
    - POSTGRES_PASSWORD: password
    - POSTGRES_DATABASE: mydb

Command : psql -h <ip> -u myuser -d mydb
"
}




## Execute ######################################################

parser_options $@
ip


