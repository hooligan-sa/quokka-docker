#!/bin/zsh
# Script to build my quokka docker image - version is $1
docker build -t q:$1 -t q:latest .
