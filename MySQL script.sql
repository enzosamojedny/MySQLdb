CREATE TABLE `producto_vendido_devolucion` (
  `idproducto_vendido_devolucion` SMALLINT PRIMARY KEY,
  `idventa` SMALLINT NOT NULL,
  `idcomprobante` SMALLINT,
  `cantidad_devuelta` SMALLINT NOT NULL,
  `estado_devolucion` varchar(20) NOT NULL
);
CREATE TABLE `categoria` (
  `idcategoria` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(50) UNIQUE NOT NULL,
  `descripcion` varchar(256),
  `estado` bit DEFAULT 1
);
CREATE TABLE `producto` (
  `idproducto` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idcategoria` SMALLINT NOT NULL,
  `iddetalle_ingreso_producto` SMALLINT NOT NULL, -- el producto que ingreso de proveedores
  `titulo` varchar(100) UNIQUE NOT NULL,
  `descripcion` varchar(256),
  `codigo` varchar(20),
  `stock` SMALLINT NOT NULL,
  -- hay una relacion con venta_producto
  `thumbnail` varchar(256),
  `images` JSON, -- un array de imagenes
  `idcategoria_default` SMALLINT, -- no se bien que hace esto
  `rating` tinyint,
  `estado` varchar(20), -- bit DEFAULT 1
  FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`)
);

-- tabla intermedia entre producto y categoria
CREATE TABLE `producto_categoria` (
  `idproducto_categoria` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idproducto` SMALLINT NOT NULL,
  `idcategoria` SMALLINT NOT NULL,
  FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`),
  FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`)
);

CREATE TABLE `detalle_ingreso_producto` ( -- seria la mercaderia que ingresa desde el proveedor
  `iddetalle_ingreso_producto` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idproducto` SMALLINT NOT NULL,
  `idproveedor` SMALLINT NOT NULL,
  `idimpuesto` SMALLINT NOT NULL, -- cuando compras, pagas impuesto tmb
  `idcomprobante` SMALLINT,
  `cantidad` TINYINT NOT NULL,
  `precio_compra` decimal(11,2) NOT NULL,
  `impuesto` decimal(4,2),
  `total` decimal(11,2) NOT NULL,
  `estado` varchar(20) NOT NULL -- si ingreso o no, supongo?
);
CREATE TABLE `comprobante`(
  `idcomprobante` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `num_comprobante` SMALLINT not null,
  `descripcion_comprobante` varchar(256) not null,
  `fecha_emision` datetime,
  `fecha_vencimiento` datetime,
  `estado` varchar(20),
  `fecha_modificacion` datetime
);
CREATE TABLE `venta` (
  `idventa` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idcliente` SMALLINT NOT NULL,
  `idempleado` SMALLINT, -- id del empleado que hizo la venta, puede ser null si se vendio virtual, por ej
  `idimpuesto` SMALLINT NOT NULL, -- impuesto pagado cuando vendes un producto (iva, retencion MP y cosas varias, supongo)
  `idcomprobante` SMALLINT,
  `monto` decimal(11,2) NOT NULL,
  `estado` varchar(20) NOT NULL,
  `metodo_de_pago` varchar(100) NOT NULL
);

CREATE TABLE `impuesto` (
  `idimpuesto` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idcomprobante` SMALLINT,
  `nombre` varchar(50) NOT NULL,
  `tipo_impuesto` varchar(50) NOT NULL,
  `tasa` decimal(11,2) NOT NULL,
  `descripcion` text
);

CREATE TABLE `proveedor` (
  `idproveedor` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `id_detalle_ingreso_producto` SMALLINT NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `tipo_documento` varchar(20),
  `num_documento` varchar(20),
  `direccion` varchar(70),
  `pais` varchar(50),
  `provincia` varchar(20),
  `telefono` varchar(20),
  `email` varchar(50),
  `estado` bit DEFAULT 1 -- activo - inactivo
);

