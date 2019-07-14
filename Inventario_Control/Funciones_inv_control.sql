--Crea la funciones de control_inventario pasando como parametros los datos necesarios
CREATE OR REPLACE FUNCTION control_inventario(nombre_inv varchar(255),descripcion_inv varchar(255), observacion_inv varcahr(255)) RETURNS boolean AS
$$
DECLARE
	id_inv integer:=0;
BEGIN

    INSERT INTO inventarios(nombre,descripcion,observacion) values(nombre_inv,descripcion_inv, observacion_inv) RETURNING id INTO id_inv;
	INSERT INTO inventario_controles(id_inventario,persona_realiza) values(id_inv,session_user::TEXT);

	INSERT INTO inventario_productos(id_producto,cantidad,id_inventario) 
	
	RETURN TRUE;
	exception 
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
end;
$$ language plpgsql;

--Borra la función 
DROP FUNCTION control_inventario(character varying,character varying)
