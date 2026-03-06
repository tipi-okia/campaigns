#!/usr/bin/env bash
# Executa apply_remarketing_batch_tags e mostra o resultado.
# Uso: ./scripts/run-apply-remarketing-batch.sh [account_id]
# Requer: .env com TIPI_SERRA_POSTGRES_*

set -e
cd "$(dirname "$0")/.."
account_id="${1:-3}"

if [[ ! -f .env ]]; then
  echo "Crie o .env a partir de .env.example e defina TIPI_SERRA_POSTGRES_PASSWORD."
  exit 1
fi
set -a
source .env
set +a

export PGPASSWORD="${TIPI_SERRA_POSTGRES_PASSWORD:?Defina TIPI_SERRA_POSTGRES_PASSWORD no .env}"
export PGOPTIONS="-c client_min_messages=warning"

psql -h "${TIPI_SERRA_POSTGRES_HOST:-pg.tipidaserra.com.br}" \
     -p "${TIPI_SERRA_POSTGRES_PORT:-6433}" \
     -U "${TIPI_SERRA_POSTGRES_USER:-postgres}" \
     -d "${TIPI_SERRA_POSTGRES_DATABASE:-chatwoot}" \
     -v ON_ERROR_STOP=1 \
     -c "SELECT batch_name, tag_id, contact_count FROM apply_remarketing_batch_tags(${account_id}, 75);"

echo "--- Verificação: contatos por batch ---"
psql -h "${TIPI_SERRA_POSTGRES_HOST:-pg.tipidaserra.com.br}" \
     -p "${TIPI_SERRA_POSTGRES_PORT:-6433}" \
     -U "${TIPI_SERRA_POSTGRES_USER:-postgres}" \
     -d "${TIPI_SERRA_POSTGRES_DATABASE:-chatwoot}" \
     -v ON_ERROR_STOP=1 \
     -c "SELECT t.name AS batch_tag, COUNT(tg.taggable_id) AS contact_count FROM taggings tg JOIN tags t ON t.id = tg.tag_id WHERE tg.taggable_type = 'Contact' AND t.name ~ '^batch_[0-9]+\$' GROUP BY t.name ORDER BY t.name;"

echo "--- Contatos com batch (conta ${account_id}) ---"
psql -h "${TIPI_SERRA_POSTGRES_HOST:-pg.tipidaserra.com.br}" \
     -p "${TIPI_SERRA_POSTGRES_PORT:-6433}" \
     -U "${TIPI_SERRA_POSTGRES_USER:-postgres}" \
     -d "${TIPI_SERRA_POSTGRES_DATABASE:-chatwoot}" \
     -v ON_ERROR_STOP=1 \
     -c "SELECT c.name, c.phone_number, t.name AS batch_tag FROM contacts c JOIN taggings tg ON tg.taggable_type = 'Contact' AND tg.taggable_id = c.id JOIN tags t ON t.id = tg.tag_id WHERE t.name ~ '^batch_[0-9]+\$' AND c.account_id = ${account_id} ORDER BY t.name, c.name;"

unset PGPASSWORD
