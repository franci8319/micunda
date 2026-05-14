-- Actualiza update_miembro_datos para aceptar rol opcional
CREATE OR REPLACE FUNCTION update_miembro_datos(p_token text, p_miembro_id uuid, p_nombre text, p_email text, p_rol text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_token != 'Pollico1@' THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  IF p_rol IS NOT NULL AND p_rol NOT IN ('admin', 'editor') THEN
    RAISE EXCEPTION 'Rol no válido';
  END IF;
  UPDATE miembros
  SET nombre = trim(p_nombre),
      email  = lower(trim(p_email)),
      rol    = COALESCE(p_rol, rol)
  WHERE id = p_miembro_id;
END;
$$;
