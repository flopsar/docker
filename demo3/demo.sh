#!/bin/bash


# Copyright (C) Flopsar Technology Sp. z o.o.

#Change version before run
VERSION=3.0.0

CONTAINER_ECOMM="flopsar-ecommerce"
CONTAINER_FLOPSAR="flopsar-server"
CONTAINER_LOAD="flopsar-loader"

IMAGE_ECOMM="flopsar/demo-ecommerce:"$VERSION
IMAGE_FLOPSAR="flopsar/demo-server:"$VERSION
IMAGE_LOAD="flopsar/ecommerce-load:latest"


BRIDGE=flopsar_bridge

scriptname=`basename ${0}`



function docker_stop {
        echo "== Stopping Flopsar containers..."
        docker stop $CONTAINER_LOAD
        docker stop $CONTAINER_FLOPSAR
}

function docker_rm {
        echo "== Removing Flopsar containers..."
        docker rm $CONTAINER_LOAD
        docker rm $CONTAINER_FLOPSAR
}

function docker_rm_ecomm {
        echo "== Removing ecommerce containers..."
        containers=$(docker ps -a -q -f 'name=flopsar-ecommerce')
        for i in $containers
        do
        docker stop $i        
        docker rm $i
        done
}


function docker_pull {
        echo "== Pulling Flopsar images..."
        docker pull $IMAGE_ECOMM
        docker pull $IMAGE_FLOPSAR
        docker pull $IMAGE_LOAD
}

function dock_start_ecomm {
        echo "== Starting "$1
        docker run -d --net $BRIDGE -p $3:8780 --name $1 -e FLOPSAR_MANAGER=$CONTAINER_FLOPSAR -e FLOPSAR_ID=$2 -d $IMAGE_ECOMM
}

function dock_start_load {
        echo "== Starting Flopsar Load Generator..."
        ECOMM_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ECOMM`
        docker run -t --net $BRIDGE --name $CONTAINER_LOAD --add-host="konakart:$ECOMM_IP" -d $IMAGE_LOAD /start-load.sh
}

function dock_start_core {
        echo "== Starting Flopsar Server..."
        docker run -td --net $BRIDGE -p 9000:9000 --name $CONTAINER_FLOPSAR $IMAGE_FLOPSAR        
}

function networking {
        docker network rm $BRIDGE
        docker network create -d bridge $BRIDGE
}




#main
main() {
        echo "Starting up Flopsar Demo Environment..."
        docker_pull
        docker_stop
        docker_rm
        docker_rm_ecomm
        networking
        dock_start_core
        dock_start_ecomm $CONTAINER_ECOMM Konakart 8780
        dock_start_load
}


main "$@"

