-- Devuelve los miembros de una cunda
CREATE OR REPLACE FUNCTION get_cunda_miembros(p_token text, p_cunda_id uuid)
RETURNS json LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'Pollico1@' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  RETURN (
    SELECT json_agg(row_to_json(t) ORDER BY t.incorporado_at)
    FROM (
      SELECT id, nombre, email, rol, incorporado_at, deleted_at
      FROM miembros
      WHERE cunda_id = p_cunda_id
    ) t
  );
END;
$$;

-- Actualiza el nombre de una cunda
CREATE OR REPLACE FUNCTION update_cunda_nombre(p_token text, p_cunda_id uuid, p_nombre text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'Pollico1@' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  UPDATE cundas SET nombre = trim(p_nombre) WHERE id = p_cunda_id;
END;
$$;

-- Actualiza nombre y email de un miembro
CREATE OR REPLACE FUNCTION update_miembro_datos(p_token text, p_miembro_id uuid, p_nombre text, p_email text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'Pollico1@' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  UPDATE miembros
  SET nombre = trim(p_nombre),
      email  = lower(trim(p_email))
  WHERE id = p_miembro_id;
END;
$$;
