# This file is intended to be source
# . /home/quokka/build/config-quokka-server.sh

# Info gathered from Chuck Black's Quokka-VM-Installed-Software wiki page
# https://github.com/chuckablack/quokka/wiki/Quokka-VM-Installed-Software


# Prevent initramfs updates from trying to run grub and lilo.
export INITRD=no
export DEBIAN_FRONTEND=noninteractive
export FLASK_APP=quokka

#minimal_apt_get_args='-y --no-install-recommends'
minimal_apt_get_args='-y'

# File containing original installed packages
PACKAGES_INSTALLED_LOG="/tmp/packages.lst"


## Build time dependencies ##
#############################

# git and ca-certificates is needed for git clone; not building
# alternate would be to download a release tarball with curl or wget
# xz-utils is needed for tar to uncompress an .xz tarball
QUOKKA_SERVER_BUILD_PACKAGES="git curl xz-utils"

# Additional packages to build the server itself - Possibly not all required
QUOKKA_SERVER_BUILD_PACKAGES="$QUOKKA_SERVER_BUILD_PACKAGES tzdata make gcc libc-dev libffi-dev openssl sudo"



## BASE ##
##########

# Actual quokka required software list from docs 
QUOKKA_BASE_PACKAGES="postgresql postgresql-contrib postgresql-client python3-dev python3 python3-pip npm"

# Split onto another line for readability
QUOKKA_BASE_PACKAGES="$QUOKKA_BASE_PACKAGES nodejs sqlite tshark nmap graphviz"

# Not using Pycharm in this container so commented out
#QUOKKA_BASE_PACKAGES="$QUOKKA_BASE_PACKAGES snap snapd"

# Add systemd for rabbitmq-server startup (systemctl)
QUOKKA_BASE_PACKAGES="$QUOKKA_BASE_PACKAGES systemd rabbitmq-server"



## Additional packages ##
#########################

# Packages I needed to test/debug while trying to make the system work
QUOKKA_ADD_PACKAGES="$QUOKKA_ADD_PACKAGES links vim iputils-ping iproute2 lsof"



## NPM packages ##
##################

# Main NMP packages
QUOKKA_NPM_PACKAGES="npx react react-dom typography @material-ui/core @material-ui/icons"

# UI Packages - Maybe only need react-scripts installed in quokka/quokka-ui but I don't know enough yet to guarantee this
QUOKKA_UI_NPM_PACKAGES="react-scripts react-vis material-table typeface-roboto react-diff-viewer"

