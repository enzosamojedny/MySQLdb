select idventa,nombre_de_empleado(e.idpersona) AS 'Vendedor',
metodo_de_pago,v.estado,cantidad,monto from venta v
INNER JOIN empleado e ON e.idempleado = v.idempleado
ORDER BY v.monto DESC, v.cantidad ASC
LIMIT 10


