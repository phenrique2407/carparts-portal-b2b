#!/usr/bin/env bash
# E1 - Diagnostico do repositorio. Rode na raiz do clone:  bash scripts/diagnostico.sh | tee diagnostico.txt
set -u
echo "=== Data: $(date -Iseconds) ==="
echo; echo "=== Tamanho do repositorio ==="
git count-objects -vH
echo; echo "=== Commits e autores ==="
echo "commits na main: $(git rev-list --count origin/main 2>/dev/null || git rev-list --count HEAD)"
git shortlog -sn --all | head
echo; echo "=== Branches remotas: idade do ultimo commit (dias) ==="
now=$(date +%s)
git for-each-ref --format='%(committerdate:unix) %(refname:short)' refs/remotes/origin |
while read -r ts name; do
  [ "$name" = "origin/HEAD" ] && continue
  printf '%5d dias  %s\n' $(( (now-ts)/86400 )) "$name"
done | sort -rn
echo "total de branches remotas: $(git for-each-ref refs/remotes/origin | grep -vc 'origin/HEAD')"
echo; echo "=== Branches ja mescladas na main (podem ser apagadas) ==="
git branch -r --merged origin/main | grep -v 'origin/main\|HEAD' || echo "(nenhuma)"
echo; echo "=== Arquivos mais alterados (proxy de conflito) ==="
git log --since="30 days ago" --name-only --pretty=format: | grep -v '^$' | sort | uniq -c | sort -rn | head -10
echo; echo "=== Commits de merge nos ultimos 30 dias ==="
git log --since="30 days ago" --merges --oneline | wc -l
