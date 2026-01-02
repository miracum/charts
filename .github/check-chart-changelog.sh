#!/usr/bin/env bash
set -euo pipefail

CT_CONFIG=".github/ct/install.yaml"

echo "Detecting changed Helm charts..."
CHANGED_CHARTS=$(ct list-changed --config "${CT_CONFIG}")

if [[ -z "${CHANGED_CHARTS}" ]]; then
  echo "No changed charts detected. Skipping changelog check."
  exit 0
fi

# Ensure base branch is available
git fetch origin "${GITHUB_BASE_REF}"

FAIL=0

for CHART in ${CHANGED_CHARTS}; do
  CHART_FILE="${CHART}/Chart.yaml"

  echo "🔍 Checking changelog for ${CHART_FILE}..."

  if [[ ! -f "${CHART_FILE}" ]]; then
    echo "❌ ${CHART_FILE} does not exist."
    FAIL=1
    continue
  fi

  # Extract changelog from base branch
  BASE_CHANGELOG=$(git show "origin/${GITHUB_BASE_REF}:${CHART_FILE}" 2>/dev/null |
    yq '.annotations."artifacthub.io/changes" // ""')

  # Extract changelog from PR
  PR_CHANGELOG=$(yq '.annotations."artifacthub.io/changes" // ""' "${CHART_FILE}")

  if [[ "${BASE_CHANGELOG}" == "${PR_CHANGELOG}" ]]; then
    echo "❌ artifacthub.io/changes was not updated."
    FAIL=1
  else
    echo "✅ Changelog annotation updated."
  fi

  echo
done

if [[ "${FAIL}" -ne 0 ]]; then
  echo "❌ One or more charts are missing changelog updates."
  exit 1
fi

echo "✅ All changed charts contain updated changelog annotations."
