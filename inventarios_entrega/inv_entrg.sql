CREATE OR REPLACE FUNCTION entrega_inventario(nombre_inv varchar(255),descripcion_inv varchar(255), observacion_inv varchar(255),productos_inv json,persona_entrega varchar(255)) RETURNS boolean AS
$$
DECLARE
	id_inv integer:=0;
	i json;
	cant_prod integer:=0;
	sum_inv integer:=0;
BEGIN
	Select count(id) INTO sum_inv FROM inventarios WHERE nombre=nombre_inv;
	IF sum_inv = 0 THEN
		INSERT INTO inventarios(nombre,descripcion,observacion) values(nombre_inv,descripcion_inv,observacion_inv) RETURNING id INTO id_inv;
		FOR i IN SELECT * FROM json_array_elements(productos_inv)
  		LOOP
			INSERT INTO inventario_entregas(id_inventario,id_producto,persona_entrega,persona_recibe,cantidad) values(id_inv,(i->>'id_producto')::int,persona_entrega,session_user::TEXT,(i->>'cantidad')::int);
  			UPDATE productos SET stock = stock+(i->>'cantidad')::int WHERE id = (i->>'id_producto')::int;
		END LOOP;	
		RETURN TRUE;
	ELSE
		Select id INTO id_inv FROM inventarios WHERE nombre=nombre_inv;
		FOR i IN SELECT * FROM json_array_elements(productos_inv)
  		LOOP
			INSERT INTO inventario_entregas(id_inventario,id_producto,persona_entrega,persona_recibe,cantidad) values(id_inv,(i->>'id_producto')::int,persona_entrega,session_user::TEXT,(i->>'cantidad')::int);
  			UPDATE productos SET stock = stock+(i->>'cantidad')::int  WHERE id = (i->>'id_producto')::int;
		END LOOP;	
		RETURN TRUE;
	END IF;
	exception 
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
end;
$$ language plpgsql;


select entrega_inventario('Inventario prueba','Descripcion de prueba', 'Observacion de prueba','[{ "id_producto": 2, "cantidad":2 }, { "id_producto": 3, "cantidad":8 }]','0105476097')

DROP FUNCTION entrega_inventario(character varying,character varying,character varying,json,character varying);
