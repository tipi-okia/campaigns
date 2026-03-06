-- Aplica tags batch_01, batch_02, ... em contatos com tag remarketing e telefone preenchido.
-- Ordena por nome, conta o total, remove tags batch antigas desses contatos e aplica novos blocos.
-- Critério: apenas telefone preenchido (não exige vínculo com inbox WhatsApp).
--
-- Parâmetros:
--   p_account_id    obrigatório
--   p_batch_size    tamanho do bloco (default 75)
--
-- Retorno: tabela (batch_name, tag_id, contact_count). Primeira linha: batch_name = '(total)', contact_count = total.

CREATE OR REPLACE FUNCTION apply_remarketing_batch_tags(
  p_account_id bigint,
  p_batch_size int DEFAULT 75
)
RETURNS TABLE(batch_name text, tag_id integer, contact_count integer)
LANGUAGE plpgsql
AS $$
DECLARE
  v_contact_ids bigint[];
  v_total int;
  v_num_batches int;
  v_batch_num int;
  v_batch_name text;
  v_tag_id int;
  v_start int;
  v_slice bigint[];
  v_cid bigint;
  v_tagger_type text := NULL;
  v_tagger_id int := NULL;
BEGIN
  -- Lista de contact_ids: remarketing + phone preenchido na conta, ordenada por name, id
  WITH base AS (
    SELECT c.id, c.name
    FROM contacts c
    INNER JOIN taggings tg ON tg.taggable_type = 'Contact' AND tg.taggable_id = c.id
    INNER JOIN tags t ON t.id = tg.tag_id AND t.name = 'remarketing'
    WHERE c.account_id = p_account_id
      AND c.phone_number IS NOT NULL AND trim(c.phone_number) <> ''
  )
  SELECT array_agg(id ORDER BY name, id) INTO v_contact_ids FROM base;

  IF v_contact_ids IS NULL THEN
    v_total := 0;
    batch_name := '(total)'; tag_id := NULL; contact_count := 0;
    RETURN NEXT;
    RETURN;
  END IF;

  v_total := array_length(v_contact_ids, 1);

  -- Remove tags batch existentes desses contatos
  DELETE FROM taggings tg
  WHERE tg.taggable_type = 'Contact'
    AND tg.taggable_id = ANY(v_contact_ids)
    AND tg.tag_id IN (SELECT id FROM tags WHERE name ~ '^batch_[0-9]+$');

  -- Linha de total
  batch_name := '(total)'; tag_id := NULL; contact_count := v_total;
  RETURN NEXT;

  -- Aplica batch_01, batch_02, ...
  v_num_batches := (v_total + p_batch_size - 1) / p_batch_size;
  FOR v_batch_num IN 1 .. v_num_batches LOOP
    v_batch_name := 'batch_' || lpad(v_batch_num::text, 2, '0');

    -- Garante que a tag existe
    INSERT INTO tags (name, taggings_count)
    VALUES (v_batch_name, 0)
    ON CONFLICT (name) DO NOTHING;

    SELECT id INTO v_tag_id FROM tags WHERE name = v_batch_name;

    v_start := (v_batch_num - 1) * p_batch_size + 1;
    v_slice := v_contact_ids[v_start : least(v_start + p_batch_size - 1, v_total)];

    FOR v_cid IN SELECT unnest(v_slice) LOOP
      INSERT INTO taggings (tag_id, taggable_type, taggable_id, tagger_type, tagger_id, context)
      VALUES (v_tag_id, 'Contact', v_cid, v_tagger_type, v_tagger_id, 'labels');
    END LOOP;

    batch_name := v_batch_name; tag_id := v_tag_id; contact_count := array_length(v_slice, 1);
    RETURN NEXT;
  END LOOP;
END;
$$;

COMMENT ON FUNCTION apply_remarketing_batch_tags(bigint, int) IS
'Aplica tags batch_01, batch_02, ... em contatos com tag remarketing e telefone preenchido (sem exigir inbox). Blocos de p_batch_size. Retorna total e por-batch.';

-- Sobrecarga para compatibilidade: chamada com 3 parâmetros (inbox_ids é ignorado).
CREATE OR REPLACE FUNCTION apply_remarketing_batch_tags(
  p_account_id bigint,
  p_inbox_ids bigint[],  -- ignorado; mantido para compatibilidade de assinatura
  p_batch_size int DEFAULT 75
)
RETURNS TABLE(batch_name text, tag_id integer, contact_count integer)
LANGUAGE sql
AS $$
  SELECT * FROM apply_remarketing_batch_tags(p_account_id, p_batch_size);
$$;

COMMENT ON FUNCTION apply_remarketing_batch_tags(bigint, bigint[], int) IS
'Compatibilidade: repassa para apply_remarketing_batch_tags(account_id, batch_size). p_inbox_ids é ignorado.';
