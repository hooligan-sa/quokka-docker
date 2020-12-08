#!/bin/zsh
# Script to stop and rm test docker quokka container

# rm the container ID
CONT_ID=`docker ps -a | grep qtest1 | awk '{print $1}'`
IMG_ID=`docker ps -a | grep qtest1 | awk '{print $2}'`
docker stop $CONT_ID
docker rm $CONT_ID

#echo "CONT_ID is:" $CONT_ID
#echo "IMG_ID is:" $IMG_ID

docker rmi $IMG_ID --force
