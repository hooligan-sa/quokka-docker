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

# Install the various pip packages
cd /build
pip3 install -r requirements.txt



# Below once I get this into GitHub
# For now, this is copied in the Dockerfile to /quokka from my local SRC directory
#if test -n "$QUOKKA_SERVER_VERSION"; then
  #curl -SL https://github.com/hooligan_sa/quokka/releases/download/v${QUOKKA_SERVER_VERSION}/v{$QUOKKA_SERVER_VERSION}.tar.gz | tar -x -J && mv quokka-${QUOKKA_SERVER_VERSION} quokka
#else
  #git clone https://github.com/hooligan_sa/quokka
#fi

# Install NPM packages
npm install $QUOKKA_NPM_PACKAGES

# For quokka-ui
cd /quokka/quokka-ui
npm install $QUOKKA_UI_NPM_PACKAGES

