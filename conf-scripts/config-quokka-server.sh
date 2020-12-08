# This file is intended to be source
# . /build/config-quokka-server.sh

# THIS NEEDS TO GO SOMEWHERE??
#AUTO_ADDED_PACKAGES=`apt-mark showauto`


# Prevent initramfs updates from trying to run grub and lilo.
export INITRD=no
export DEBIAN_FRONTEND=noninteractive
export FLASK_APP=quokka

#minimal_apt_get_args='-y --no-install-recommends'
minimal_apt_get_args='-y'

# File containing original installed packages
PACKAGES_INSTALLED_LOG="/tmp/packages.lst"



## Build time dependencies ##

# git and ca-certificates is needed for git clone; not building
# alternate would be to download a release tarball with curl or wget
# xz-utils is needed for tar to uncompress an .xz tarball
QUOKKA_SERVER_BUILD_PACKAGES="git ca-certificates curl xz-utils"

# Core list from docs - postgresql-libs for pip3 and psycopg2-binary
QUOKKA_SERVER_BUILD_PACKAGES="$QUOKKA_SERVER_BUILD_PACKAGES tzdata make python3-dev libffi-dev openssl postgresql-client libxslt-dev libxml2-dev npm"
QUOKKA_BASE_PACKAGES="tzdata make postgresql-client python3-dev python3 python3-pip npm"

# Building the servers needs g++
#QUOKKA_SERVER_BUILD_PACKAGES="$QUOKKA_SERVER_BUILD_PACKAGES g++"


## Run time dependencies ##
QUOKKA_RUN_PACKAGES="python3 python3-pip"


# Headers required for psutil - May be able to move these to build packages
#QUOKKA_RUN_PACKAGES="$QUOKKA_RUN_PACKAGES gcc libc-dev fortify-headers linux-headers" 
QUOKKA_RUN_PACKAGES="$QUOKKA_RUN_PACKAGES gcc libc-dev" 


# apt-get remove --allow-remove-essential enters an infinite loop of
# pam errors with this package
#  login: because it depends on libpam*
PACKAGES_REMOVE_SKIP_REGEX='(libpam|login)'


# Additional packages required
QUOKKA_ADD_PACKAGES="nodejs git sqlite tshark nmap graphviz rabbitmq-server"

# Add links for local debugging
QUOKKA_ADD_PACKAGES="$QUOKKA_ADD_PACKAGES links vim iputils-ping"

# NPM packages
QUOKKA_NPM_PACKAGES="npx react react-dom typography @material-ui/core @material-ui/icons"

# As per https://github.com/chuckablack/quokka/wiki/Quokka-VM-Installed-Software - this needs to be run in your react UI directory, e.g. quokka/quokka-ui
mkdir -p /quokka/quokka-ui
cd /quokka/quokka-ui
QUOKKA_UI_NPM_PACKAGES="react-scripts react-vis material-table typeface-roboto react-diff-viewer"

