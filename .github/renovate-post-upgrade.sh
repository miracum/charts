#!/usr/bin/env bash
set -euo pipefail

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

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.5.55@sha256:ac80f43e5cc4c3ab24c9bcb20157ed13f6144fa4a708e10a9e6a4166a51b5f0a /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
