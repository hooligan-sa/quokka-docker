FROM debian:buster

MAINTAINER Patrick Holahan <tjunyat@gmail.com>

ENV QUOKKA_VERSION=0.1
ARG DEBIAN_FRONTEND=noninteractive


# Copy the quokka files to /quokka in the container 
WORKDIR /quokka
COPY ./quokka/ .

# Copy requisite scripts
WORKDIR /build
COPY config-quokka-server.sh prepare-quokka-server.sh cleanup-quokka.sh requirements.txt ./


# Install the required software
RUN /build/prepare-quokka-server.sh && \
  /build/cleanup-quokka.sh && \
  rm -rf /build

# Expose relevant ports - Doesn't appear to be working for some reason
EXPOSE 5000

# Run the flask app
#CMD ["flask", "run"]
#CMD ["export", "FLASK_APP='quokka'"]
CMD ["export", "FLASK_DEBUG='1'"]
ENTRYPOINT ["flask"]
CMD ["run", "--host", "0.0.0.0", "-p", "5000"]
