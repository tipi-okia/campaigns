#!/usr/bin/env bash
# Wrapper para o MCP Postgres Tipi da Serra: carrega .env do projeto e inicia o server.
# Uso: scripts/mcp-tipi-serra-postgres.sh (Cursor chama isso via .cursor/mcp.json)

set -e
cd "$(dirname "$0")/.."

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

export POSTGRES_HOST="${TIPI_SERRA_POSTGRES_HOST:-pg.tipidaserra.com.br}"
export POSTGRES_PORT="${TIPI_SERRA_POSTGRES_PORT:-6433}"
export POSTGRES_DATABASE="${TIPI_SERRA_POSTGRES_DATABASE:-chatwoot}"
export POSTGRES_USER="${TIPI_SERRA_POSTGRES_USER:-postgres}"
export POSTGRES_PASSWORD="${TIPI_SERRA_POSTGRES_PASSWORD:?Defina TIPI_SERRA_POSTGRES_PASSWORD no .env ou no ambiente}"

exec /usr/local/bin/toolbox --prebuilt postgres --stdio
