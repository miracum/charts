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

echo "Changed dep name is: $depName to $newVersion"

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.3.36@sha256:1424a809e85eda3a6d7afb2386bdc3b9ac03b2b5244924a7be4851b15a2eca4f /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
