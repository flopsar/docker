#!/bin/sh


# Copyright (C) Flopsar Technology Sp. z o.o.

CONTAINER_SUFFIX="_host"
CONTAINER_FLOPSAR="myFlopsarDB"

IMAGE_ECOMM="flopsar/ecommerce:2.1"
IMAGE_FLOPSAR="flopsar/demo2flopsar:2.1"
IMAGE_LOAD="flopsar/ecommerce-load:latest"

BRIDGE=flopsar_bridge


scriptname=`basename ${0}`






function dock_pull {
        echo "Pulling Flopsar images..."
        docker pull $IMAGE_ECOMM
        docker pull $IMAGE_FLOPSAR
        docker pull $IMAGE_LOAD
}

function dock_start_ecomm {
        echo "Starting Flopsar eCommerce $1..."
        NAME=$1$CONTAINER_SUFFIX
        docker run -t --net $BRIDGE -p $2:8780 --name $NAME -e FLOPSAR_MANAGER=$CONTAINER_FLOPSAR -e FLOPSAR_ID=$1 -d $IMAGE_ECOMM /start-flopsar.sh
}

function dock_start_load {
        echo "Starting Flopsar Load Generator $1..."
        ECOMM_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1`
        docker run -t --net $BRIDGE --name $2 --add-host="konakart:$ECOMM_IP" -d $IMAGE_LOAD /start-load.sh
}

function dock_start_core {
        echo "Starting Flopsar Manager and Database..."
        docker run -it --net $BRIDGE -p 9000:9000 -p 10001:10001 --name $CONTAINER_FLOPSAR -d $IMAGE_FLOPSAR
        docker cp $1 $CONTAINER_FLOPSAR:/home/flopsar/flopsar-mgr/lic/
        docker exec -td $CONTAINER_FLOPSAR /start-flopsar.sh
}

function retarget {          
        echo "Retargeting agents..."
        for (( i=0; i<$1; i++ ))
                do
                        port=$((8780+i))
                        docker exec -td -e AGENT="ecommerce_"$port $CONTAINER_FLOPSAR /retarget-flopsar.sh
                done         
}

function workstation_run {
        docker cp $CONTAINER_FLOPSAR:/home/flopsar/workstation.zip .
        unzip -o workstation.zip
        rm workstation.zip
        echo "You can now start workstation."
}


function networking {
        docker network rm $BRIDGE
        docker network create -d bridge $BRIDGE
}

function stop_rm {
        docker stop $1
        docker rm $1
}



function clear_all {
        stop_rm $CONTAINER_FLOPSAR
        for (( i=0; i<$1; i++ ))
                do
                        port=$((8780+i))
                        stop_rm "ecommerce_"$port$CONTAINER_SUFFIX
                        stop_rm "ecommerce_"$port"load"$CONTAINER_SUFFIX
                done 
}


function start_all {
        #dock_pull
        networking
        dock_start_core $2
        for (( i=0; i<$1; i++ ))
                do
                        port=$((8780+i))
                        dock_start_ecomm "ecommerce_"$port $port
                        dock_start_load "ecommerce_"$port$CONTAINER_SUFFIX "ecommerce_"$port"load"$CONTAINER_SUFFIX
                done 
        echo "Waiting for agents to connect..."
        sleep 10
        retarget $1             
        workstation_run
}




#main
main() {
        case "$1" in
                start)
                        if [ $# -ne 3 ]; then
                                echo "Usage: $scriptname start <ecommerce_num> <license.key>"; return 1;
                        fi
                        clear_all $2
                        start_all $2 $3
                ;;
                stop)
                        if [ $# -ne 2 ]; then
                                echo "Usage: $scriptname stop <ecommerce_num>"; return 1;
                        fi
                        clear_all $2
                ;;
                retarget)
                        if [ $# -ne 2 ]; then
                                echo "Usage: $scriptname retarget <ecommerce_num>"; return 1;
                        fi
                        retarget $2                        
                ;;
                *)
                        echo "Usage: $scriptname (start|stop|retarget) <ecommerce_num> <license.key>"; return 1;

                return 1
                ;;
        esac
}



main "$@"

