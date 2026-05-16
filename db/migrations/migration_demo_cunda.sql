-- ══════════════════════════════════════════════════════════
-- MIGRACIÓN: CUNDA DEMO (para vídeo)
-- Misma estructura de viajes que Albolote, datos ficticios
-- Ejecutar en: Supabase > SQL Editor
-- ══════════════════════════════════════════════════════════
--
-- Miembros:
--   Carlos  →  carlos@demo.es   /  demo1234  /  admin   (≈ Francis)
--   Ana     →  ana@demo.es      /  demo1234  /  admin   (≈ Plácido)
--   Luis    →  luis@demo.es     /  demo1234  /  admin   (≈ Boro)
--   Marta   →  marta@demo.es    /  demo1234  /  editor  (≈ Miguel)
-- ══════════════════════════════════════════════════════════

DO $$
DECLARE
  v_cunda  uuid;
  v_carlos uuid;
  v_ana    uuid;
  v_luis   uuid;
  v_marta  uuid;
BEGIN

  -- ── 1. Crear la cunda Demo ────────────────────────────────
  SELECT crear_cunda(
    'Cunda Demo',
    'Carlos',
    'carlos@demo.es',
    'demo1234'
  ) INTO v_cunda;

  SELECT id INTO v_carlos
    FROM miembros
   WHERE cunda_id = v_cunda AND nombre = 'Carlos';

  -- ── 2. Añadir miembros ────────────────────────────────────
  SELECT añadir_miembro(v_cunda, 'Ana',   'ana@demo.es',   'demo1234', 'admin',  '2026-03-01', v_carlos) INTO v_ana;
  SELECT añadir_miembro(v_cunda, 'Luis',  'luis@demo.es',  'demo1234', 'admin',  '2026-03-01', v_carlos) INTO v_luis;
  SELECT añadir_miembro(v_cunda, 'Marta', 'marta@demo.es', 'demo1234', 'editor', '2026-03-01', v_carlos) INTO v_marta;

  -- ── 3. Retrotraer incorporado_at de Carlos ────────────────
  --    (crear_cunda lo fija a current_date, lo ajustamos)
  UPDATE miembros SET incorporado_at = '2026-03-01'
   WHERE cunda_id = v_cunda AND nombre = 'Carlos';

  -- ── 4. Insertar los 14 viajes ─────────────────────────────
  --    Mapeo: Francis→Carlos, Plácido→Ana, Boro→Luis, Miguel→Marta
  INSERT INTO viajes (cunda_id, fecha, conductor_id, asistentes, created_by) VALUES
    (v_cunda, '2026-03-11', v_luis,   ARRAY[v_marta, v_carlos],           v_carlos),
    (v_cunda, '2026-03-14', v_luis,   ARRAY[v_marta, v_carlos],           v_carlos),
    (v_cunda, '2026-03-15', v_luis,   ARRAY[v_carlos, v_marta, v_ana],    v_carlos),
    (v_cunda, '2026-03-23', v_carlos, ARRAY[v_marta, v_ana],              v_carlos),
    (v_cunda, '2026-03-30', v_carlos, ARRAY[v_marta, v_luis],             v_carlos),
    (v_cunda, '2026-03-31', v_carlos, ARRAY[v_luis, v_marta],             v_carlos),
    (v_cunda, '2026-04-07', v_marta,  ARRAY[v_luis, v_carlos],            v_carlos),
    (v_cunda, '2026-04-08', v_ana,    ARRAY[v_luis, v_carlos, v_marta],   v_carlos),
    (v_cunda, '2026-04-09', v_marta,  ARRAY[v_luis, v_carlos],            v_carlos),
    (v_cunda, '2026-04-16', v_luis,   ARRAY[v_marta, v_ana],              v_carlos),
    (v_cunda, '2026-04-23', v_marta,  ARRAY[v_luis, v_carlos],            v_carlos),
    (v_cunda, '2026-05-09', v_luis,   ARRAY[v_marta, v_carlos],           v_carlos),
    (v_cunda, '2026-05-10', v_carlos, ARRAY[v_marta, v_luis],             v_carlos),
    (v_cunda, '2026-05-11', v_carlos, ARRAY[v_marta, v_luis],             v_carlos);

  -- ── 5. Verificación ───────────────────────────────────────
  RAISE NOTICE 'Cunda Demo ID: %', v_cunda;
  RAISE NOTICE 'Carlos: %', v_carlos;
  RAISE NOTICE 'Ana:    %', v_ana;
  RAISE NOTICE 'Luis:   %', v_luis;
  RAISE NOTICE 'Marta:  %', v_marta;
  RAISE NOTICE 'Viajes: %', (SELECT count(*) FROM viajes WHERE cunda_id = v_cunda);

END;
$$;
