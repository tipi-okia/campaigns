-- Remove contatos com custom_attributes.cancelar_cadastro = true.
-- Elimina dependências (group_members, taggings, contact_inboxes, conversations, notes, csat_survey_responses) e depois o contato.
--
-- Parâmetros:
--   p_account_id    obrigatório; apenas contatos desta conta são considerados
--
-- Retorno: número de contatos removidos.

CREATE OR REPLACE FUNCTION delete_contacts_cancelar_cadastro(p_account_id bigint)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
  v_contact_ids integer[];
  v_deleted_count bigint := 0;
BEGIN
  IF p_account_id IS NULL THEN
    RAISE EXCEPTION 'p_account_id é obrigatório';
  END IF;

  -- Contatos com cancelar_cadastro = true (boolean ou string 'true'/'t')
  SELECT array_agg(id ORDER BY id)
  INTO v_contact_ids
  FROM contacts
  WHERE account_id = p_account_id
    AND (
      (custom_attributes->>'cancelar_cadastro') IN ('true', 't')
      OR (custom_attributes->'cancelar_cadastro') = 'true'::jsonb
    );

  IF v_contact_ids IS NULL OR array_length(v_contact_ids, 1) = 0 THEN
    RETURN 0;
  END IF;

  -- 1. group_members (FK NO ACTION para contacts)
  DELETE FROM group_members
  WHERE contact_id = ANY(v_contact_ids);

  -- 2. taggings (Contact)
  DELETE FROM taggings
  WHERE taggable_type = 'Contact'
    AND taggable_id = ANY(v_contact_ids);

  -- 3. contact_inboxes
  DELETE FROM contact_inboxes
  WHERE contact_id = ANY(v_contact_ids);

  -- 4. messages das conversas desses contatos (evita órfãos se houver FK em outro ambiente)
  DELETE FROM messages
  WHERE conversation_id IN (
    SELECT id FROM conversations WHERE contact_id = ANY(v_contact_ids)
  );

  -- 5. conversations
  DELETE FROM conversations
  WHERE contact_id = ANY(v_contact_ids);

  -- 6. notes
  DELETE FROM notes
  WHERE contact_id = ANY(v_contact_ids);

  -- 7. csat_survey_responses
  DELETE FROM csat_survey_responses
  WHERE contact_id = ANY(v_contact_ids);

  -- 8. contacts
  WITH deleted AS (
    DELETE FROM contacts
    WHERE id = ANY(v_contact_ids)
    RETURNING 1
  )
  SELECT count(*)::bigint INTO v_deleted_count FROM deleted;

  RETURN v_deleted_count;
END;
$$;

COMMENT ON FUNCTION delete_contacts_cancelar_cadastro(bigint) IS
'Elimina contatos da conta com custom_attributes.cancelar_cadastro = true, removendo antes dependências (group_members, taggings, contact_inboxes, messages, conversations, notes, csat_survey_responses). Retorna o número de contatos deletados.';
