FROM python:alpine:3.10.0a2-alpine3.12

# Hack from https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/blob/master/Dockerfile
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=quokka

# Adding postgresql libraries for pip3 psycopg2-binary
RUN apk add --no-cache postgresql-libs 

# Install other packages and build environments
RUN apk add --no-cache --virtual .build-deps make g++ python3-dev libffi-dev openssl-dev postgresql-dev libxslt-dev libxml2-dev && \
  apk add --no-cache --update python3 && \
  if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi 

# Other required files
RUN apk add --no-cache nodejs && \
  apk add --no-cache npm && \
  apk add --no-cache git && \
  apk add --no-cache sqlite3 && \
  apk add --no-cache postgresql && \
  apk add --no-cache postgresql-contrib && \
  apk add --no-cache tshark && \
  apk add --no-cache rabbitmq-server && \
  apk add --no-cache nmap && \
  apk add --no-cache graphviz && \

# Continuing the hacky install
RUN python3 -m ensurepip && \
  rm -r /usr/lib/python*/ensurepip && \
  pip3 install --no-cache --upgrade pip setuptools wheel && \
  if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

# PIP packages
#RUN pip3 install flask flask-sqlalchemy flask_cors net-tools tabulate python_arptable napalm ntplib psycopg2-binary psutil pyshark scapy pika scapy2dict python-nmap
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# NPM packages
RUN npm install npx && \
  npm install react && \
  npm install react-dom && \
  npm install typography && \
  npm install @material-ui/core && \
  npm install @material-ui/icons

# As per https://github.com/chuckablack/quokka/wiki/Quokka-VM-Installed-Software - this needs to be run in your react UI directory, e.g. quokka/quokka-ui
WORKDIR /quokka/quokka-ui
RUN npm install react-scripts && \
  npm install react-vis && \
  npm install material-table && \
  npm install typeface-roboto && \
  npm install react-diff-viewer

# Debugging - Add links browser
RUN apk add --no-cache links

# Postgres attempt from https://stackoverflow.com/questions/46981073/how-to-run-postgres-in-a-docker-alpine-linux-container
#RUN (addgroup -S postgres && adduser -S postgres -G postgres || true)
#RUN mkdir -p /var/lib/postgresql/data
#RUN mkdir -p /run/postgresql/
#RUN chown -R postgres:postgres /run/postgresql/
#RUN chmod -R 777 /var/lib/postgresql/data
#RUN chown -R postgres:postgres /var/lib/postgresql/data
#RUN su - postgres -c "initdb /var/lib/postgresql/data"
#RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf
#RUN su - postgres -c "pg_ctl start -D /var/lib/postgresql/data -l /var/lib/postgresql/log.log && psql --command \"ALTER USER postgres WITH ENCRYPTED PASSWORD 'postgres';\" && psql --command \"CREATE DATABASE builddb;\""

USER postgres

RUN chmod 0700 /var/lib/postgresql/data &&\
    initdb /var/lib/postgresql/data &&\
    echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf &&\
    echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf &&\
    pg_ctl start &&\
    psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'main'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE main" &&\
    psql -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'mysecurepassword';"

EXPOSE 5432

# Clean up the build dependencies
RUN apk --purge del .build-deps


# Copy the quokka files to /quokka in the container (specified by WORKDIR)
WORKDIR /quokka
COPY ./quokka/ .

# Expose relevant ports - Doesn't appear to be working for some reason
EXPOSE 5000

# Run the flask app
#CMD ["flask", "run"]
#CMD ["export", "FLASK_APP='quokka'"]
CMD ["export", "FLASK_DEBUG='1'"]
ENTRYPOINT ["flask"]
CMD ["run", "--host", "0.0.0.0", "-p", "5000"]
