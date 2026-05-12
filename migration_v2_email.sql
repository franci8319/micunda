-- ================================================
--  MICUNDA — Migración v2: usuario → email
-- ================================================

-- 1. Renombrar columna
ALTER TABLE miembros RENAME COLUMN usuario TO email;

-- 2. Normalizar emails a minúsculas
UPDATE miembros SET email = LOWER(email);

-- 3. Nombre único por cunda (insensible a mayúsculas)
CREATE UNIQUE INDEX idx_miembros_nombre_unique
  ON miembros(cunda_id, LOWER(nombre));

-- 4. Actualizar función login
CREATE OR REPLACE FUNCTION login(
  p_cunda_id uuid,
  p_email    text,
  p_password text
)
RETURNS TABLE (
  id             uuid,
  nombre         text,
  rol            text,
  incorporado_at date
)
LANGUAGE sql SECURITY DEFINER AS $$
  SELECT id, nombre, rol, incorporado_at
  FROM   miembros
  WHERE  cunda_id      = p_cunda_id
    AND  email         = LOWER(p_email)
    AND  password_hash = crypt(p_password, password_hash);
$$;

-- 5. Actualizar función crear_cunda
CREATE OR REPLACE FUNCTION crear_cunda(
  p_nombre_cunda   text,
  p_nombre_admin   text,
  p_email_admin    text,
  p_password_admin text
)
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_cunda_id uuid;
  v_admin_id uuid;
BEGIN
  INSERT INTO cundas(nombre) VALUES (p_nombre_cunda)
  RETURNING id INTO v_cunda_id;

  INSERT INTO miembros(cunda_id, nombre, email, password_hash, rol)
  VALUES (
    v_cunda_id,
    p_nombre_admin,
    LOWER(p_email_admin),
    crypt(p_password_admin, gen_salt('bf')),
    'admin'
  )
  RETURNING id INTO v_admin_id;

  UPDATE miembros SET created_by = v_admin_id WHERE id = v_admin_id;
  RETURN v_cunda_id;
END;
$$;

-- 6. Actualizar función añadir_miembro
CREATE OR REPLACE FUNCTION añadir_miembro(
  p_cunda_id       uuid,
  p_nombre         text,
  p_email          text,
  p_password       text,
  p_rol            text,
  p_incorporado_at date,
  p_created_by     uuid
)
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO miembros(cunda_id, nombre, email, password_hash, rol, incorporado_at, created_by)
  VALUES (
    p_cunda_id,
    p_nombre,
    LOWER(p_email),
    crypt(p_password, gen_salt('bf')),
    p_rol,
    p_incorporado_at,
    p_created_by
  )
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
