#!/bin/zsh
# Script to copy the quokka github run-* and stop-* scripts to the container if not including during "docker-compose build" process

docker cp ./run-scripts/run-all.sh q_quokka-server_1:/quokka/
docker cp ./run-scripts/run-quokka.sh q_quokka-server_1:/quokka/
docker cp ./run-scripts/run-ui.sh q_quokka-server_1:/quokka/
docker cp ./run-scripts/run-sdwansim.sh q_quokka-server_1:/quokka/
docker cp ./run-scripts/run-workers.sh q_quokka-server_1:/quokka/
docker cp ./run-scripts/stop-all.sh q_quokka-server_1:/quokka/
docker cp ./run-scripts/stop-workers.sh q_quokka-server_1:/quokka/
