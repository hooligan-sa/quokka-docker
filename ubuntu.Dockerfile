FROM ubuntu:20.04

MAINTAINER Patrick Holahan <tjunyat@gmail.com>

ENV QUOKKA_VERSION=0.1
ENV TZ=Africa/Johannesburg


# Copy the quokka files to /quokka in the container 
WORKDIR /quokka
COPY ./quokka/ .

# Copy requisite scripts
WORKDIR /build
COPY conf-scripts/* ./


# Install the required software
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone &&\
  /build/prepare-quokka-server.sh 
  #/build/cleanup-quokka.sh && \
  #rm -rf /build

# Expose relevant ports - Doesn't appear to be working for some reason
EXPOSE 5000

# Run the flask app
#CMD ["flask", "run"]
#CMD ["export", "FLASK_APP='quokka'"]
#CMD ["export", "FLASK_DEBUG='1'"]
WORKDIR /quokka
ENTRYPOINT ["flask"]
CMD ["run", "--host", "0.0.0.0", "-p", "5000"]

