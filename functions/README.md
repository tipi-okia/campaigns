# Funções SQL — batches remarketing

Funções para aplicar tag remarketing em contatos elegíveis e para aplicar/limpar tags de batch (Chatwoot).

## Aplicar tag remarketing em contatos elegíveis

**Arquivo:** `apply_remarketing_tag_to_eligible_contacts.sql`

- Aplica a tag **remarketing** em todos os contatos que atendem a:
  - Número de telefone preenchido (válido para WhatsApp; não exige vínculo prévio com inbox WhatsApp)
  - `custom_attributes.cancelar_cadastro` distinto de `'true'` (ou chave ausente)
- Não duplica: só insere tagging para quem ainda não tem a tag.
- Parâmetro opcional `p_account_id`: se informado, restringe à conta; se NULL, processa todas as contas.

**Como rodar no banco:**

```bash
psql -h HOST -U USER -d chatwoot -f functions/apply_remarketing_tag_to_eligible_contacts.sql
```

**Exemplo de uso:**

```sql
-- Todas as contas
SELECT apply_remarketing_tag_to_eligible_contacts(NULL);

-- Apenas conta 3
SELECT apply_remarketing_tag_to_eligible_contacts(3);
```

---

## Aplicar tags batch

**Arquivo:** `apply_remarketing_batch_tags.sql`

- Filtra contatos com tag `remarketing` e `phone_number` preenchido na conta (não exige vínculo com inbox WhatsApp).
- Ordena por nome (e `id`).
- Remove tags batch antigas desses contatos e aplica `batch_01`, `batch_02`, … em blocos de tamanho configurável (default 75).

**Como rodar no banco:**

```bash
psql -h HOST -U USER -d chatwoot -f functions/apply_remarketing_batch_tags.sql
```

**Exemplo de uso (após criar a função):**

```sql
-- Conta 3, blocos de 75
SELECT * FROM apply_remarketing_batch_tags(3, 75);

-- Conta 3, blocos de 50
SELECT * FROM apply_remarketing_batch_tags(3, 50);
```

---

## Limpar tags batch

**Arquivo:** `clear_remarketing_batch_tags.sql`

- Remove todas as taggings cuja tag tem nome no padrão `batch_01`, `batch_02`, … (`batch_N`).
- Opcionalmente restringe aos contatos de uma conta.

**Como rodar no banco:**

```bash
psql -h HOST -U USER -d chatwoot -f functions/clear_remarketing_batch_tags.sql
```

**Exemplo de uso:**

```sql
-- Limpar apenas contatos da conta 3
SELECT clear_remarketing_batch_tags(3);

-- Limpar em todos os contatos
SELECT clear_remarketing_batch_tags(NULL);
```

---

## Eliminar contatos com cancelar_cadastro = true

**Arquivo:** `delete_contacts_cancelar_cadastro.sql`

- Remove **definitivamente** todos os contatos da conta cujo `custom_attributes.cancelar_cadastro` é `true` (boolean ou string).
- Antes, exclui dependências: group_members, taggings, contact_inboxes, messages, conversations, notes, csat_survey_responses.
- **Destrutivo:** não há soft delete; os registros são apagados do banco.
- Parâmetro **obrigatório** `p_account_id`: apenas contatos dessa conta são considerados.

**Como rodar no banco:**

```bash
psql -h HOST -U USER -d chatwoot -f functions/delete_contacts_cancelar_cadastro.sql
```

**Exemplo de uso:**

```sql
-- Eliminar contatos com cancelar_cadastro = true da conta 3
SELECT delete_contacts_cancelar_cadastro(3);
-- Retorna o número de contatos removidos.
```

