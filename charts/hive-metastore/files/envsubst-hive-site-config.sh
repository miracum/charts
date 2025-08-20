#!/bin/bash

set -euxo pipefail

echo "Generating Hive configuration from template"

envsubst </hive-site.tmpl.xml >/opt/hive/conf/hive-site.xml

exec /entrypoint.sh
