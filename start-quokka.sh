#!/bin/zsh
# Script to start docker quokka container with mounted local directory for code
docker run -d \
-i -p 5000:5000 \
--mount type=bind,source="/Users/patrickh/PycharmProjects/quokka/",target="/quokka" \
--name qtest1 q:latest
#--mount type=bind,source="/Users/patrickh/python/projects/q/quokka/",target="/quokka" \
#--name qtest1 q:latest sh

