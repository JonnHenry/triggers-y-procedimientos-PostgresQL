CREATE OR REPLACE FUNCTION ingreso_tratamiento( nombre_trat varchar(255),precio_trat float,descripcion_trat varchar(25),datos_prod json) RETURNS boolean AS
$$
DECLARE
    i json;
	id_int integer;
BEGIN
	INSERT INTO tratamientos(nombre,precio,descripcion,fecha_creacion,fecha_actualizacion) values(nombre_trat,precio_trat,descripcion_trat, CURRENT_DATE,CURRENT_DATE) RETURNING id INTO id_int;
	FOR i IN SELECT * FROM json_array_elements(datos_prod)
  	LOOP
		INSERT INTO tratamiento_productos(id_tratamiento,id_producto,cantidad_producto) values(id_int,(i->>'id')::int,(i->>'cantidad')::int);
  	END LOOP;
	RETURN TRUE;
	EXCEPTION
    WHEN OTHERS THEN
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
END;
$$ language plpgsql


CREATE OR REPLACE FUNCTION inicia_tratamiento(id_tratamiento_trat integer) RETURNS boolean AS
$$
DECLARE
	rec record;
	cantidad_prod int;
BEGIN
	FOR rec IN SELECT id_producto,productos.categoria, tratamiento_productos.cantidad_producto FROM tratamiento_productos JOIN productos ON productos.id = tratamiento_productos.id_producto JOIN tratamientos ON tratamiento_productos.id_tratamiento=tratamientos.id WHERE id_tratamiento=id_tratamiento_trat
  	LOOP
		IF rec.categoria = 'Equipo' THEN
			SELECT stock into cantidad_prod from equipos WHERE id_producto=rec.id_producto;
			IF cantidad_prod - rec.cantidad_producto>0 THEN
				UPDATE equipos SET stock = cantidad_prod - rec.cantidad_producto WHERE id_producto=rec.id_producto;
			ELSE
				RETURN FALSE;
			END IF;
			
		ELSIF rec.categoria = 'Insumo' THEN
			SELECT stock into cantidad_prod from insumos WHERE id_producto=rec.id_producto;
			IF cantidad_prod - rec.cantidad_producto > 0 THEN
				UPDATE insumos SET stock = cantidad_prod - rec.cantidad_producto WHERE id_producto=rec.id_producto;
			ELSE
				RETURN FALSE;
			END IF;
		ELSIF rec.categoria = 'Instrumento' THEN
			SELECT stock into cantidad_prod from instrumentos WHERE id_producto=rec.id_producto;
			IF cantidad_prod - rec.cantidad_producto > 0 THEN
				UPDATE instrumentos SET stock = cantidad_prod - rec.cantidad_producto WHERE id_producto=rec.id_producto;
			ELSE
				RETURN FALSE;
			END IF;
		ELSE
			RETURN FALSE;
			
		END IF;
	END LOOP;
	RETURN TRUE;
	EXCEPTION
    WHEN OTHERS THEN
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
END;
$$ language plpgsql



CREATE OR REPLACE FUNCTION termina_tratamiento(id_tratamiento_trat integer, insumos_desechados integer[]) RETURNS boolean AS
$$
DECLARE
	rec record;
	cantidad_prod int;
BEGIN
	FOR rec IN SELECT id_producto,productos.categoria, tratamiento_productos.cantidad_producto FROM tratamiento_productos JOIN productos ON productos.id = tratamiento_productos.id_producto JOIN tratamientos ON tratamiento_productos.id_tratamiento=tratamientos.id WHERE id_tratamiento=id_tratamiento_trat
  	LOOP
		IF rec.categoria = 'Equipo' THEN
			--SELECT stock into cantidad_prod from equipos WHERE id_producto=rec.id_producto;
			UPDATE equipos SET stock = stock + rec.cantidad_producto WHERE id_producto=rec.id_producto;
		ELSIF rec.categoria = 'Insumo' THEN
			--SELECT stock into cantidad_prod from insumos WHERE id_producto=rec.id_producto;
			UPDATE insumos SET stock = stock + rec.cantidad_producto WHERE id_producto=rec.id_producto;
		ELSIF rec.categoria = 'Instrumento' THEN
			--SELECT stock into cantidad_prod from instrumentos WHERE id_producto=rec.id_producto;
			IF insumos_desechados @> rec.id_producto THEN
				UPDATE instrumentos SET stock = stock + rec.cantidad_producto WHERE id_producto=rec.id_producto;
			END IF;	
		ELSE
			RETURN FALSE;
		END IF;
	END LOOP;
	RETURN TRUE;
	EXCEPTION
    WHEN OTHERS THEN
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
END;
$$ language plpgsql






DROP Function ingreso_tratamiento( nombre_trat varchar(255),precio_trat float,descripcion_trat varchar(25),datos_prod json);

select ingreso_tratamiento('tratamiento de prueba',25.45,'tratamiento de prueba','[{ "id": 1, "cantidad":2 }, { "id": 2, "cantidad":8 }]');

