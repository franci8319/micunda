-- ================================================
--  MICUNDA — Schema v1
-- ================================================

-- Extensión para cifrado de contraseñas
create extension if not exists pgcrypto;


-- ================================================
--  CUNDAS
-- ================================================
create table cundas (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  created_at  timestamptz default now()
);


-- ================================================
--  MIEMBROS
-- ================================================
create table miembros (
  id              uuid primary key default gen_random_uuid(),
  cunda_id        uuid not null references cundas(id) on delete cascade,
  nombre          text not null,
  usuario         text not null,
  password_hash   text not null,
  rol             text not null check (rol in ('admin', 'editor')),
  incorporado_at  date not null default current_date,
  created_at      timestamptz default now(),
  created_by      uuid references miembros(id),

  unique(cunda_id, usuario)
);

create index idx_miembros_cunda on miembros(cunda_id);


-- ================================================
--  VIAJES
-- ================================================
create table viajes (
  id            bigint primary key generated always as identity,
  cunda_id      uuid not null references cundas(id) on delete cascade,
  fecha         date not null,
  conductor_id  uuid not null references miembros(id),
  asistentes    uuid[] not null default '{}',
  created_by    uuid not null references miembros(id),
  created_at    timestamptz default now(),
  updated_by    uuid references miembros(id),
  updated_at    timestamptz,
  deleted_by    uuid references miembros(id),
  deleted_at    timestamptz
);

create index idx_viajes_cunda_fecha on viajes(cunda_id, fecha);
create index idx_viajes_conductor   on viajes(conductor_id);


-- ================================================
--  FUNCIÓN DE LOGIN
--  Verifica usuario + contraseña y devuelve el miembro
-- ================================================
create or replace function login(
  p_cunda_id uuid,
  p_usuario  text,
  p_password text
)
returns table (
  id             uuid,
  nombre         text,
  rol            text,
  incorporado_at date
)
language sql security definer as $$
  select id, nombre, rol, incorporado_at
  from   miembros
  where  cunda_id      = p_cunda_id
    and  usuario       = p_usuario
    and  password_hash = crypt(p_password, password_hash);
$$;


-- ================================================
--  FUNCIÓN PARA CREAR ADMIN + CUNDA EN UN PASO
-- ================================================
create or replace function crear_cunda(
  p_nombre_cunda   text,
  p_nombre_admin   text,
  p_usuario_admin  text,
  p_password_admin text
)
returns uuid
language plpgsql security definer as $$
declare
  v_cunda_id  uuid;
  v_admin_id  uuid;
begin
  -- Crear la cunda
  insert into cundas(nombre) values (p_nombre_cunda)
  returning id into v_cunda_id;

  -- Crear el admin (created_by se actualiza después porque aún no existe)
  insert into miembros(cunda_id, nombre, usuario, password_hash, rol)
  values (
    v_cunda_id,
    p_nombre_admin,
    p_usuario_admin,
    crypt(p_password_admin, gen_salt('bf')),
    'admin'
  )
  returning id into v_admin_id;

  -- El admin se crea a sí mismo
  update miembros set created_by = v_admin_id where id = v_admin_id;

  return v_cunda_id;
end;
$$;


-- ================================================
--  FUNCIÓN PARA AÑADIR MIEMBRO (solo admins)
-- ================================================
create or replace function añadir_miembro(
  p_cunda_id       uuid,
  p_nombre         text,
  p_usuario        text,
  p_password       text,
  p_rol            text,
  p_incorporado_at date,
  p_created_by     uuid
)
returns uuid
language plpgsql security definer as $$
declare
  v_id uuid;
begin
  insert into miembros(cunda_id, nombre, usuario, password_hash, rol, incorporado_at, created_by)
  values (
    p_cunda_id,
    p_nombre,
    p_usuario,
    crypt(p_password, gen_salt('bf')),
    p_rol,
    p_incorporado_at,
    p_created_by
  )
  returning id into v_id;

  return v_id;
end;
$$;
