#!/usr/bin/bash

# Start posgresql
sudo ./start-postgres.sh -D
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start postgres: $status"
	exit $status
fi

# Start rabbitmq-server
sudo ./start-rabbitmq.sh -D
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start rabbitmq-server: $status"
	exit $status
fi


## DISABLED ##
# If this is the first time the container is booting, don't modify __init__.py
#if [ ! -f ./first-run ]; then
	#touch ./first-run
#else
	#cp /home/quokka/quokka/quokka/del_device_table.__init__.py /home/quokka/quokka/quokka/__init__.py
#fi
	

# Start quokka
cd quokka
./run-quokka.sh &
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start quokka: $status"
	exit $status
fi

# Start quokka-ui
./run-ui.sh &
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start quokka-ui: $status"
	exit $status
fi


while sleep 60; do
  ps aux |grep postgresql |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep rabbitmq |grep -q -v grep
  PROCESS_2_STATUS=$?
  ps auxw | grep -i quokka | grep -v 3500 | grep flask | grep -q -v grep
  PROCESS_3_STATUS=$?
  ps auxw | grep -i npm | grep -q -v grep
  PROCESS_4_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 -o $PROCESS_4_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
