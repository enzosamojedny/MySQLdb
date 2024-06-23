DELIMITER $$

CREATE FUNCTION nombre_completo(nombre VARCHAR(100), apellido VARCHAR(100))
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    RETURN CONCAT(nombre, ' ', apellido);
END$$

CREATE FUNCTION obtener_antiguedad(fecha_contratacion DATETIME)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_contratacion, CURDATE());
END$$

CREATE FUNCTION obtener_edad(fecha_nacimiento DATETIME)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END$$

CREATE FUNCTION `nombre_de_empleado`(var_idpersona INT ) RETURNS varchar(200)
    READS SQL DATA
BEGIN
DECLARE persona_empleado VARCHAR(200);
SELECT nombre_completo(p.nombre,p.apellido) 
INTO persona_empleado
FROM persona p
INNER JOIN empleado e
WHERE p.idpersona = var_idpersona
LIMIT 1;
RETURN persona_empleado;
END$$

DELIMITER ;
