CREATE OR REPLACE FUNCTION create_or_update_equipo(id_eq int8, nombre_eq varchar(255),descripcion_eq varchar(255),precio_unitario_eq float8, marca_eq varchar(255),observacion_eq varchar(255), estado_eq enum_equipos_estado, stock_eq integer) RETURNS boolean AS
$$
DECLARE
	stock_actual integer:=0;
	exist_insumos integer:=0;
	exist_instrumentos integer:=0;
	sum_existen integer = 0;
BEGIN
	Select count(id_producto) INTO exist_insumos FROM insumos WHERE id_producto=id_eq;
	Select count(id_producto) INTO exist_instrumentos FROM instrumentos WHERE id_producto=id_eq;
	sum_existen:=exist_insumos+exist_instrumentos;
	IF sum_existen = 0 THEN
		SELECT stock INTO stock_actual FROM equipos WHERE id_producto = id_eq;
		INSERT INTO productos (id, nombre, descripcion, precio_unitario, categoria, fecha_creacion, fecha_actualizacion) 
		VALUES (id_eq, nombre_eq, descripcion_eq, precio_unitario_eq, 'Equipo',CURRENT_DATE,CURRENT_DATE)
		ON CONFLICT (id) DO UPDATE 
  		SET nombre = nombre_eq, descripcion = descripcion_eq,precio_unitario=precio_unitario_eq, fecha_actualizacion= CURRENT_DATE;
			
		INSERT INTO equipos (id_producto, marca, observacion, estado, stock) 
		VALUES (id_eq, marca_eq, observacion_eq, estado_eq, stock_eq)
		ON CONFLICT (id_producto) DO UPDATE 
  		SET marca = marca_eq, observacion = observacion_eq, estado=estado_eq, stock=stock_actual+stock_eq;
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
	exception 
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
end;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION create_or_update_insumo(id_in int8, nombre_in varchar(255), descripcion_in varchar(255),precio_unitario_in float8,fecha_caducidad_in date, stock_in integer) RETURNS boolean AS
$$
DECLARE
	stock_actual integer:=0;
	exist_equipos integer:=0;
	exist_instrumentos integer:=0;
	sum_existen integer = 0;
BEGIN
	Select count(id_producto) INTO exist_equipos FROM equipos WHERE id_producto=id_in;
	Select count(id_producto) INTO exist_instrumentos FROM instrumentos WHERE id_producto=id_in;
	sum_existen:=exist_equipos+exist_instrumentos;
	IF sum_existen = 0 THEN
		SELECT stock INTO stock_actual FROM insumos WHERE id_producto = id_in;
		INSERT INTO productos (id, nombre, descripcion, precio_unitario, categoria, fecha_creacion, fecha_actualizacion ) 
		VALUES (id_in, nombre_in, descripcion_in, precio_unitario_in, 'Insumo',CURRENT_DATE,CURRENT_DATE)
		ON CONFLICT (id) DO UPDATE 
  		SET nombre = nombre_in, descripcion = descripcion_in, precio_unitario=precio_unitario_in, fecha_actualizacion=CURRENT_DATE;
				
		INSERT INTO insumos (id_producto,fecha_caducidad,stock) 
		VALUES (id_in, fecha_caducidad_in, stock_in)
		ON CONFLICT (id_producto) DO UPDATE 
  		SET fecha_caducidad = fecha_caducidad_in, stock=stock_actual+stock_in;
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;
	EXCEPTION
    WHEN OTHERS THEN
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
	
end;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION create_or_update_instrumento(id_ins int8, nombre_ins varchar(255), descripcion_ins varchar(255),precio_unitario_ins float8, observacion_ins varchar(255), estado_ins enum_instrumentos_estado, stock_ins integer) RETURNS boolean AS
$$
DECLARE
	stock_actual integer:=0;
	exist_equipos integer:=0;
	exist_insumos integer:=0;
	sum_existen integer = 0;
BEGIN
	Select count(id_producto) INTO exist_equipos FROM equipos WHERE id_producto=id_ins;
	Select count(id_producto) INTO exist_insumos FROM insumos WHERE id_producto=id_ins;
	sum_existen:=exist_equipos+exist_insumos;
	IF sum_existen = 0 THEN
		SELECT stock INTO stock_actual FROM instrumentos WHERE id_producto = id_ins;
		INSERT INTO productos (id, nombre, descripcion, precio_unitario, categoria, fecha_creacion, fecha_actualizacion ) 
		VALUES (id_ins, nombre_ins, descripcion_ins, precio_unitario_ins, 'Instrumento',CURRENT_DATE,CURRENT_DATE)
		ON CONFLICT (id) DO UPDATE 
  		SET nombre = nombre_ins, descripcion = descripcion_ins, precio_unitario=precio_unitario_ins,fecha_actualizacion=CURRENT_DATE;
				
		INSERT INTO instrumentos(id_producto,observacion,estado,stock) 
		VALUES (id_ins,observacion_ins,estado_ins, stock_ins)
		ON CONFLICT (id_producto) DO UPDATE 
  		SET observacion=observacion_ins, estado=estado_ins,stock = stock_actual+stock_ins;
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;
	EXCEPTION
    WHEN OTHERS THEN
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
		RETURN FALSE;
end;
$$ language plpgsql;


DROP FUNCTION create_or_update_equipo(id_eq int8, nombre_eq varchar(255),descripcion_eq varchar(255),precio_unitario_eq float8, marca_eq varchar(255),observacion_eq varchar(255), estado_eq enum_equipos_estado, stock_eq integer);
DROP FUNCTION create_or_update_insumo(id_in int8, nombre_in varchar(255), descripcion_in varchar(255),precio_unitario_in float8,fecha_caducidad_in date, stock_in integer);
DROP FUNCTION create_or_update_instrumento(id_ins int8, nombre_ins varchar(255), descripcion_ins varchar(255),precio_unitario_ins float8, observacion_ins varchar(255), estado_ins enum_instrumentos_estado, stock_ins integer);


SELECT create_or_update_equipo(1, 'Equipo de prueba','No existe descripción',52.45, 'Honda','No existe observación', 'Buen estado', 200);
SELECT create_or_update_insumo(2, 'Insumo de prueba', 'No existe descripción',25.68,'22-05-2019', 10);
SELECT create_or_update_instrumento(5, 'Insumo de prueba', 'No existe descripción',25.68, 'No existe observación', 'Buen estado', 100)


SELECT * FROM equipos JOIN productos ON productos.id = equipos.id_producto;
SELECT * FROM insumos JOIN productos ON productos.id = insumos.id_producto;
SELECT * FROM instrumentos JOIN productos ON productos.id = instrumentos.id_producto;