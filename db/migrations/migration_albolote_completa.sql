-- ══════════════════════════════════════════════════════════
-- MIGRACIÓN COMPLETA: CUNDA ALBOLOTE
-- Proyecto: micunda.es (kjjdsfhtlqhatxyoljyg.supabase.co)
-- Ejecutar en: Supabase > SQL Editor
-- ══════════════════════════════════════════════════════════

DO $$
DECLARE
  v_cunda   uuid;
  v_francis uuid;
  v_placido uuid := gen_random_uuid();
  v_miguel  uuid := gen_random_uuid();
  v_boro    uuid := gen_random_uuid();
BEGIN

  -- ── 1. Limpiar todos los datos de prueba ──────────────────
  DELETE FROM viajes;
  DELETE FROM grupos_ocultos;
  DELETE FROM miembros;
  DELETE FROM cundas;

  -- ── 2. Crear la cunda Albolote + Francis como admin ───────
  --    (usar la RPC existente que gestiona el hash de contraseña)
  SELECT crear_cunda(
    'Albolote',
    'Francis',
    'fvilleguillas@gmail.com',
    'cunda1234'
  ) INTO v_cunda;

  SELECT id INTO v_francis
    FROM miembros
   WHERE cunda_id = v_cunda AND nombre = 'Francis';

  -- ── 3. Añadir Plácido, Miguel y Boro ──────────────────────
  SELECT añadir_miembro(v_cunda, 'Plácido', 'superpisca@hotmail.com',  'cunda1234', 'admin',  current_date, v_francis) INTO v_placido;
  SELECT añadir_miembro(v_cunda, 'Miguel',  'cholin777@hotmail.com',   'cunda1234', 'editor', current_date, v_francis) INTO v_miguel;
  SELECT añadir_miembro(v_cunda, 'Boro',    'boropadul1234@gmail.com', 'cunda1234', 'editor', current_date, v_francis) INTO v_boro;

  -- ── 4. Importar los 14 viajes del historial ───────────────
  --    Asistentes = quién estuvo en el coche (sin el conductor)
  INSERT INTO viajes (cunda_id, fecha, conductor_id, asistentes, created_by) VALUES
    (v_cunda, '2026-03-11', v_boro,    ARRAY[v_miguel, v_francis],                 v_francis),
    (v_cunda, '2026-03-14', v_boro,    ARRAY[v_miguel, v_francis],                 v_francis),
    (v_cunda, '2026-03-15', v_boro,    ARRAY[v_francis, v_miguel, v_placido],      v_francis),
    (v_cunda, '2026-03-23', v_francis, ARRAY[v_miguel, v_placido],                 v_francis),
    (v_cunda, '2026-03-30', v_francis, ARRAY[v_miguel, v_boro],                    v_francis),
    (v_cunda, '2026-03-31', v_francis, ARRAY[v_boro, v_miguel],                    v_francis),
    (v_cunda, '2026-04-07', v_miguel,  ARRAY[v_boro, v_francis],                   v_francis),
    (v_cunda, '2026-04-08', v_placido, ARRAY[v_boro, v_francis, v_miguel],         v_francis),
    (v_cunda, '2026-04-09', v_miguel,  ARRAY[v_boro, v_francis],                   v_francis),
    (v_cunda, '2026-04-16', v_boro,    ARRAY[v_miguel, v_placido],                 v_francis),
    (v_cunda, '2026-04-23', v_miguel,  ARRAY[v_boro, v_francis],                   v_francis),
    (v_cunda, '2026-05-09', v_boro,    ARRAY[v_miguel, v_francis],                 v_francis),
    (v_cunda, '2026-05-10', v_francis, ARRAY[v_miguel, v_boro],                    v_francis),
    (v_cunda, '2026-05-11', v_francis, ARRAY[v_miguel, v_boro],                    v_francis);

  -- ── 5. Verificación ───────────────────────────────────────
  RAISE NOTICE 'Cunda ID: %', v_cunda;
  RAISE NOTICE 'Francis:  %', v_francis;
  RAISE NOTICE 'Plácido:  %', v_placido;
  RAISE NOTICE 'Miguel:   %', v_miguel;
  RAISE NOTICE 'Boro:     %', v_boro;
  RAISE NOTICE 'Viajes insertados: %', (SELECT count(*) FROM viajes WHERE cunda_id = v_cunda);

END;
$$;

-- Comprobación final (ejecutar aparte si quieres ver los datos)
-- SELECT nombre, email, rol FROM miembros ORDER BY incorporado_at;
-- SELECT fecha, conductor_id, asistentes FROM viajes ORDER BY fecha;
