#!/usr/bin/env bash
# E4 - Tempo das execucoes das Actions. Requer GitHub CLI autenticado (gh auth login).
# Uso: bash scripts/tempos.sh ci-baseline   |   bash scripts/tempos.sh ci
wf="${1:?informe o nome do workflow: ci-baseline ou ci}"
echo "Workflow: $wf"
gh run list --workflow "$wf" --limit 10 --json databaseId,conclusion,createdAt,updatedAt,url \
  --jq '.[] | select(.conclusion=="success") |
   "\(.databaseId)  \(((.updatedAt|fromdate)-(.createdAt|fromdate)))s  \(.url)"'
echo "--- tempo do passo de checkout (ultimo run) ---"
id=$(gh run list --workflow "$wf" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run view "$id" --json jobs --jq '.jobs[].steps[] | "\(.name)  \(((.completedAt|fromdate)-(.startedAt|fromdate)))s"'
