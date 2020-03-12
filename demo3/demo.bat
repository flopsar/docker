:: Copyright (C) Flopsar Technology Sp. z o.o.


@ECHO OFF
SETLOCAL

:: Change version before run
SET VERSION=3.0.0

SET CONTAINER_ECOMM=flopsar-ecommerce
SET CONTAINER_FLOPSAR=flopsar-server
SET CONTAINER_LOAD=flopsar-loader
SET IMAGE_ECOMM=flopsar/demo-ecommerce:%VERSION%
SET IMAGE_FLOPSAR=flopsar/demo-server:%VERSION%
SET IMAGE_LOAD=flopsar/ecommerce-load:latest
SET BRIDGE=flopsar_bridge

ECHO Starting up Flopsar Demo Environment...

call:docker_pull
call:docker_stop
call:docker_rm
call:docker_network
call:dock_start_core
call:dock_start_ecomm
call:dock_start_load


EXIT /B 0


:: Functions
:docker_pull
ECHO == Pulling Flopsar images...
docker pull %IMAGE_ECOMM%
docker pull %IMAGE_FLOPSAR%
docker pull %IMAGE_LOAD%
EXIT /B 0

:docker_stop
ECHO == Stopping Flopsar containers...
docker stop %CONTAINER_LOAD%
docker stop %CONTAINER_FLOPSAR%	
docker stop %CONTAINER_ECOMM%	
EXIT /B 0		

:docker_rm
ECHO == Removing Flopsar containers...
docker rm %CONTAINER_LOAD%
docker rm %CONTAINER_FLOPSAR%
docker rm %CONTAINER_ECOMM%
EXIT /B 0				

:docker_network
docker network rm %BRIDGE%
docker network create -d bridge %BRIDGE%
EXIT /B 0

:dock_start_core
ECHO == Starting Flopsar Server...
docker run -td --net %BRIDGE% -p 9000:9000 --name %CONTAINER_FLOPSAR% %IMAGE_FLOPSAR%     
EXIT /B 0

:dock_start_ecomm
ECHO == Starting %CONTAINER_ECOMM%
docker run -d --net %BRIDGE% -p 8780:8780 --name %CONTAINER_ECOMM% -e FLOPSAR_MANAGER=%CONTAINER_FLOPSAR% -e FLOPSAR_ID=Konakart -d %IMAGE_ECOMM%
EXIT /B 0

:dock_start_load
ECHO == Starting Flopsar Load Generator...
FOR /F %%g IN ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" %CONTAINER_ECOMM%') DO SET ECOMM_IP=%%g
docker run -t --net %BRIDGE% --name %CONTAINER_LOAD% --add-host="konakart:%ECOMM_IP%" -d %IMAGE_LOAD% /start-load.sh
EXIT /B 0





