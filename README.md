# quokka
Quokka config/deploy files repo

This repo contains my various attempts to configure and deploy a quokka docker container based on Chuck Black's https://github.com/chuckablack/quokka/wiki/Quokka-VM-Installed-Software

# Docker Compose build/install instructions:

# Pre-requisites:
docker and docker-compose need to be installed on your system

# Current version is 0.7
# Build
1. Change directories to where you cloned the repo
  cd ./q0.7
2. Use docker-compose to build the image from the docker-compose.yml and ubuntu.Dockerfile.0.7 files (they also use other scripts/files within the other directories)
  docker-compose build

# Run
When the build process completes (assuming no errors) you can run the container using either:
1. Actively monitor the console log while running
  docker-compose up
2. Have it run as a daemon, in order to see logs, you need to use "docker logs <container name>"
  docker logs q07_quokka-server_1

# Connect to the container - Shell
In order to access the container, there is a script "qsh.sh" that just issues the docker command below
  docker exec -it q07_quokka-server_1 bash


# Access quokka
You can use the browser on your local system to access the UI on http://localhost:3000
If there are errors in the quokka flask app, you can see them by browsing to http://localhost:5000


