# Campanhas Tipi da Serra

Projeto para **explorar o banco de dados**, **entender relacionamentos entre tabelas** e **construir dashboards** para criação e gestão de campanhas (Tipi da Serra).

## Configuração do projeto (Cursor + Linear + Skills)

Este repositório está configurado para trabalhar com o conjunto de skills do time T2E ([cursor-skills](https://github.com/t2english/cursor-skills)).

### 1. Instalar Cursor Skills (uma vez na máquina)

```bash
git clone https://github.com/t2english/cursor-skills.git /tmp/cursor-skills \
  && /tmp/cursor-skills/install.sh --all
```

Ou apenas as skills usadas neste projeto:

```bash
/tmp/cursor-skills/install.sh --skills codenavi,tlc-spec-driven,linear-project-management,coding-guidelines,docs-writer
```

### 2. Linear

- **Team:** OK IA  
- **Project:** Tipi da Serra  
- Config local: `.cursor/linear.json` (já criado).

O agente usa esse arquivo em todas as operações no Linear (criar/atualizar issues, listar sprint, etc.).  
Para recriar a config em outro clone:

```bash
/tmp/cursor-skills/install.sh --init-linear
```

(Escolher team "OK IA" e project "Tipi da Serra".)

### 3. Estrutura de planejamento (.specs)

- **Visão e escopo:** `.specs/project/PROJECT.md`
- **Roadmap e milestones:** `.specs/project/ROADMAP.md`
- **Decisões e estado:** `.specs/project/STATE.md`

Usado pela skill **tlc-spec-driven** (Specify → Design → Tasks → Implement).

### 4. Conhecimento do codebase/banco (.notebook)

- **Índice:** `.notebook/INDEX.md`
- Notas são criadas/atualizadas pela skill **codenavi** durante a exploração (flows, padrões, gotchas, domínio).

### 5. Regras Cursor

- `.cursor/rules/project-context.mdc` — contexto do projeto, Linear, .specs, .notebook e MCPs (always apply).

### 6. MCPs recomendados

| MCP            | Uso principal                          |
|----------------|----------------------------------------|
| **user-linear** | Issues, projetos, ciclos, comentários  |
| **user-context7** | Documentação atualizada de libs       |
| **tipi-serra** | **Postgres Tipi da Serra** — listar tabelas, executar SQL (read-only), plano de queries |

Garanta que o Linear MCP está habilitado no Cursor para criar/atualizar issues a partir de planos aprovados.

#### MCP Postgres Tipi da Serra

O servidor **tipi-serra** (Postgres) está configurado em `.cursor/mcp.json` para este projeto. Ele usa o script `scripts/mcp-tipi-serra-postgres.sh`, que carrega credenciais do arquivo `.env` (não commitado).

**Primeira vez:**

1. Copie o exemplo de variáveis: `cp .env.example .env`
2. Edite `.env` e defina `TIPI_SERRA_POSTGRES_PASSWORD` (e, se precisar, host/porta/database/user).
3. Reinicie o Cursor ou recarregue os MCPs (Settings > Features > MCP > Refresh).

**Ferramentas:** o MCP expõe ferramentas como listar tabelas, executar SQL e obter plano de execução — úteis para o M1 (descoberta do banco). O acesso é read-only.

---

## Roadmap resumido

1. **M1 — Descoberta do banco:** explorar schema, documentar relacionamentos, mapear domínio “campanhas”.
2. **M2 — Primeiro dashboard:** definir métricas, implementar dashboard, validar com usuários.

Detalhes em `.specs/project/ROADMAP.md`. Issues do roadmap estão no Linear (project Tipi da Serra):

- **OKIA-359** — M1 — Descoberta do banco de dados (pai)
  - OKIA-360 — Explorar schema: catálogo de tabelas e colunas
  - OKIA-361 — Documentar relacionamentos e diagrama ER
  - OKIA-362 — Mapear domínio "campanhas" no banco
- **OKIA-363** — M2 — Primeiro dashboard (métricas e exploração)

---

## Ambiente

- **MCP Postgres:** credenciais em `.env` (copiar de `.env.example`). Não commitar `.env`.
- Dependências de runtime (dashboard, etc.): a documentar após escolha da stack em M1/M2.
