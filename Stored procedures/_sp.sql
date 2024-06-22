DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_stock`(
    IN p_idproducto INT,
    IN p_stock_actualizado INT
)
BEGIN
    UPDATE `producto`
    SET `stock` = p_stock_actualizado
    WHERE `idproducto` = p_idproducto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_venta`(
    IN p_idcliente INT,
    IN p_idempleado INT,
    IN p_idimpuesto INT,
    IN p_idcomprobante INT,
    IN p_monto DECIMAL(11,2),
    IN p_estado ENUM('completada', 'cancelada', 'en proceso'),
    IN p_metodo_de_pago ENUM('efectivo', 'credito', 'debito', 'cuenta corriente', 'transferencia bancaria'),
    IN p_cantidad SMALLINT,
    IN p_descuento DECIMAL(11,2),
    IN p_cantidad_devuelta INT,
    IN p_estado_devolucion VARCHAR(100)
)
BEGIN
    INSERT INTO `venta` (
        `idcliente`,
        `idempleado`,
        `idimpuesto`,
        `idcomprobante`,
        `monto`,
        `estado`,
        `metodo_de_pago`,
        `cantidad`,
        `descuento`,
        `cantidad_devuelta`,
        `estado_devolucion`
    )
    VALUES (
        p_idcliente,
        p_idempleado,
        p_idimpuesto,
        p_idcomprobante,
        p_monto,
        p_estado,
        p_metodo_de_pago,
        p_cantidad,
        p_descuento,
        p_cantidad_devuelta,
        p_estado_devolucion
    );
END$$

DELIMITER ;
