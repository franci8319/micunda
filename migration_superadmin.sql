-- Tabla de logs de emails enviados
CREATE TABLE IF NOT EXISTS email_logs (
  id           uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  sent_at      timestamptz DEFAULT now(),
  tipo         text        NOT NULL,  -- 'semanal' | 'contrasena'
  cunda_nombre text,
  destinatarios int        DEFAULT 1
);

-- Función de stats para el panel de super-admin
-- Cambia 'MICUNDA_SUPERADMIN_TOKEN' por un token secreto antes de ejecutar
CREATE OR REPLACE FUNCTION get_superadmin_stats(p_token text)
RETURNS json LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'MICUNDA_SUPERADMIN_TOKEN' THEN
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
          c.nombre,
          c.created_at::date                                      AS creada,
          count(DISTINCT m.id)::int                               AS miembros,
          count(DISTINCT v.id)::int                               AS viajes,
          max(v.fecha)                                            AS ultimo_viaje
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
