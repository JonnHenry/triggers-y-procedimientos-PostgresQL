CREATE OR REPLACE FUNCTION control_inventario_productos(anyelement) RETURNS json AS
$$
DECLARE
	rec record;
	valor int:=0;
	array_inv json[];
	dato_json json;
BEGIN
	FOR  rec IN SELECT id_inventario FROM inventario_controles LOOP
		select row_to_json(t) INTO dato_json::json
		from (
			select id,nombre,descripcion,fecha_creacion,fecha_actualizacion,persona_realiza,
			(
				select array_to_json(array_agg(row_to_json(d)))
				from(
					SELECT prod.id,prod.nombre,prod.descripcion,prod.categoria,prod.precio_unitario,inv.cantidad 
					FROM productos as prod JOIN inventario_productos as inv ON inv.id_producto = prod.id WHERE inv.id_inventario=rec.id_inventario
				) d
			) as productos
			FROM inventarios JOIN inventario_controles ON inventarios.id = inventario_controles.id_inventario WHERE id=rec.id_inventario
		) t;
		SELECT array_append(array_inv,dato_json) into array_inv;
    END LOOP;
	RETURN array_inv;
	exception 
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN array_inv;
end;
$$ language plpgsql;