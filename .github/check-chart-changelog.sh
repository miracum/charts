#!/usr/bin/env bash
set -euo pipefail

echo "Detecting changed Helm charts..."

CHANGED_CHARTS=$(ct list-changed --config .github/ct/install.yaml)

if [[ -z "${CHANGED_CHARTS}" ]]; then
  echo "No changed charts detected. Skipping changelog check."
  exit 0
fi

echo "Changed charts:"
echo "${CHANGED_CHARTS}"
echo

FAIL=0

# Ensure base branch is available for diff
git fetch origin "${GITHUB_BASE_REF}"

for CHART in ${CHANGED_CHARTS}; do
  CHART_FILE="${CHART}/Chart.yaml"

  echo "🔍 Checking changelog for ${CHART_FILE}..."

  if [[ ! -f "${CHART_FILE}" ]]; then
    echo "❌ ${CHART_FILE} does not exist."
    FAIL=1
    continue
  fi

  DIFF=$(git diff "origin/${GITHUB_BASE_REF}...HEAD" -- "${CHART_FILE}")

  if [[ -z "${DIFF}" ]]; then
    echo "❌ ${CHART_FILE} was not modified."
    FAIL=1
    continue
  fi

  if echo "${DIFF}" | grep -q "artifacthub.io/changes"; then
    echo "✅ Changelog annotation updated."
  else
    echo "❌ Missing changelog update (artifacthub.io/changes)."
    FAIL=1
  fi

  echo
done

if [[ "${FAIL}" -ne 0 ]]; then
  echo "❌ One or more charts are missing changelog updates."
  exit 1
fi

echo "✅ All changed charts contain changelog updates."
