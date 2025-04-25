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

docker run --rm -v "${PWD}:/root/workspace" ghcr.io/chgl/kube-powertools:v2.3.53@sha256:5d1bd8a0c865c06c3af437b1d0a9117a8cbcf3f3374a1b0ce1f2963cf0e225a5 /root/workspace/.github/renovate-bump-version.sh "${depName}" "${newVersion}"
