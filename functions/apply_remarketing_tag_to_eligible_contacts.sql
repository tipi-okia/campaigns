-- Aplica a tag "remarketing" em todos os contatos elegíveis:
--   - Número de WhatsApp válido (phone_number preenchido; não exige vínculo prévio com inbox WhatsApp)
--   - custom_attributes.cancelar_cadastro distinto de 'true' (ou ausente)
--
-- Parâmetros:
--   p_account_id    opcional; se informado, restringe aos contatos da conta; se NULL, todas as contas
--
-- Retorno: quantidade de contatos que receberam a tag (novas inserções em taggings).

CREATE OR REPLACE FUNCTION apply_remarketing_tag_to_eligible_contacts(p_account_id bigint DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_tag_id int;
  v_inserted int;
BEGIN
  -- Garante que a tag "remarketing" existe
  INSERT INTO tags (name, taggings_count)
  VALUES ('remarketing', 0)
  ON CONFLICT (name) DO NOTHING;

  SELECT id INTO v_tag_id FROM tags WHERE name = 'remarketing';

  -- Insere taggings apenas para contatos elegíveis que ainda não têm a tag
  -- Elegível: phone preenchido + cancelar_cadastro != 'true' (sem exigir contact_inboxes WhatsApp)
  WITH eligible AS (
    SELECT c.id AS contact_id
    FROM contacts c
    WHERE c.phone_number IS NOT NULL
      AND trim(c.phone_number) <> ''
      AND (c.custom_attributes->>'cancelar_cadastro') IS DISTINCT FROM 'true'
      AND (p_account_id IS NULL OR c.account_id = p_account_id)
  ),
  to_insert AS (
    SELECT e.contact_id
    FROM eligible e
    WHERE NOT EXISTS (
      SELECT 1
      FROM taggings tg
      WHERE tg.taggable_type = 'Contact'
        AND tg.taggable_id = e.contact_id
        AND tg.tag_id = v_tag_id
        AND tg.context = 'labels'
    )
  )
  INSERT INTO taggings (tag_id, taggable_type, taggable_id, tagger_type, tagger_id, context)
  SELECT v_tag_id, 'Contact', contact_id, NULL, NULL, 'labels'
  FROM to_insert;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  RETURN v_inserted;
END;
$$;

COMMENT ON FUNCTION apply_remarketing_tag_to_eligible_contacts(bigint) IS
'Aplica a tag remarketing em contatos com phone preenchido e cancelar_cadastro != true. p_account_id opcional (NULL = todas as contas).';
