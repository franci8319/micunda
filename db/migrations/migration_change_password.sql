-- Función para que un miembro cambie su propia contraseña,
-- o para que el admin la restablezca vía RPC.
CREATE OR REPLACE FUNCTION change_password(p_id uuid, p_new_password text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE miembros
  SET    password_hash = crypt(p_new_password, gen_salt('bf'))
  WHERE  id = p_id;
END;
$$;
