#!/bin/bash

set -euxo pipefail

envsubst < /hive-site.tmpl.xml > /opt/hive/conf/hive-site.xml

exec /entrypoint.sh
