CREATE OR REPLACE FUNCTION prueba() RETURNS json AS
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




{"{\"id\":1,\"nombre\":\"Inventario 1 de prueba\",\"descripcion\":\"Descripcion de prueba\",\"fecha_creacion\":\"2019-07-07T19:20:01.367147\",\"fecha_actualizacion\":\"2019-07-07T19:20:01.367147\",\"persona_realiza\":\"admin\",\"productos\":[{\"id\":1,\"nombre\":\"Equipo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Equipo\",\"precio_unitario\":9.99,\"cantidad\":\"10\"},{\"id\":2,\"nombre\":\"Equipo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Equipo\",\"precio_unitario\":99.99,\"cantidad\":\"10\"},{\"id\":5,\"nombre\":\"Insumo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Instrumento\",\"precio_unitario\":85.69,\"cantidad\":\"100\"},{\"id\":6,\"nombre\":\"Insumo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Instrumento\",\"precio_unitario\":85.69,\"cantidad\":\"100\"},{\"id\":4,\"nombre\":\"Instrumento\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Insumo\",\"precio_unitario\":99.99,\"cantidad\":\"1\"},{\"id\":3,\"nombre\":\"Instrumento\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Insumo\",\"precio_unitario\":99.99,\"cantidad\":\"1\"}]}","{\"id\":2,\"nombre\":\"2\",\"descripcion\":\"Prueba\",\"fecha_creacion\":\"2019-07-07T21:39:46.225172\",\"fecha_actualizacion\":\"2019-07-07T21:39:46.225172\",\"persona_realiza\":\"postgres\",\"productos\":[{\"id\":1,\"nombre\":\"Equipo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Equipo\",\"precio_unitario\":9.99,\"cantidad\":\"10\"},{\"id\":2,\"nombre\":\"Equipo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Equipo\",\"precio_unitario\":99.99,\"cantidad\":\"10\"},{\"id\":5,\"nombre\":\"Insumo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Instrumento\",\"precio_unitario\":85.69,\"cantidad\":\"100\"},{\"id\":6,\"nombre\":\"Insumo de prueba\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Instrumento\",\"precio_unitario\":85.69,\"cantidad\":\"100\"},{\"id\":4,\"nombre\":\"Instrumento\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Insumo\",\"precio_unitario\":99.99,\"cantidad\":\"1\"},{\"id\":3,\"nombre\":\"Instrumento\",\"descripcion\":\"No existe descripción\",\"categoria\":\"Insumo\",\"precio_unitario\":99.99,\"cantidad\":\"1\"}]}"}