CREATE Table `persona` (
  `idpersona` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idrol` SMALLINT not null,
  `idempleado` SMALLINT not null,
  `iddireccion` SMALLINT,
  `nombre` varchar(50) not null,
  `apellido` varchar(50) not null,
  `tipo_documento` varchar(20),
  `num_documento` varchar(20),
  `telefono` varchar(20),
  `email` varchar(50) not null,
  `password` varchar(30) not null,
  `estado` bit default 1, -- activo - inactivo
  `pais` varchar(50),
  `provincia` varchar(20),
  `fecha_nacimiento` datetime,
  `genero` bit DEFAULT 1
);

CREATE Table `direccion` (
  `iddireccion` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idpersona` SMALLINT, -- relacion con persona y eso
  `direccion1` varchar(50),
  `direccion2` varchar(50),
  `codigo_postal` varchar(30),
  `ciudad` varchar(30),
  `provincia` varchar(30),
  `pais` varchar(30),
  `fecha_modificacion` datetime 
);

CREATE TABLE `rol` (
  `idrol` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL,
  `descripcion` varchar(200),
  `estado` bit DEFAULT 1
);

CREATE TABLE `cliente` (
  `idcliente` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idproducto_vendido_devolucion` SMALLINT,
  `idventa` SMALLINT DEFAULT null, -- el cliente hace una compra, apunta a la tabla VENTAS con toda la info
  `idpersona` SMALLINT NOT NULL,
  `cantidad_devuelta` SMALLINT NOT NULL,
  `estado_devolucion` varchar(50) NOT NULL,
  `estado` bit DEFAULT 1 -- activo - inactivo
);

CREATE TABLE `empleado` (
  `idempleado` SMALLINT PRIMARY KEY AUTO_INCREMENT,
  `idpersona` SMALLINT NOT NULL, -- te trae quien es la persona de la tabla personas
  `cargo` varchar(50),
  `salario` decimal(11,2),
  `horas_trabajadas` SMALLINT,
  `fecha_contratacion` datetime,
  `estado` bit DEFAULT 1
);

-- tabla intermedia entre venta y producto
CREATE TABLE `venta_producto` (
  `idventa` SMALLINT NOT NULL,
  `idproducto` SMALLINT NOT NULL,
  `cantidad` SMALLINT NOT NULL,
  `precio_venta` decimal(11,2) NOT NULL,
  `descuento` decimal(11,2) NOT NULL,
  PRIMARY KEY (`idventa`, `idproducto`),
  CONSTRAINT `fk_venta_idventa` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`),
  CONSTRAINT `fk_producto_idproducto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`)
);

ALTER TABLE `producto_vendido_devolucion` ADD FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`);
ALTER TABLE `producto_vendido_devolucion` ADD FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`);
ALTER TABLE `impuesto` ADD FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`);
ALTER TABLE `detalle_ingreso_producto` ADD FOREIGN KEY (`idproveedor`) REFERENCES `proveedor` (`idproveedor`);
ALTER TABLE `detalle_ingreso_producto` ADD FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`);
ALTER TABLE `detalle_ingreso_producto` ADD FOREIGN KEY (`idimpuesto`) REFERENCES `impuesto` (`idimpuesto`);
ALTER TABLE `detalle_ingreso_producto` ADD FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`);
ALTER TABLE `venta` ADD FOREIGN KEY (`idempleado`) REFERENCES `empleado` (`idempleado`);
ALTER TABLE `venta` ADD FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`);
ALTER TABLE `venta` ADD FOREIGN KEY (`idimpuesto`) REFERENCES `impuesto` (`idimpuesto`);
ALTER TABLE `venta` ADD FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`);
ALTER TABLE `persona` ADD FOREIGN KEY (`idrol`) REFERENCES `rol` (`idrol`);
ALTER TABLE `persona` ADD FOREIGN KEY (`iddireccion`) REFERENCES `direccion` (`iddireccion`);
ALTER TABLE `empleado` ADD FOREIGN KEY (`idpersona`) REFERENCES `persona` (`idpersona`);
ALTER TABLE `cliente` ADD FOREIGN KEY (`idpersona`) REFERENCES `persona` (`idpersona`);
ALTER TABLE `cliente` ADD FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`);
-- tabla intermedia producto-categoria
ALTER TABLE `producto`
ADD CONSTRAINT `fk_idcategoria_default` FOREIGN KEY (`idcategoria_default`) REFERENCES `categoria` (`idcategoria`);
