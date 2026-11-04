#!/usr/bin/env bash
# E5 - Laboratorio de Git: conflito+rebase, revert na main, bisect run.
# Roda num repositorio TEMPORARIO (nao toca no seu projeto real) e nao usa force push nem reset --hard.
# Uso: bash scripts/lab-git.sh | tee lab-git.log
set -e
export GIT_PAGER=cat
LAB=$(mktemp -d); cd "$LAB"
git init -q -b main . ; git config user.name "Aluno"; git config user.email "aluno@exemplo.com"
git config core.editor true
say(){ echo; echo "################ $*"; }

say "CENARIO 0: historico base (main com 6 commits de uma funcao soma)"
cat > calc.js <<'X'
exports.soma = (a,b) => a + b;
exports.dobro = (a) => a * 2;
X
cat > test.js <<'X'
const c = require('./calc'); const assert = require('assert');
assert.strictEqual(c.soma(2,3), 5);
assert.strictEqual(c.dobro(4), 8);
X
git add . && git commit -qm "feat(calc): soma e dobro"
for i in 2 3 4 5; do echo "// ajuste $i" >> calc.js; git commit -qam "chore(calc): ajuste $i"; done
git tag bom            # ultimo commit sabidamente bom
git log --oneline

say "CENARIO 1: conflito resolvido com rebase"
git switch -qc feat/dobro-triplo
sed -i 's#a \* 2#a * 3 /* feat */#' calc.js
git commit -qam "feat(calc): dobro vira triplo na branch"
git switch -q main
sed -i 's#a \* 2#a << 1 /* main */#' calc.js
git commit -qam "refactor(calc): dobro com shift na main"
git switch -q feat/dobro-triplo
echo '$ git rebase main   (conflito esperado)'
git rebase main || true
echo '--- git status ---'; git status --short
echo '--- trecho com marcadores ---'; grep -n '<<<<<<<\|=======\|>>>>>>>' calc.js || true
echo '--- resolvendo: mantemos a intencao da branch (triplo) ---'
sed -i '/<<<<<<<\|=======\|>>>>>>>/d;/a << 1/d' calc.js
cat calc.js
git add calc.js
GIT_EDITOR=true git rebase --continue
git log --oneline --graph -n 8
git switch -q main && git merge -q --ff-only feat/dobro-triplo && git branch -q -d feat/dobro-triplo
# ajusta o teste para a nova regra e fixa a linha de base
sed -i 's#c.dobro(4), 8#c.dobro(4), 12#' test.js
git commit -qam "test(calc): teste acompanha o triplo"
node test.js && echo "testes OK na main"
git tag bom2

say "CENARIO 2: git revert de um commit ja publicado na main"
echo "exports.ruim = () => { throw new Error('boom'); };" >> calc.js
git commit -qam "feat(calc): adiciona funcao ruim"
BAD=$(git rev-parse --short HEAD)
echo "commit a desfazer: $BAD"
git revert --no-edit "$BAD"
git log --oneline -n 4
echo "(historico preservado: o revert e um commit NOVO, sem reescrever nada)"

say "CENARIO 3: git bisect run achando um bug inserido de proposito"
for i in 1 2 3; do echo "// ok $i" >> calc.js; git commit -qam "chore(calc): ok $i"; done
sed -i 's#a + b#a - b#' calc.js && git commit -qam "fix(calc): 'ajuste' que na verdade quebra a soma (BUG)"
CULPADO=$(git rev-parse --short HEAD)
for i in 4 5 6; do echo "// ok $i" >> calc.js; git commit -qam "chore(calc): ok $i"; done
echo "bug inserido em: $CULPADO (o bisect nao sabe disso)"
cat > check.sh <<'X'
#!/usr/bin/env bash
# 0 = bom, 1 = ruim. Roda os testes sobre o commit atual do bisect.
cd "$(dirname "$0")" && node test.js >/dev/null 2>&1
X
chmod +x check.sh; git add check.sh; git commit -qm "test: script de bisect"
cp check.sh /tmp/check-lab.sh
sed -i 's#cd "$(dirname "$0")"#cd '"$LAB"'#' /tmp/check-lab.sh
git bisect start HEAD bom2
git bisect run /tmp/check-lab.sh
git bisect log | tail -n 8
git bisect reset
echo "Esperado: o primeiro commit ruim e $CULPADO"
echo; echo "Laboratorio em: $LAB"
