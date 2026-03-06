-- Remove tags batch (batch_01, batch_02, ...) dos contatos.
-- Uso: após envio das campanhas ou para limpar antes de nova rodada.
--
-- Parâmetros:
--   p_account_id    opcional; se informado, remove apenas dos contatos dessa conta; se NULL, remove de todos
--
-- Retorno: número de taggings removidos.

CREATE OR REPLACE FUNCTION clear_remarketing_batch_tags(p_account_id bigint DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_deleted int;
BEGIN
  IF p_account_id IS NULL THEN
    WITH deleted AS (
      DELETE FROM taggings
      WHERE taggable_type = 'Contact'
        AND tag_id IN (SELECT id FROM tags WHERE name ~ '^batch_[0-9]+$')
      RETURNING 1
    )
    SELECT count(*)::int INTO v_deleted FROM deleted;
  ELSE
    WITH deleted AS (
      DELETE FROM taggings
      WHERE taggable_type = 'Contact'
        AND taggable_id IN (SELECT id FROM contacts WHERE account_id = p_account_id)
        AND tag_id IN (SELECT id FROM tags WHERE name ~ '^batch_[0-9]+$')
      RETURNING 1
    )
    SELECT count(*)::int INTO v_deleted FROM deleted;
  END IF;

  RETURN v_deleted;
END;
$$;

COMMENT ON FUNCTION clear_remarketing_batch_tags(bigint) IS
'Remove tags batch_01, batch_02, ... dos contatos. Se p_account_id for informado, apenas contatos dessa conta; se NULL, todos.';
