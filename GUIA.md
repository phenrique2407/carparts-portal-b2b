# Guia de execução · Prática Carparts (passo a passo)

Tempo estimado: 2 a 3 horas. Faça **nesta ordem**. Tire prints no momento em que cada passo é feito.

## 0. Preparação (15 min)
1. Crie um repositório **novo** no GitHub chamado `carparts-portal-b2b` (público, ou privado com merge queue disponível; veja a observação ao final).
2. No terminal (WSL/Ubuntu): `git clone <url> && cd carparts-portal-b2b`, copie os arquivos deste kit para dentro, e rode:
   `git add -A && git commit -m "chore: estrutura inicial do monorepo" && git push -u origin main`
3. Edite `.github/CODEOWNERS` e troque `@usuario-*` pelos usuários reais do grupo (ou o seu, se estiver sozinho).
4. Instale e autentique o GitHub CLI: `gh auth login` (só para o script de tempos).

## E1 · Diagnóstico (15%)
1. Para ter "branches com idade" e conflitos reais, crie 3 ou 4 branches de teste e abra 1 ou 2 PRs.
2. `bash scripts/diagnostico.sh | tee diagnostico.txt`
3. Meça o checkout atual: rode o `ci-baseline` 3 vezes (ver E4) e anote o tempo do passo "Checkout completo".
4. Escreva 5 linhas com as causas de conflito, em ordem de impacto no lead time (baseline de 11 dias; meta de 2).
**Evidência:** `diagnostico.txt` + print do tempo de checkout.

## E2 · Estratégia (15%)
1. `CONTRIBUTING.md` já está no kit; ajuste nomes e limites se quiser.
2. Faça o commit **por PR**: `git switch -c docs/contributing`, commit `docs: adiciona guia de contribuição`, push, abra o PR.
**Evidência:** o PR aprovado e mesclado + o arquivo na `main`.

## E3 · Proteção e merge queue (20%)
1. GitHub > Settings > **Rules > Rulesets** (ou Branches > Branch protection rule) para a `main`:
   - Require a pull request before merging, com **1 aprovação**
   - Require review from Code Owners
   - Require status checks to pass: selecione `test-portal`
   - Block force pushes
   - Require merge queue
2. Confirme que o `.github/CODEOWNERS` está na `main`.
3. Faça um PR que toque `prompts/` e mostre o revisor automático pedido.
4. Teste que o push direto é recusado: `git push origin main` com um commit novo deve falhar.
**Evidência (prints):** a regra, o CODEOWNERS pedindo revisão, a fila de merge com um PR dentro e o push direto recusado.

## E4 · CI enxuto (20%)
1. **ANTES:** Actions > `ci-baseline` > *Run workflow*, 3 vezes. Rode `bash scripts/tempos.sh ci-baseline`.
2. **DEPOIS:** Actions > `ci` > *Run workflow*, 3 vezes. Rode `bash scripts/tempos.sh ci`.
3. Monte a tabela: execução, tempo total, tempo do checkout, antes e depois.
4. Abra um PR que mude só `apps/api/` e mostre que o `ci` **não roda** (filtro `paths`).
5. Abra um PR que mude `apps/portal/`: o `ci` roda e o PR entra na merge queue (o evento `merge_group` dispara outra execução).
**Evidência:** os dois YAML, os links das 6 execuções e a tabela. Num repositório pequeno o ganho pode ser de poucos segundos; **registre o valor real**. Isso é aceitável, e o parecer pode comentar que o ganho cresce com o tamanho do repositório.

## E5 · Laboratório de Git (15%)
`bash scripts/lab-git.sh | tee lab-git.log`
O script roda num repositório temporário (não afeta o seu) e cobre: conflito resolvido com rebase, `git revert` na main e `git bisect run`. Depois, **comente o log** com 1 ou 2 frases por cenário, dizendo o que o comando fez e por que é seguro (por exemplo: o revert cria um commit novo e não reescreve histórico).
**Evidência:** `lab-git.log` comentado.

## E6 · Parecer (15%)
Abra `PARECER-SCION-CARPARTS.md`, preencha os campos `______` com os números reais do E1 e do E4 e exporte para PDF de uma página.
**Evidência:** o PDF, com a fonte primária citada.

## Eliminatórios: confira antes de entregar
- [ ] Nenhum `git push --force` nem `git reset --hard` em branch compartilhada
- [ ] Nenhum `.env`, token ou senha em qualquer commit (`git log -p | grep -i "token\|password\|secret"`)
- [ ] Nenhum push direto na `main`; todo PR de agente com revisão humana registrada
- [ ] Parecer sem tratar o Scion como disponível e com os números citados
- [ ] Todas as evidências são **suas** (repositório, logs, prints)

## Observações
- **Merge queue** exige um repositório de organização ou plano que a suporte. Se a opção não aparecer no repositório pessoal, crie uma organização gratuita no GitHub e transfira o repositório, ou confirme com o professor uma alternativa. Se não conseguir ativar, documente o motivo com print.
- Os workflows usam `actions/checkout@v7`, como na aula. Se a Action falhar por versão, troque pela mais recente indicada em github.com/actions/checkout.
- Sozinho? Use seu usuário em todas as linhas do CODEOWNERS e um segundo usuário/conta, ou peça a um colega para aprovar, já que o GitHub não permite aprovar o próprio PR.
