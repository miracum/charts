#!/bin/bash
set -euox pipefail

mkdir -p /srv/conf
cp -r /usr/share/rock/conf/* /srv/conf

PERSISTENT_R_LIBRARY_DIR="/mnt/var/lib/rock/R/library"

# Check if the R library folder already exists
# in the persistent volume
if [ ! -d "$PERSISTENT_R_LIBRARY_DIR" ]; then
  # Create the dir containing the default datashield libraries
  mkdir -p "$PERSISTENT_R_LIBRARY_DIR"

  # copy default libs from the container's filesystem to the volume
  cp -r /var/lib/rock/R/library/* "$PERSISTENT_R_LIBRARY_DIR"

  echo "$PERSISTENT_R_LIBRARY_DIR created and libraries copied."
else
  echo "$PERSISTENT_R_LIBRARY_DIR already exists."
fi

/opt/obiba/bin/first_run.sh
