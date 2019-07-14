
--Función para crear un tratamiento con los productos
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


--Con esta funcion se resta del stock todos los productos que son necesarios para el tratamiento
--esto es debido a que talves otro doctor quiera hacer el mismo tratamiento pero si no cuenta con lo necesario
--no va a poder hacer y este sera notificado que no puede realizar tal tratamiento.
CREATE OR REPLACE FUNCTION inicia_tratamiento(id_tratamiento_trat integer) RETURNS boolean AS
$$
DECLARE
	rec record;
BEGIN
	FOR rec IN SELECT id_producto,stock,cantidad_producto FROM tratamiento_productos JOIN productos ON productos.id = tratamiento_productos.id_producto JOIN tratamientos ON tratamiento_productos.id_tratamiento=tratamientos.id WHERE id_tratamiento=id_tratamiento_trat
  	LOOP
		IF rec.stock - rec.cantidad_producto>-1 THEN
			UPDATE productos SET stock = rec.stock - rec.cantidad_producto WHERE id=rec.id_producto;
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
$$ language plpgsql;



--Función que permite finalizar un tratamiento, esto es debido a que este cuando se haya terminado ya los instrumentos y productos se deben 
--de devolver al estante y otro doctor o odontologo podra hacer uso de ello.

CREATE OR REPLACE FUNCTION termina_tratamiento(id_tratamiento_trat integer, desechados integer[]) RETURNS boolean AS
$$
DECLARE
	rec record;
BEGIN
	FOR rec IN SELECT id_producto::integer,stock,cantidad_producto FROM tratamiento_productos JOIN productos ON productos.id = tratamiento_productos.id_producto WHERE id_tratamiento=id_tratamiento_trat
  	LOOP
		IF NOT (SELECT rec.id_producto = ANY (desechados::int[])) THEN
			UPDATE productos SET stock = rec.stock + rec.cantidad_producto WHERE id=rec.id_producto;
		END IF;
	END LOOP;
	RETURN TRUE;
	EXCEPTION
    WHEN OTHERS THEN
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
	RETURN TRUE;
END;
$$ language plpgsql;


--Para borrar las funciones y bajar la base de datos del servidor
DROP Function inicia_tratamiento(id_tratamiento_trat integer);
DROP Function termina_tratamiento(id_tratamiento_trat integer, desechados integer[]);
DROP Function ingreso_tratamiento( nombre_trat varchar(255),precio_trat float,descripcion_trat varchar(25),datos_prod json);


