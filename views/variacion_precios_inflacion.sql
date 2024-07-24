CREATE VIEW variacion_precios_inflacion AS
SELECT 
    p.idproducto,
    p.titulo,
    p.precio_venta,
	p.precio_venta * (1 + i.tasa_mensual / 100) AS precio_ajustado_inflacion,
    t.fecha AS fecha_tipo_cambio,
    t.tasa AS tipo_cambio_tasa,
    i.fecha AS fecha_inflacion,
    i.tasa_mensual AS inflacion_tasa,
	h.comentario
FROM 
    historial_precios h
INNER JOIN 
    producto p ON h.idproducto = p.idproducto
INNER JOIN 
    tipo_cambio t ON h.id_tipo_cambio = t.id_tipo_cambio
INNER JOIN 
    inflacion i ON h.id_inflacion = i.id_inflacion;
