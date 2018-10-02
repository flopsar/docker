#!/bin/bash
# Copyright (C) Flopsar Technology Sp. z o.o.


#Set Flopsar version here.
#Version must be greater than 2.3.1.
VERSION="2.3.2"

CONTAINER_ECOMM="myFlopsarEcommerce"
CONTAINER_FLOPSAR="myFlopsarDB"
CONTAINER_LOAD="myFlopsarLoader"

IMAGE_ECOMM="flopsar/ecommerce:"$VERSION
IMAGE_FLOPSAR="flopsar/flopsar:"$VERSION
IMAGE_LOAD="flopsar/ecommerce-load:latest"
AGENT="flopsar-agent-"$VERSION".jar"

BRIDGE=flopsar_bridge


scriptname=`basename ${0}`

function usage {
    echo "Usage: $scriptname <license.key>"
}




function dock_stop {
        echo "Stopping Flopsar containers..."
        docker stop $CONTAINER_LOAD
        docker stop $CONTAINER_ECOMM
        docker stop $CONTAINER_FLOPSAR
}

function dock_rm {
        echo "Removing Flopsar containers..."
        docker rm $CONTAINER_LOAD
        docker rm $CONTAINER_ECOMM
        docker rm $CONTAINER_FLOPSAR
}

function dock_pull {
        echo "Pulling Flopsar images..."
        docker pull $IMAGE_ECOMM
        docker pull $IMAGE_FLOPSAR
        docker pull $IMAGE_LOAD
}

function dock_start_ecomm {
        echo "Starting Flopsar eCommerce..."
        docker run -t --net $BRIDGE -p 8780:8780 --name $CONTAINER_ECOMM -e FLOPSAR_AGENT=$AGENT -e FLOPSAR_MANAGER=$CONTAINER_FLOPSAR -e FLOPSAR_ID=konakart -d $IMAGE_ECOMM /start-flopsar.sh
}

function dock_start_load {
        echo "Starting Flopsar Load Generator..."
        ECOMM_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ECOMM`
        docker run -t --net $BRIDGE --name $CONTAINER_LOAD --add-host="konakart:$ECOMM_IP" -d $IMAGE_LOAD /start-load.sh
}

function dock_start_core {
        echo "Starting Flopsar Manager and Database..."
        docker run -it --net $BRIDGE -p 9000:9000 -p 10001:10001 --name $CONTAINER_FLOPSAR -d $IMAGE_FLOPSAR
        docker cp $1 $CONTAINER_FLOPSAR:/home/flopsar/flopsar-mgr/lic/
        docker exec -td $CONTAINER_FLOPSAR /start-flopsar.sh
}

function workstation_run {
        docker cp $CONTAINER_FLOPSAR:/home/flopsar/workstation-$VERSION.zip .
        unzip -o workstation-$VERSION.zip
        echo "You can now start workstation."
}


function networking {
        docker network rm $BRIDGE
        docker network create -d bridge $BRIDGE
}


#main
main() {
        if [ $# -ne 1 ];
        then usage; exit;
        fi

        echo "Setting up Docker Flopsar Demo..."
        dock_pull
        dock_stop
        dock_rm
        networking
        dock_start_core $1
        dock_start_ecomm
        dock_start_load
        workstation_run
}


main "$@"
