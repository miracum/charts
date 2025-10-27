#!/bin/bash

# via https://github.com/argoproj/argo-helm/blob/main/scripts/renovate-bump-version.sh

depName="${1}"
if [ -z "${depName}" ]; then
  echo "Missing argument 'depName'" >&2
  exit 1
fi

newVersion="${2}"
if [ -z "${newVersion}" ]; then
  echo "Missing argument 'newVersion'" >&2
  exit 1
fi

# if a PR updates the same dependency across multiple charts,
# then for each updated chart the name of the dependency is
# repeated in $depName. the code below removes duplicates.
# It might be needlessly over-engineered as this also handles
# cases such as "common common common postgre postgres" which
# really shouldn't happen.
# We might want to check out <https://docs.renovatebot.com/configuration-options/#datafiletemplate>
# eventually to clean this up.
depName=$(echo "$depName" | tr ' ' '\n' | sort -u | xargs)

echo "Changed dep name is: $depName to $newVersion"

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.4.18@sha256:329353558cdc6af6c0b93172b36498cfea07a07b37af90df6eaf8457ca1eec31 /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
