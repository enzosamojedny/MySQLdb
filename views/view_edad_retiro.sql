CREATE VIEW `view_edad_retiro` AS
SELECT 
    nombre_completo(p.nombre, p.apellido) AS Nombre,
    e.cargo AS Cargo,
    e.salario AS Salario,
    obtener_antiguedad(e.fecha_contratacion) AS Antiguedad,
    obtener_edad(p.fecha_nacimiento) AS Edad,
    e.estado AS Estado
FROM 
    empleado e
INNER JOIN 
    persona p ON e.idpersona = p.idpersona;