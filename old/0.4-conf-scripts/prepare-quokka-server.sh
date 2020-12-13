#!/bin/bash -x

. /build/config-quokka-server.sh

apt-get update -y

dpkg --get-selections | awk '{print $1}' | sort > "$PACKAGES_INSTALLED_LOG"
echo "Installed packages at start"
cat $PACKAGES_INSTALLED_LOG

#apt-get install $minimal_apt_get_args $QUOKKA_SERVER_BUILD_PACKAGES
apt-get install $minimal_apt_get_args $QUOKKA_BASE_PACKAGES
apt-get install $minimal_apt_get_args $QUOKKA_RUN_PACKAGES


# Update npm
npm i npm@latest -g

# The additional NPM/etc packages
apt-get install $minimal_apt_get_args $QUOKKA_ADD_PACKAGES

# Git clone Chuck Black's quokka repo
cd /root
git clone https://github.com/chuckablack/quokka/ 

# Install the various pip packages
cd /root/quokka
# Remove the quokka-0.0.0 requirement as it doesn't exist in pip repo
cat requirements.txt | grep -v quokka > temp && mv temp requirements.txt
# Add additional packages from OVA not included in the github repo itself
echo "flask-sqlalchemy-2.4.4" >> reuqirements.txt
echo "flask-cors-3.0.9" >> reuqirements.txt
echo "net-tools-0.1.2" >> reuqirements.txt
echo "tabulate-0.8.7" >> reuqirements.txt
echo "python-arptable-0.0.2" >> reuqirements.txt
echo "psycopg2-binary-2.8.6" >> reuqirements.txt
pip3 install -r requirements.txt



# Below once I get this into GitHub
# For now, this is copied in the Dockerfile to ~/quokka from my local SRC directory
#if test -n "$QUOKKA_SERVER_VERSION"; then
  #curl -SL https://github.com/hooligan_sa/quokka/releases/download/v${QUOKKA_SERVER_VERSION}/v{$QUOKKA_SERVER_VERSION}.tar.gz | tar -x -J && mv quokka-${QUOKKA_SERVER_VERSION} quokka
#else
  #git clone https://github.com/hooligan_sa/quokka
#fi

# Install NPM packages
npm install $QUOKKA_NPM_PACKAGES


# For quokka-ui
cd /root/quokka/quokka-ui
npm install $QUOKKA_UI_NPM_PACKAGES


# Add FLASK_APP to .bashrc below a newline
echo "" >> /root/.bashrc
echo "export FLASK_APP=quokka" >> /root/.bashrc

# Add shell info to all run/stop files
echo "#!/usr/bin/bash" | cat - /root/quokka/run-all.sh > /root/temp && mv /root/temp /root/quokka/run-all.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/run-ui.sh > /root/temp && mv /root/temp /root/quokka/run-ui.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/run-quokka.sh > /root/temp && mv /root/temp /root/quokka/run-quokka.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/run-sdwansim.sh > /root/temp && mv /root/temp /root/quokka/run-sdwansim.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/run-workers.sh > /root/temp && mv /root/temp /root/quokka/run-workers.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/stop-all.sh > /root/temp && mv /root/temp /root/quokka/stop-all.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/stop-quokka.sh > /root/temp && mv /root/temp /root/quokka/stop-quokka.sh
echo "#!/usr/bin/bash" | cat - /root/quokka/stop-workers.sh > /root/temp && mv /root/temp /root/quokka/stop-workers.sh

GA
# Make the new files executable
chmod a+x /root/quokka/run-*.sh
chmod a+x /root/quokka/stop-*.sh

# Set postgres DB to postgres docker container db q_db_1
#cd /root/quokka/quokka/
#cat __init__.py | sed 's/app.config\["SQLALCHEMY_DATABASE_URI"\]\ =\ '\''postgres:\/\/\/quokka'\''/app.config\["SQLALCHEMY_DATABASE_URI"\]\ =\ '\''postgres:\/\/quokka:myquokkapw@q_db_1'\''/g' > temp && mv temp __init__.py
