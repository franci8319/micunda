-- ══════════════════════════════════════════════
-- SETUP CUNDA ALBOLOTE
-- Ejecutar en Supabase > SQL Editor
-- ══════════════════════════════════════════════

-- 1. Renombrar la cunda
UPDATE cundas SET nombre = 'Albolote';

-- 2. Ver los miembros actuales (para verificar nombres antes de actualizar)
SELECT id, nombre, email, rol FROM miembros WHERE deleted_at IS NULL;

-- 3. Francis — admin
UPDATE miembros SET email = 'fvilleguillas@gmail.com', rol = 'admin'
  WHERE lower(nombre) LIKE '%francis%' AND deleted_at IS NULL;
SELECT change_password(id, 'cunda1234')
  FROM miembros WHERE lower(nombre) LIKE '%francis%' AND deleted_at IS NULL;

-- 4. Plácido — admin
UPDATE miembros SET email = 'superpisca@hotmail.com', rol = 'admin'
  WHERE (lower(nombre) LIKE '%plácido%' OR lower(nombre) LIKE '%placido%') AND deleted_at IS NULL;
SELECT change_password(id, 'cunda1234')
  FROM miembros WHERE (lower(nombre) LIKE '%plácido%' OR lower(nombre) LIKE '%placido%') AND deleted_at IS NULL;

-- 5. Miguel — editor
UPDATE miembros SET email = 'cholin777@hotmail.com', rol = 'editor'
  WHERE lower(nombre) LIKE '%miguel%' AND deleted_at IS NULL;
SELECT change_password(id, 'cunda1234')
  FROM miembros WHERE lower(nombre) LIKE '%miguel%' AND deleted_at IS NULL;

-- 6. Boro — editor (email provisional)
UPDATE miembros SET email = 'boropadul1234@gmail.com', rol = 'editor'
  WHERE lower(nombre) LIKE '%boro%' AND deleted_at IS NULL;
SELECT change_password(id, 'cunda1234')
  FROM miembros WHERE lower(nombre) LIKE '%boro%' AND deleted_at IS NULL;

-- 7. Verificación final
SELECT nombre, email, rol FROM miembros WHERE deleted_at IS NULL ORDER BY incorporado_at;
