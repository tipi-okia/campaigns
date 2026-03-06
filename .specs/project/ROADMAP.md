# Roadmap — Campanhas Tipi da Serra

**Current Milestone:** M1 — Descoberta do banco  
**Status:** Planning

---

## M1 — Descoberta do banco de dados

**Goal:** Entender o schema, relacionamentos e convenções do banco usado pela Tipi da Serra.  
**Target:** Conclusão da documentação e diagrama de relacionamentos.

### Features

**Exploração do schema** — PLANNED

- Listar tabelas e colunas (catalogo).
- Identificar chaves primárias e estrangeiras.
- Documentar convenções de nomenclatura e tipos.

**Documentação de relacionamentos** — PLANNED

- Diagrama ER ou equivalente (por domínio).
- Documento de “onde vivem” entidades de interesse para campanhas.

**Domínio “campanhas”** — PLANNED

- Identificar tabelas/entidades ligadas a campanhas.
- Regras de negócio conhecidas (se houver).
- Pontos de integração com outros sistemas (se aplicável).

---

## M2 — Primeiro dashboard

**Goal:** Um dashboard funcional para exploração de dados e métricas básicas.  
**Target:** A definir após M1.

### Features

**Definição de métricas e fontes** — PLANNED

- Escolher 3–5 métricas iniciais baseadas no schema.
- Definir fontes (tabelas/views/queries).

**Implementação do dashboard** — PLANNED

- Stack de visualização a definir (Metabase/Superset/app custom).
- Conexão segura ao banco (read-only).
- Primeira versão publicável/ compartilhável.

**Validação com usuários** — PLANNED

- Feedback da equipe Tipi da Serra.
- Ajustes para próxima iteração.

---

## Future Considerations

- Mais dashboards por tipo de campanha ou canal.
- Alertas e thresholds baseados em métricas.
- Integração com ferramentas de campanhas (e-mail, ads, etc.) se houver necessidade.
