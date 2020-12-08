#!/bin/bash -x

. /build/config-quokka-server.sh

# Remove auto added packages beyond those from base install
tmp=$(mktemp)
dpkg --get-selections | awk '{print$1}' | sort > "$tmp"
echo "Installed packages at end"
cat "$tmp"
packages_to_remove=$(comm -23 "$tmp" "$PACKAGES_INSTALLED_LOG")
# | grep -vE "$PACKAGES_REMOVE_SKIP_REGEX"
rm -rf "$tmp"

apt-get remove --purge -y --allow-remove-essential $packages_to_remove

# Install the run-time dependencies - Already done in prepare-server script
#apt-get install $minimal_apt_get_args $QUOKKA_RUN_PACKAGES

# Install required PIP packages - Already done in prepare-server script
#pip3 install -r requirements.txt

# Install required NPM packages - already done in prepare-server script
#npm install npx react react-dom typography @material-ui/core @material-ui/icons


# ./build/cleanup.sh
rm -rf /tmp/* /var/tmp/*

apt-get clean
rm -rf /var/lib/apt/lists/*
