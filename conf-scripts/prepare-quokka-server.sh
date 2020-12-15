#!/bin/bash -x

# Load configuration variables
. /build/config-quokka-server.sh

apt-get update -y

# Log base installed packages - Will try use later to flatten the image
dpkg --get-selections | awk '{print $1}' | sort > "$PACKAGES_INSTALLED_LOG"
echo "Installed packages at start"
cat $PACKAGES_INSTALLED_LOG

# Install server and base packages
apt-get install $minimal_apt_get_args $QUOKKA_SERVER_BUILD_PACKAGES
apt-get install $minimal_apt_get_args $QUOKKA_BASE_PACKAGES

# Add quokka and postgres users to /etc/sudoers to run sudo without asking for a password
echo "quokka    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "postgres    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

## Disabled the below until I know if it's necessary
# Update npm
#npm i npm@latest -g

# Install the additional packages
apt-get install $minimal_apt_get_args $QUOKKA_ADD_PACKAGES

# Git clone Chuck Black's quokka repo - "main" is current default branch
su - quokka
cd /home/quokka/quokka
git clone https://github.com/chuckablack/quokka/ 



## PIP3 Packages ##
###################

# Remove the quokka-0.0.0 requirement as it doesn't exist in pip repo
cat requirements.txt | grep -v quokka > temp && mv temp requirements.txt

# Add additional packages from OVA not included in the github repo itself
echo "flask-sqlalchemy~=2.4.4" >> requirements.txt
echo "flask-cors~=3.0.9" >> requirements.txt
echo "net-tools~=0.1.2" >> requirements.txt
echo "tabulate~=0.8.7" >> requirements.txt
echo "python-arptable~=0.0.2" >> requirements.txt
echo "psycopg2-binary~=2.8.6" >> requirements.txt

# Install required pip packages
sudo pip3 install -r requirements.txt


## NPM Packages ##
##################

# Install NPM packages
npm install $QUOKKA_NPM_PACKAGES

# Install NPM UI packages
cd /home/quokka/quokka/quokka-ui
npm install $QUOKKA_UI_NPM_PACKAGES


## Flask ##
###########

# Add FLASK_APP to .bashrc below a newline
echo "" >> /home/quokka/.bashrc
echo "export FLASK_APP=quokka" >> /home/quokka/.bashrc


# Ubuntu / Docker container ##
##############################

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



## Start/configure Services ##
##############################

# Set postgres DB to postgres docker container db q_db_1 - When I move back to splitting services between containers
#su -
#cd /home/quokka/quokka/quokka
#cat __init__.py | sed 's/app.config\["SQLALCHEMY_DATABASE_URI"\]\ =\ '\''postgres:\/\/\/quokka'\''/app.config\["SQLALCHEMY_DATABASE_URI"\]\ =\ '\''postgres:\/\/quokka:myquokkapw@q_db_1'\''/g' > temp && mv temp __init__.py

## Local postgres config as per https://github.com/chuckablack/quokka/wiki/Quokka-VM-Installed-Software ##
##########################################################################################################
# Start the postgresql service
sudo service postgresql start

# Set it to start when system starts - Not working for some reason
sudo systemctl enable postgresql

# Create postgres user and DB
sudo -u postgres createuser -s quokka
sudo -u postgres createdb quokka

# Start the rabbitmq-server - This seems to take a while
sudo service rabbitmq-server start

# Set it to start when the system starts - Not working for some reason
sudo systemctl enable rabbitmq-server

# Create user and set permissions
sudo rabbitmqctl add_user quokkaUser quokkaPass
sudo rabbitmqctl set_permissions quokkaUser "." "." "."



## Local Ubuntu/docker requirement due to install/default "root" user ##
########################################################################

# Set user directory permissions
chown -R quokka:root /home/quokka/
