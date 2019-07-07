CREATE OR REPLACE FUNCTION control_inventario(nombre_inv varchar(255),descripcion_inv varchar(255)) RETURNS boolean AS
$$
DECLARE
	id_inv integer:=0;
BEGIN

    INSERT INTO inventarios(nombre,descripcion,fecha_creacion,fecha_actualizacion) values(nombre_inv,descripcion_inv, CURRENT_DATE,CURRENT_DATE) RETURNING id INTO id_inv;
	INSERT INTO inventario_controles(id_inventario,persona_realiza) values(id_inv,session_user::TEXT);

	INSERT INTO inventario_productos(id_producto,cantidad,id_inventario) 
	SELECT id, stock,id_inv FROM equipos JOIN productos ON productos.id = equipos.id_producto;
	
	INSERT INTO inventario_productos(id_producto,cantidad,id_inventario) 
	SELECT id, stock,id_inv FROM instrumentos JOIN productos ON productos.id = instrumentos.id_producto;
	
	INSERT INTO inventario_productos(id_producto,cantidad,id_inventario) 
	SELECT id, stock,id_inv FROM insumos JOIN productos ON productos.id = insumos.id_producto;
	RETURN TRUE;
	exception 
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
end;
$$ language plpgsql;


DROP FUNCTION control_inventario(character varying,character varying)
