#!/bin/zsh
# Script to access qtest shell

docker exec -it q_db_1 psql -U quokka -d quokka -c 'SELECT * FROM device'

