#!/bin/bash -x

. /build/config-quokka-server.sh

apt-get update -y

dpkg --get-selections | awk '{print $1}' | sort > "$PACKAGES_INSTALLED_LOG"
echo "Installed packages at start"
cat $PACKAGES_INSTALLED_LOG

#apt-get install $minimal_apt_get_args $QUOKKA_SERVER_BUILD_PACKAGES
apt-get install $minimal_apt_get_args $QUOKKA_BASE_PACKAGES
apt-get install $minimal_apt_get_args $QUOKKA_RUN_PACKAGES

echo "quokka    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# Update npm
#npm i npm@latest -g

# The additional NPM/etc packages
apt-get install $minimal_apt_get_args $QUOKKA_ADD_PACKAGES


# Below removed - copying all files from the OVA
# Git clone Chuck Black's quokka repo
su - quokka
cd /home/quokka/quokka
#git clone https://github.com/chuckablack/quokka/ 

# Install the various pip packages
#cd quokka
# Remove the quokka-0.0.0 requirement as it doesn't exist in pip repo
#cat requirements.txt | grep -v quokka > temp && mv temp requirements.txt
# Add additional packages from OVA not included in the github repo itself
echo "flask-sqlalchemy~=2.4.4" >> requirements.txt
echo "flask-cors~=3.0.9" >> requirements.txt
echo "net-tools~=0.1.2" >> requirements.txt
echo "tabulate~=0.8.7" >> requirements.txt
echo "python-arptable~=0.0.2" >> requirements.txt
echo "psycopg2-binary~=2.8.6" >> requirements.txt

# Return to root user - sudo still not working - group/permissions error?
su - 
cd /home/quokka/quokka
pip3 install -r requirements.txt
# Return to root user

# Below once I get this into GitHub
# For now, this is copied in the Dockerfile to ~/quokka from my local SRC directory
#if test -n "$QUOKKA_SERVER_VERSION"; then
  #curl -SL https://github.com/hooligan_sa/quokka/releases/download/v${QUOKKA_SERVER_VERSION}/v{$QUOKKA_SERVER_VERSION}.tar.gz | tar -x -J && mv quokka-${QUOKKA_SERVER_VERSION} quokka
#else
  #git clone https://github.com/hooligan_sa/quokka
#fi

# Install NPM packages
npm install $QUOKKA_NPM_PACKAGES

. /build/quokka-user-ui-npm-packages.sh
# For quokka-ui
su - quokka
cd /home/quokka/quokka/quokka-ui
npm install $QUOKKA_UI_NPM_PACKAGES


# Add FLASK_APP to .bashrc below a newline
echo "" >> /home/quokka/.bashrc
echo "export FLASK_APP=quokka" >> /home/quokka/.bashrc

# Add shell info to all run/stop files
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/run-all.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/run-all.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/run-ui.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/run-ui.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/run-quokka.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/run-quokka.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/run-sdwansim.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/run-sdwansim.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/run-workers.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/run-workers.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/stop-all.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/stop-all.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/stop-quokka.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/stop-quokka.sh
echo "#!/usr/bin/bash" | cat - /home/quokka/quokka/stop-workers.sh > /home/quokka/quokka/temp && mv /home/quokka/quokka/temp /home/quokka/quokka/stop-workers.sh

# Make the new files executable
chmod a+x /home/quokka/quokka/run-*.sh
chmod a+x /home/quokka/quokka/stop-*.sh

su -
# Set postgres DB to postgres docker container db q_db_1
#cd /root/quokka/quokka/
#cat __init__.py | sed 's/app.config\["SQLALCHEMY_DATABASE_URI"\]\ =\ '\''postgres:\/\/\/quokka'\''/app.config\["SQLALCHEMY_DATABASE_URI"\]\ =\ '\''postgres:\/\/quokka:myquokkapw@q_db_1'\''/g' > temp && mv temp __init__.py

# Local postgres config as per https://github.com/chuckablack/quokka/wiki/Quokka-VM-Installed-Software
# Start the postgresql service
service postgresql start
# Change accounts and create userd and DB
su - postgres
postgres createuser -s quokka
postgres createdb quokka

# Start the rabbitmq-server - This seems to take a while
service rabbitmq-server start
systemctl enable rabbitmq-server
rabbitmqctl add_user quokkaUser quokkaPass
rabbitmqctl set_permissions quokkaUser "." "." "."

# Set user permissions
chown -R quokka:root /home/quokka/
