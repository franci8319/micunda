-- Actualiza get_superadmin_stats para incluir el id de cada cunda
CREATE OR REPLACE FUNCTION get_superadmin_stats(p_token text)
RETURNS json LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'Pollico1@' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  RETURN json_build_object(
    'totales', json_build_object(
      'cundas',   (SELECT count(*)::int FROM cundas),
      'miembros', (SELECT count(*)::int FROM miembros  WHERE deleted_at IS NULL),
      'viajes',   (SELECT count(*)::int FROM viajes    WHERE deleted_at IS NULL),
      'emails',   (SELECT count(*)::int FROM email_logs)
    ),
    'cundas', (
      SELECT json_agg(row_to_json(t) ORDER BY t.ultimo_viaje DESC NULLS LAST)
      FROM (
        SELECT
          c.id,
          c.nombre,
          c.created_at::date                 AS creada,
          count(DISTINCT m.id)::int          AS miembros,
          count(DISTINCT v.id)::int          AS viajes,
          max(v.fecha)                       AS ultimo_viaje
        FROM      cundas   c
        LEFT JOIN miembros m ON m.cunda_id = c.id AND m.deleted_at IS NULL
        LEFT JOIN viajes   v ON v.cunda_id = c.id AND v.deleted_at IS NULL
        GROUP BY c.id, c.nombre, c.created_at
      ) t
    ),
    'emails_recientes', (
      SELECT json_agg(row_to_json(e))
      FROM (
        SELECT tipo, cunda_nombre, destinatarios, sent_at::date AS fecha
        FROM email_logs
        ORDER BY sent_at DESC
        LIMIT 50
      ) e
    )
  );
END;
$$;

-- Elimina una cunda y todos sus datos en cascada
CREATE OR REPLACE FUNCTION delete_cunda(p_token text, p_cunda_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'Pollico1@' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  DELETE FROM grupos_ocultos WHERE cunda_id = p_cunda_id;
  DELETE FROM viajes          WHERE cunda_id = p_cunda_id;
  DELETE FROM miembros        WHERE cunda_id = p_cunda_id;
  DELETE FROM cundas          WHERE id       = p_cunda_id;
END;
$$;
