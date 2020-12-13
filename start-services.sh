#!/usr/bin/bash

# Start posgresql
./start-postgres.sh -D
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start postgres: $status"
	exit $status
fi

# Start quokka
cd quokka
./run-quokka.sh -D
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start quokka: $status"
	exit $status
fi

# Start quokka-ui
./run-quokka-ui.sh -D
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start quokka-ui: $status"
	exit $status
fi


while sleep 60; do
  ps aux |grep postgresql |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps auxw | grep -i quokka | grep -v 4000 | grep flask | grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
