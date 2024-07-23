CREATE TABLE `auditoria`(
  `idAuditoria` INT PRIMARY KEY AUTO_INCREMENT,
  `descripcion` VARCHAR(60),
  `tipo_cambio_realizado` VARCHAR(256),
  `fecha_cambio` DATETIME,
  `responsable_cambio` VARCHAR(50)
);
CREATE TABLE `categoria` (
  `idcategoria` INT PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(100) UNIQUE NOT NULL,
  `descripcion` VARCHAR(256),
  `estado` BIT DEFAULT 1
);
CREATE TABLE `proveedor` (
  `idproveedor` INT PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `razon_social` VARCHAR(100) NOT NULL,
  `tipo_documento` VARCHAR(20),
  `num_documento` VARCHAR(50),
  `direccion` VARCHAR(100),
  `pais` VARCHAR(100),
  `provincia` VARCHAR(100),
  `telefono` VARCHAR(100),
  `email` VARCHAR(50),
  `estado` ENUM('activo', 'inactivo') NOT NULL
);
CREATE TABLE `comprobante`(
  `idcomprobante` INT PRIMARY KEY AUTO_INCREMENT,
  `num_comprobante` DECIMAL(12, 0) NOT NULL,
  `descripcion_comprobante` VARCHAR(256) NOT NULL,
  `fecha_emision` DATETIME,
  `fecha_vencimiento` DATETIME,
  `estado` ENUM('pago', 'impago') NOT NULL,
  `condicion_IVA` VARCHAR(100),
  `fecha_modificacion` DATETIME
);
CREATE TABLE `impuesto` (
  `idimpuesto` INT PRIMARY KEY AUTO_INCREMENT,
  `idcomprobante` INT,
  `nombre` VARCHAR(50) NOT NULL,
  `tipo_impuesto` VARCHAR(50) NOT NULL,
  `tasa` DECIMAL(11,2) NOT NULL,
  `descripcion` TEXT,
  `estado` ENUM('pago', 'impago', 'pendiente', 'vencido') NOT NULL,
  FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`)
);

CREATE TABLE `detalle_ingreso_mercaderia` (
  `iddetalle_ingreso_mercaderia` INT PRIMARY KEY AUTO_INCREMENT,
  `idproveedor` INT NOT NULL,
  `idimpuesto` INT NOT NULL,
  `idcomprobante` INT,
  `codigo_producto` VARCHAR(50),
  `descripcion_producto` TEXT,
  `cantidad` INT NOT NULL,
  `precio_compra` DECIMAL(11,2) NOT NULL,
  `total` DECIMAL(11,2) NOT NULL,
  `estado` ENUM('en stock', 'sin stock') NOT NULL,
  `fecha_ingreso` DATETIME,
  `fecha_vencimiento` DATE,
  `lote_o_serie` VARCHAR(50),
  `condicion_almacenamiento` VARCHAR(100),
  `notas` TEXT,
  `categoria_producto` VARCHAR(50),
  `marca` VARCHAR(50),
  `sku` VARCHAR(50), -- Número de referencia interno utilizado para la gestión de inventarios.
  `fecha_fabricacion` DATE,
  `pais_origen` VARCHAR(100),
  FOREIGN KEY (`idproveedor`) REFERENCES `proveedor` (`idproveedor`),
  FOREIGN KEY (`idimpuesto`) REFERENCES `impuesto` (`idimpuesto`),
  FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`)
);

CREATE TABLE `producto` (
  `idproducto` INT PRIMARY KEY AUTO_INCREMENT,
  `idcategoria` INT NOT NULL,
  `iddetalle_ingreso_mercaderia` INT NOT NULL,
  `titulo` VARCHAR(100) UNIQUE NOT NULL,
  `descripcion` VARCHAR(256),
  `codigo_producto` VARCHAR(50),
  `stock` INT NOT NULL,
  `thumbnail` VARCHAR(256),
  `images` JSON,
  `idcategoria_default` INT, -- could be used for tagging default category among many
  `rating` TINYINT,
  `estado` ENUM('en stock', 'sin stock') NOT NULL,
  FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`),
  FOREIGN KEY (`idcategoria_default`) REFERENCES `categoria` (`idcategoria`)
);

CREATE TABLE `rol` (
  `idrol` INT PRIMARY KEY AUTO_INCREMENT,
  `nombre` VARCHAR(300) NOT NULL,
  `descripcion` VARCHAR(300),
  `estado` ENUM('activo', 'inactivo') NOT NULL
);
CREATE TABLE `persona` (
  `idpersona` INT PRIMARY KEY AUTO_INCREMENT,
  `idrol` INT NOT NULL,
  `nombre` VARCHAR(100) NOT NULL,
  `apellido` VARCHAR(100) NOT NULL,
  `tipo_documento` VARCHAR(20),
  `num_documento` VARCHAR(50),
  `telefono` VARCHAR(50),
  `email` VARCHAR(50) NOT NULL,
  `password` VARCHAR(30) NOT NULL,
  `pais` VARCHAR(100),
  `provincia` VARCHAR(100),
  `ciudad` VARCHAR(100),
  `direccion1` VARCHAR(50),
  `direccion2` VARCHAR(50),
  `codigo_postal` VARCHAR(30),
  `fecha_nacimiento` DATETIME,
  `fecha_modificacion` DATETIME,
  `genero` BIT DEFAULT 1,
  FOREIGN KEY (`idrol`) REFERENCES `rol` (`idrol`)
);
CREATE TABLE `cliente` (
  `idcliente` INT PRIMARY KEY AUTO_INCREMENT,
  `idpersona` INT NOT NULL,
  `cantidad_devuelta` INT DEFAULT NULL,
  `motivo_devolucion` VARCHAR(256) DEFAULT NULL,
  `estado_devolucion` VARCHAR(50) DEFAULT NULL,
  `notificaciones_activas` BOOLEAN DEFAULT true,
  `fecha_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `estado` ENUM('activo', 'inactivo','borrado') NOT NULL,
  `ultima_visita_sitio` DATETIME,
  `ultima_compra` DATE,
  `metodo_pago_preferido` VARCHAR(100),
  `total_compras` INT DEFAULT 0,
  `puntos_cliente` INT DEFAULT 0,
   FOREIGN KEY (`idpersona`) REFERENCES `persona` (`idpersona`)
);
CREATE TABLE `empleado` (
  `idempleado` INT PRIMARY KEY AUTO_INCREMENT,
  `idpersona` INT NOT NULL, -- te trae quien es la persona de la tabla personas
  `cargo` VARCHAR(50),
  `salario` decimal(11,2),
  `horas_trabajadas` INT,
  `fecha_contratacion` DATETIME,
  `estado` ENUM('activo', 'inactivo') NOT NULL,
   FOREIGN KEY (`idpersona`) REFERENCES `persona` (`idpersona`)
);
CREATE TABLE `venta` (
  `idventa` INT PRIMARY KEY AUTO_INCREMENT,
  `idcliente` INT DEFAULT NULL,
  `idempleado` INT DEFAULT NULL,
  `idimpuesto` INT NOT NULL, 
  `idcomprobante` INT DEFAULT NULL,
  `descripcion` VARCHAR(256) NOT NULL,
  `monto` decimal(11,2) NOT NULL,
  `estado` ENUM('completada', 'cancelada','en proceso') NOT NULL,
  `metodo_de_pago` ENUM('efectivo', 'credito','debito', 'cuenta corriente', 'transferencia bancaria') NOT NULL,
  `cantidad` SMALLINT NOT NULL,
  `descuento` decimal(11,2) NOT NULL,
  `cantidad_devuelta` INT DEFAULT NULL,
  `estado_devolucion` VARCHAR(100) DEFAULT NULL,
  FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`),
  FOREIGN KEY (`idempleado`) REFERENCES `empleado` (`idempleado`),
  FOREIGN KEY (`idimpuesto`) REFERENCES `impuesto` (`idimpuesto`),
  FOREIGN KEY (`idcomprobante`) REFERENCES `comprobante` (`idcomprobante`)
);
-- -----------------------------------------------------------------------------------------------------
-- TABLAS FINANCIERAS DE LA EMPRESA


CREATE TABLE `tipo_cambio` (
    `id_tipo_cambio` INT PRIMARY KEY AUTO_INCREMENT,
    `fecha` DATETIME NOT NULL,
    `moneda` VARCHAR(3) NOT NULL, -- ISO 4217 codigo de moneda (ej, USD, EUR, ARS, AUD)
    `tasa` DECIMAL(10, 4) NOT NULL  -- cambio contra moneda principal (ARS)
);
CREATE TABLE `inflacion` ( -- tomo valores EOD (fin del día)
    `id_inflacion` INT PRIMARY KEY AUTO_INCREMENT,
    `fecha` DATE NOT NULL,
    `tasa_mensual` DECIMAL(5, 2) NOT NULL,
    -- tasa son opcionales, puedo calcular la tasa en un _sp y hacer una formula de calculo de tasa quizas
    -- solo tengo que tener datos necesarios para las formulas
    `TNA` DECIMAL(5, 2) NOT NULL,
    `TEA` DECIMAL(5, 2) NOT NULL,  -- en %
    `tipo_indice` ENUM('CER', 'UVA', 'CVS') NOT NULL,  -- cvs = variacion salarios
    `comentario` VARCHAR(256) 
);
CREATE TABLE `historial_precios` (
    `id_historial_precio` INT PRIMARY KEY AUTO_INCREMENT,
    `idproducto` INT NOT NULL,
    `precio` DECIMAL(10, 2) NOT NULL,
    `comentario` VARCHAR(256),
    `id_tipo_cambio` INT,  -- ref a tipo_de_cambio
    `id_inflacion` INT,  -- ref a inflacion
    FOREIGN KEY (`idproducto`) REFERENCES `producto`(`idproducto`),
    FOREIGN KEY (`id_tipo_cambio`) REFERENCES `tipo_cambio`(`id_tipo_cambio`),
    FOREIGN KEY (`id_inflacion`) REFERENCES `inflacion`(`id_inflacion`)
);
CREATE TABLE `rentabilidad` (
    `id_rentabilidad` INT PRIMARY KEY AUTO_INCREMENT,
    `idproducto` INT NOT NULL,
    `idventa` INT NOT NULL,
    `fecha` DATE NOT NULL,
    `ingresos_totales` DECIMAL(10, 2) NOT NULL,  -- Ganancia de cada venta
    `gastos` DECIMAL(10, 2) NOT NULL, 
    `ingresos_netos` DECIMAL(10, 2) AS (`ingresos_totales` - `gastos`) STORED,
    `id_tipo_cambio` INT,
    `id_inflacion` INT,
    FOREIGN KEY (`idproducto`) REFERENCES `producto`(`idproducto`),
    FOREIGN KEY (`idventa`) REFERENCES `venta`(`idventa`),
    FOREIGN KEY (`id_tipo_cambio`) REFERENCES `tipo_cambio`(`id_tipo_cambio`),
    FOREIGN KEY (`id_inflacion`) REFERENCES `inflacion`(`id_inflacion`)
);
-- -----------------------------------------------------------------------------------------------------

-- TABLAS INTERMEDIAS (MANY-TO-MANY)
-- tabla intermedia entre venta y producto
CREATE TABLE `venta_producto` (
  `idventa` INT NOT NULL,
  `idproducto` INT NOT NULL,
  PRIMARY KEY (`idventa`, `idproducto`),
  CONSTRAINT `fk_venta_idventa` FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`),
  CONSTRAINT `fk_producto_idproducto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`)
);
-- tabla intermedia entre proveedor y producto
CREATE TABLE `producto_a_detalle_ingreso` (
  `idproducto` INT NOT NULL,
  `iddetalle_ingreso_mercaderia` INT NOT NULL,
  PRIMARY KEY (`idproducto`, `iddetalle_ingreso_mercaderia`),
  FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`),
  FOREIGN KEY (`iddetalle_ingreso_mercaderia`) REFERENCES `detalle_ingreso_mercaderia` (`iddetalle_ingreso_mercaderia`)
);
-- tabla intermedia entre empleado y ventas
CREATE TABLE `empleado_a_ventas`(
  `idempleado` INT NOT NULL,
  `idventa` INT NOT NULL,
  PRIMARY KEY (`idempleado`, `idventa`),
  FOREIGN KEY (`idempleado`) REFERENCES `empleado` (`idempleado`),
  FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`)
);
CREATE TABLE `ventas_a_clientes`(
  `idventa` INT NOT NULL,
  `idcliente` INT NOT NULL,
  PRIMARY KEY (`idventa`, `idcliente`),
  FOREIGN KEY (`idventa`) REFERENCES `venta` (`idventa`),
  FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idcliente`)
);
CREATE TABLE `producto_a_proveedor` (
  `idproducto` INT NOT NULL,
  `idproveedor` INT NOT NULL,
  PRIMARY KEY (`idproducto`, `idproveedor`),
  FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`),
  FOREIGN KEY (`idproveedor`) REFERENCES `proveedor` (`idproveedor`)
);
CREATE TABLE `categorias_a_producto` (
  `idcategoria` INT NOT NULL,
  `idproducto` INT NOT NULL,
  PRIMARY KEY (`idcategoria`, `idproducto`),
  FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`),
  FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`)
);
INSERT INTO rol (nombre, descripcion, estado) 
VALUES
    ('Cliente', 'Representa a individuos que interactúan con la organización como clientes.', 'activo'),
    ('Empleado', 'Se refiere a miembros del personal que trabajan dentro de la organización.', 'inactivo'),
    ('Supervisor', 'Supervisa y gestiona el trabajo de los empleados dentro de un departamento o área específica.', 'activo'),
    ('Personal de Limpieza', 'Responsable de mantener la limpieza e higiene dentro de las instalaciones de la organización.', 'inactivo'),
    ('Gerente', 'Ocupa un puesto gerencial responsable de supervisar un departamento o equipo específico y tomar decisiones estratégicas.', 'activo'),
    ('Administrador', 'Se encarga de tareas administrativas como llevar registros, documentación y coordinación de recursos dentro de la organización.', 'inactivo'),
    ('Técnico', 'Realiza tareas técnicas relacionadas con el mantenimiento, reparación o instalación de equipos.', 'activo'),
    ('Vendedor', 'Se encarga de vender productos o servicios a los clientes, gestionar consultas y procesar transacciones.', 'inactivo'),
    ('Recepcionista', 'Recibe a los visitantes, atiende llamadas entrantes, gestiona citas y brinda apoyo administrativo en la recepción.', 'activo'),
    ('Analista', 'Analiza datos, tendencias del mercado o procesos operativos para proporcionar ideas y recomendaciones para la toma de decisiones dentro de la organización.', 'inactivo'),
    ('Consultor', 'Proporciona asesoramiento experto en un área específica para ayudar a la organización a resolver problemas o mejorar su desempeño.', 'activo'),
    ('Contador', 'Se encarga de llevar registros financieros, preparar informes y garantizar el cumplimiento de las obligaciones fiscales y contables.', 'inactivo'),
    ('Desarrollador', 'Diseña, desarrolla y mantiene aplicaciones de software para satisfacer las necesidades de la organización.', 'activo'),
    ('Diseñador', 'Crea diseños gráficos, visuales y de experiencia de usuario para productos y materiales de marketing de la organización.', 'inactivo'),
    ('Entrenador', 'Proporciona entrenamiento y desarrollo profesional a los empleados para mejorar sus habilidades y desempeño laboral.', 'activo'),
    ('Especialista en Recursos Humanos', 'Gestiona funciones de recursos humanos como contratación, capacitación, evaluación del desempeño y resolución de conflictos.', 'inactivo'),
    ('Investigador', 'Conduce investigaciones y estudios para obtener información relevante y contribuir al conocimiento en un campo específico.', 'activo'),
    ('Ingeniero', 'Diseña, desarrolla y mantiene sistemas y estructuras físicas para satisfacer las necesidades de la organización.', 'inactivo'),
    ('Marketing', 'Desarrolla estrategias de marketing, promociona productos o servicios y gestiona la relación con los clientes para aumentar las ventas.', 'activo'),
    ('Logística', 'Gestiona el flujo de productos y materiales desde la adquisición hasta la entrega final, garantizando eficiencia y satisfacción del cliente.', 'inactivo'),
    ('Soporte Técnico', 'Brinda asistencia técnica y resuelve problemas relacionados con productos o servicios de la organización.', 'activo'),
    ('Abogado', 'Proporciona asesoramiento legal y representa los intereses legales de la organización en asuntos legales y judiciales.', 'inactivo'),
    ('Auditor', 'Realiza auditorías internas para evaluar el cumplimiento de políticas, procedimientos y regulaciones dentro de la organización.', 'activo'),
    ('Compras', 'Se encarga de adquirir productos, materiales o servicios necesarios para el funcionamiento de la organización.', 'inactivo'),
    ('Especialista en Seguridad', 'Implementa medidas de seguridad física y cibernética para proteger los activos y la información de la organización.', 'activo'),
    ('Instructor', 'Imparte capacitación y desarrollo profesional en áreas específicas para mejorar las habilidades y competencias de los empleados.', 'inactivo'),
    ('Planificador Financiero', 'Desarrolla estrategias financieras y planifica la gestión de recursos para alcanzar los objetivos financieros de la organización.', 'activo'),
    ('Analista de Datos', 'Analiza grandes volúmenes de datos para extraer información relevante y proporcionar insights que impulsen la toma de decisiones.', 'inactivo'),
    ('Diseñador de Interiores', 'Crea diseños funcionales y estéticos para interiores de espacios comerciales u oficinas de la organización.', 'activo'),
    ('Especialista en Marketing Digital', 'Desarrolla y ejecuta estrategias de marketing en línea para promocionar productos o servicios y aumentar la visibilidad de la marca.', 'inactivo');
INSERT INTO proveedor (nombre, razon_social, tipo_documento, num_documento, direccion, pais, provincia, telefono, email, estado) 
VALUES
('YPF S.A.', 'YPF Sociedad Anónima', 'CUIT', '30-50000517-4', 'Av. Ing. H. Huergo 723', 'Argentina', 'Buenos Aires', '0800-1229-000', 'info@ypf.com.ar', 'activo'),
('Mercado Libre S.R.L.', 'MercadoLibre Sociedad Responsable Limitada', 'CUIT', '30-70308853-4', 'Arias 3751, 7th floor', 'Argentina', 'Buenos Aires', '+5411 4640 8000', 'info@mercadolibre.com', 'activo'),
('Telecom Argentina S.A.', 'Telecom Argentina Sociedad Anónima', 'CUIT', '30-63945345-3', 'Alicia Moreau de Justo 50', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-555-5000', 'contacto@telecom.com.ar', 'activo'),
('Total Logistics LLC', 'Total Logistics LLC', 'CUIT', '30-50000845-4', 'Av. Rivadavia 325', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0810-666-4444', 'banconacion@banconacion.com.ar', 'inactivo'),
('Toyota', 'Toyota Argentina Sociedad Anónima', 'CUIT', '30-70728594-5', 'Av. Del Libertador 350', 'Argentina', 'Buenos Aires', '0800-555-2498', 'info@toyota.com.ar', 'activo'),
('YPF Luz.', 'YPF Luz Sociedad Anónima', 'CUIT', '30-71657435-5', 'Macacha Güemes 515', 'Argentina', 'Buenos Aires', '0800-1229-000', 'info@ypfluz.com.ar', 'activo'),
('Aerolíneas Argentinas', 'Aerolíneas Argentinas Sociedad Anónima', 'CUIT', '30-64140555-4', 'Av. Rafael Obligado s/n', 'Argentina', 'Buenos Aires', '+5411 4340-7777', 'info@aerolineas.com.ar', 'activo'),
('YPF Gas', 'YPF Gas Sociedad Anónima', 'CUIT', '30-71410506-5', 'Macacha Güemes 515', 'Argentina', 'Buenos Aires', '0800-1229-000', 'info@ypfgas.com.ar', 'activo'),
('Direct Imports LLC', 'Direct Imports LLC', 'CUIT', '30-71657435-5', '111 Pine Avenue', 'United States', 'Georgia', '+1-404-555-2345', 'info@directimports.com', 'inactivo'),
('Claro Argentina', 'Claro Argentina Sociedad Anónima', 'CUIT', '30-63945345-3', 'Bouchard 710, 2nd floor', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-123-2527', 'contacto@claro.com.ar', 'activo'),
('Nestlé', 'Nestlé Argentina Sociedad Anónima', 'CUIT', '30-50000845-4', 'Florida 520, 1st floor', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-333-0333', 'info@nestle.com.ar', 'activo'),
('Petrobras', 'Petrobras Argentina Sociedad Anónima', 'CUIT', '30-63945345-3', 'Av. Libertador 4444', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-666-2378', 'contacto@petrobras.com.ar', 'activo'),
('Techint', 'Techint Compañía Técnica Internacional Sociedad Anónima Cerrada', 'CUIT', '30-50000845-4', 'Bouchard 547', 'Argentina', 'Buenos Aires', '0800-400-2444', 'info@techint.com', 'activo'),
('Telefónica', 'Telefónica Argentina Sociedad Anónima', 'CUIT', '30-71410506-5', 'Alicia M. de Justo 50', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-333-1515', 'info@telefonica.com.ar', 'inactivo'),
('Unilever', 'Unilever de Argentina Sociedad Anónima', 'CUIT', '30-71657435-5', 'Av. Del Libertador 1850', 'Argentina', 'Buenos Aires', '0800-555-6383', 'info@unilever.com.ar', 'inactivo'),
('Arcor', 'Arcor Sociedad Anónima Industrial y Comercial', 'CUIT', '30-64140555-4', 'Av. Rafael Núñez 4400', 'Argentina', 'Córdoba', '0800-333-2833', 'contacto@arcor.com.ar', 'activo'),
('Citibank', 'Citibank Argentina Sociedad Anónima', 'CUIT', '30-70728594-5', '25 de Mayo 25', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-222-2482', 'contacto@citibank.com.ar', 'activo'),
('Dow Argentina S.R.L.', 'Dow Argentina Sociedad Responsable Limitada', 'CUIT', '30-50000517-4', 'Av. Corrientes 2560', 'Argentina', 'Buenos Aires', '0800-444-3333', 'info@dow.com.ar', 'activo'),
('GlaxoSmithKline Argentina', 'GlaxoSmithKline Argentina Sociedad Anónima', 'CUIT', '30-70308853-4', 'Av. Corrientes 4151', 'Argentina', 'Buenos Aires', '0800-999-2442', 'info@gsk.com.ar', 'activo'),
('Iberia Líneas Aéreas', 'Iberia Líneas Aéreas de España Sociedad Anónima', 'CUIT', '30-63945345-3', 'Av. de Mayo 843', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '+5411 5555-8800', 'info@iberia.com.ar', 'inactivo'),
('Mitsubishi Corporation', 'Mitsubishi Corporation Sucursal Argentina', 'CUIT', '30-50000845-4', 'Av. Santa Fe 846', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '+5411 5555-9900', 'info@mitsubishi.com.ar', 'activo'),
('Nokia', 'Nokia Argentina Sociedad Anónima', 'CUIT', '30-70728594-5', 'Av. Córdoba 1138', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '+5411 5555-5500', 'info@nokia.com.ar', 'activo'),
('Novartis', 'Novartis Argentina Sociedad Anónima', 'CUIT', '30-71657435-5', 'Av. Leandro N. Alem 1050', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-555-5544', 'info@novartis.com.ar', 'inactivo'),
('Pan American Energy', 'Pan American Energy LLC Sucursal Argentina', 'CUIT', '30-64140555-4', 'Av. Leandro N. Alem 855', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '+5411 5555-4400', 'info@panenergy.com.ar', 'inactivo'),
('Pfizer', 'Pfizer Argentina Sociedad Anónima', 'CUIT', '30-70728594-5', 'Av. Eduardo Madero 942', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-555-6633', 'info@pfizer.com.ar', 'activo'),
('Procter & Gamble', 'Procter & Gamble Argentina Sociedad Responsable Limitada', 'CUIT', '30-70308853-4', 'Av. Leandro N. Alem 1050', 'Argentina', 'Ciudad Autónoma de Buenos Aires', '0800-555-9966', 'info@pg.com.ar', 'inactivo'),
('Advanced Solutions LLC', 'Advanced Solutions LLC', 'CUIT', '30-64140555-4', '999 Maple Drive', 'United States', 'Virginia', '+1-703-555-9012', 'info@advancedsolutions.com', 'activo');
INSERT INTO comprobante (num_comprobante, descripcion_comprobante, fecha_emision, fecha_vencimiento, estado, fecha_modificacion, condicion_IVA) VALUES
(100012345678, 'Factura A', '2024-01-05 10:30:00', '2024-02-05 23:59:59', 'pago', '2024-01-05 10:30:00', 'Responsable Inscripto'),
(100098765432, 'Factura B', '2024-01-15 11:45:00', '2024-02-14 23:59:59', 'pago', '2024-01-15 11:45:00', 'Exento'),
(100056789012, 'Factura C', '2024-01-20 14:20:00', '2024-02-19 23:59:59', 'pago', '2024-01-20 14:20:00', 'Monotributista'),
(100023456789, 'Factura A', '2024-01-25 09:10:00', '2024-02-24 23:59:59', 'pago', '2024-01-25 09:10:00', 'Responsable Inscripto'),
(100034567890, 'Factura B', '2024-02-01 13:15:00', '2024-03-02 23:59:59', 'impago', '2024-02-01 13:15:00', 'Exento'),
(100045678901, 'Factura C', '2024-02-10 16:25:00', '2024-03-11 23:59:59', 'impago', '2024-02-10 16:25:00', 'Monotributista'),
(100056789012, 'Factura A', '2024-02-15 08:45:00', '2024-03-17 23:59:59', 'pago', '2024-02-15 08:45:00', 'Responsable Inscripto'),
(100067890123, 'Factura B', '2024-02-20 10:50:00', '2024-03-21 23:59:59', 'impago', '2024-02-20 10:50:00', 'Exento'),
(100078901234, 'Factura C', '2024-02-25 12:00:00', '2024-03-26 23:59:59', 'pago', '2024-02-25 12:00:00', 'Monotributista'),
(100089012345, 'Factura A', '2024-03-01 15:30:00', '2024-03-31 23:59:59', 'pago', '2024-03-01 15:30:00', 'Responsable Inscripto'),
(100090123456, 'Factura B', '2024-03-05 09:05:00', '2024-04-04 23:59:59', 'impago', '2024-03-05 09:05:00', 'Exento'),
(100091234567, 'Factura C', '2024-03-10 14:35:00', '2024-04-09 23:59:59', 'impago', '2024-03-10 14:35:00', 'Monotributista'),
(100092345678, 'Factura A', '2024-03-15 11:20:00', '2024-04-14 23:59:59', 'pago', '2024-03-15 11:20:00', 'Responsable Inscripto'),
(100093456789, 'Factura B', '2024-03-20 16:40:00', '2024-04-19 23:59:59', 'pago', '2024-03-20 16:40:00', 'Exento'),
(100094567890, 'Factura C', '2024-03-25 13:55:00', '2024-04-24 23:59:59', 'impago', '2024-03-25 13:55:00', 'Monotributista'),
(100095678901, 'Factura A', '2024-04-01 10:00:00', '2024-05-01 23:59:59', 'pago', '2024-04-01 10:00:00', 'Responsable Inscripto'),
(100096789012, 'Factura B', '2024-04-05 11:30:00', '2024-05-05 23:59:59', 'impago', '2024-04-05 11:30:00', 'Exento'),
(100097890123, 'Factura C', '2024-04-10 14:45:00', '2024-05-10 23:59:59', 'pago', '2024-04-10 14:45:00', 'Monotributista'),
(100098901234, 'Factura A', '2024-04-15 09:25:00', '2024-05-15 23:59:59', 'impago', '2024-04-15 09:25:00', 'Responsable Inscripto'),
(100099012345, 'Factura B', '2024-04-20 13:00:00', '2024-05-20 23:59:59', 'pago', '2024-04-20 13:00:00', 'Exento'),
(100100123456, 'Factura C', '2024-04-25 16:15:00', '2024-05-25 23:59:59', 'impago', '2024-04-25 16:15:00', 'Monotributista'),
(100101234567, 'Factura A', '2024-05-01 10:10:00', '2024-06-01 23:59:59', 'pago', '2024-05-01 10:10:00', 'Responsable Inscripto'),
(100102345678, 'Factura B', '2024-05-05 11:20:00', '2024-06-05 23:59:59', 'pago', '2024-05-05 11:20:00', 'Exento'),
(100103456789, 'Factura C', '2024-05-10 14:00:00', '2024-06-10 23:59:59', 'impago', '2024-05-10 14:00:00', 'Monotributista'),
(100104567890, 'Factura A', '2024-05-15 09:35:00', '2024-06-15 23:59:59', 'pago', '2024-05-15 09:35:00', 'Responsable Inscripto'),
(100105678901, 'Factura B', '2024-05-20 13:10:00', '2024-06-20 23:59:59', 'impago', '2024-05-20 13:10:00', 'Exento'),
(100106789012, 'Factura C', '2024-05-25 16:50:00', '2024-06-25 23:59:59', 'pago', '2024-05-25 16:50:00', 'Monotributista'),
(100107890123, 'Factura A', '2024-06-01 10:30:00', '2024-07-01 23:59:59', 'impago', '2024-06-01 10:30:00', 'Responsable Inscripto'),
(100108901234, 'Factura B', '2024-06-05 11:40:00', '2024-07-05 23:59:59', 'pago', '2024-06-05 11:40:00', 'Exento'),
(100109012345, 'Factura C', '2024-06-10 14:55:00', '2024-07-10 23:59:59', 'impago', '2024-06-10 14:55:00', 'Monotributista');
INSERT INTO categoria (nombre, descripcion, estado) VALUES
('Electrónica', 'Productos electrónicos y gadgets', 1),
('Ropa', 'Prendas de vestir y accesorios', 1),
('Calzado', 'Zapatos y calzado deportivo', 0),
('Juguetes', 'Juguetes para niños de todas las edades', 1),
('Hogar', 'Artículos para el hogar y decoración', 1),
('Deportes', 'Equipos y accesorios deportivos', 1),
('Libros', 'Libros y material de lectura', 1),
('Música', 'Instrumentos y accesorios musicales', 1),
('Videojuegos', 'Consolas y videojuegos', 0),
('Joyería', 'Joyas y bisutería', 1),
('Salud', 'Productos de salud y bienestar', 1),
('Belleza', 'Productos de belleza y cuidado personal', 0),
('Automotriz', 'Repuestos y accesorios para autos', 1),
('Mascotas', 'Productos para el cuidado de mascotas', 1),
('Alimentos', 'Comida y productos gourmet', 1),
('Bebidas', 'Bebidas alcohólicas y no alcohólicas', 1),
('Papelería', 'Material de oficina y escolar', 1),
('Electrodomésticos', 'Aparatos eléctricos para el hogar', 1),
('Herramientas', 'Herramientas y equipos de bricolaje', 1),
('Jardinería', 'Productos para el jardín y exteriores', 0),
('Computadoras', 'PCs, laptops y accesorios', 0),
('Celulares', 'Teléfonos móviles y accesorios', 0),
('Fotografía', 'Cámaras y equipos de fotografía', 1),
('Relojes', 'Relojes de pulsera y de bolsillo', 0), 
('Bolsos', 'Bolsos, carteras y mochilas', 1),
('Muebles', 'Muebles para el hogar y oficina', 1),
('Viajes', 'Equipaje y accesorios de viaje', 1),
('Seguridad', 'Productos de seguridad y vigilancia', 0),
('Juegos de Mesa', 'Juegos de mesa y rompecabezas', 0), 
('Cine', 'Películas y accesorios de cine en casa', 0); 
INSERT INTO impuesto (idcomprobante, nombre, tipo_impuesto, tasa, descripcion, estado) 
VALUES
(1, 'IVA', 'Nacional', 21.00, 'Impuesto al Valor Agregado', 'pago'),
(2, 'Ganancias', 'Nacional', 35.00, 'Impuesto a las Ganancias', 'pago'),
(3, 'Luz', 'Servicios', 27.00, 'Impuesto sobre el consumo de electricidad', 'pendiente'),
(4, 'Gas', 'Servicios', 10.50, 'Impuesto sobre el consumo de gas natural', 'pendiente'),
(5, 'Rentas', 'Provincial', 3.50, 'Impuesto sobre los ingresos brutos', 'pendiente'),
(6, 'ABL', 'Municipal', 1.00, 'Ablimp, Alumbrado, Barrido y Limpieza', 'pago'),
(7, 'Sellos', 'Provincial', 1.50, 'Impuesto sobre sellos y contratos', 'impago'),
(8, 'Seguridad e Higiene', 'Municipal', 2.00, 'Impuesto de seguridad e higiene', 'pago'),
(9, 'Impuesto Automotor', 'Provincial', 2.50, 'Impuesto sobre vehículos automotores', 'impago'),
(10, 'IVA', 'Nacional', 10.50, 'Impuesto al Valor Agregado reducido', 'pago'),
(11, 'Ganancias', 'Nacional', 35.00, 'Impuesto a las Ganancias sobre dividendos', 'pendiente'),
(12, 'Luz', 'Servicios', 21.00, 'Impuesto sobre el consumo de electricidad', 'pendiente'),
(13, 'Gas', 'Servicios', 10.50, 'Impuesto sobre el consumo de gas natural', 'pago'),
(14, 'Rentas', 'Provincial', 5.00, 'Impuesto sobre los ingresos brutos', 'pago'),
(15, 'ABL', 'Municipal', 1.00, 'Ablimp, Alumbrado, Barrido y Limpieza', 'impago'),
(16, 'Sellos', 'Provincial', 1.50, 'Impuesto sobre sellos y contratos', 'pendiente'),
(17, 'Seguridad e Higiene', 'Municipal', 2.00, 'Impuesto de seguridad e higiene', 'pago'),
(18, 'Impuesto Automotor', 'Provincial', 3.00, 'Impuesto sobre vehículos automotores', 'impago'),
(19, 'IVA', 'Nacional', 27.00, 'Impuesto al Valor Agregado diferencial', 'pago'),
(20, 'Ganancias', 'Nacional', 35.00, 'Impuesto a las Ganancias', 'pendiente'),
(21, 'Luz', 'Servicios', 21.00, 'Impuesto sobre el consumo de electricidad', 'impago'),
(22, 'Gas', 'Servicios', 10.50, 'Impuesto sobre el consumo de gas natural', 'pago'),
(23, 'Rentas', 'Provincial', 3.50, 'Impuesto sobre los ingresos brutos', 'pendiente'),
(24, 'ABL', 'Municipal', 1.00, 'Ablimp, Alumbrado, Barrido y Limpieza', 'pago'),
(25, 'Sellos', 'Provincial', 1.50, 'Impuesto sobre sellos y contratos', 'impago'),
(26, 'Seguridad e Higiene', 'Municipal', 2.00, 'Impuesto de seguridad e higiene', 'pendiente'),
(27, 'Impuesto Automotor', 'Provincial', 2.50, 'Impuesto sobre vehículos automotores', 'pago'),
(28, 'IVA', 'Nacional', 21.00, 'Impuesto al Valor Agregado', 'impago'),
(29, 'Ganancias', 'Nacional', 35.00, 'Impuesto a las Ganancias', 'pendiente'),
(30, 'Luz', 'Servicios', 27.00, 'Impuesto sobre el consumo de electricidad', 'pago');
INSERT INTO `persona` (
  `idrol`, `nombre`, `apellido`, `tipo_documento`, `num_documento`, 
  `telefono`, `email`, `password`, `pais`, `provincia`, `ciudad`, 
  `direccion1`, `direccion2`, `codigo_postal`, `fecha_nacimiento`, `fecha_modificacion`, 
  `genero`
) 
VALUES
(23, 'John', 'Doe', 'DNI', '12345678A', '123456789', 'john.doe@example.com', 'password123', 'USA', 'California', 'Los Angeles', '123 Main St', 'Apt 4B', '90001', '1990-01-15', '2024-06-17', 1),
(5, 'Jane', 'Smith', 'Passport', 'AB123456', '987654321', 'jane.smith@example.com', 'password456', 'Canada', 'Ontario', 'Toronto', '456 Maple Ave', 'Unit 5A', 'M5H 2N2', '1985-07-20', '2024-06-17', 0),
(16, 'Michael', 'Johnson', 'SSN', '987654321', '456789012', 'michael.johnson@example.com', 'password789', 'UK', 'England', 'London', '789 Elm St', 'Suite 3C', 'E1 6AN', '1982-03-10', '2024-06-17', 1),
(29, 'Emily', 'Brown', 'Driver License', 'CD987654', '789012345', 'emily.brown@example.com', 'passwordabc', 'Australia', 'New South Wales', 'Sydney', '321 Pine Rd', 'Floor 2', '2000', '1995-09-05', '2024-06-17', 0),
(11, 'David', 'Williams', 'DNI', '65432198B', '321654987', 'david.williams@example.com', 'passworddef', 'France', 'Paris', 'Paris', '654 Oak St', 'Bldg 1', '75001', '1988-12-25', '2024-06-17', 1),
(9, 'Sarah', 'Jones', 'Passport', 'FG654321', '654987321', 'sarah.jones@example.com', 'passwordghi', 'Germany', 'Berlin', 'Berlin', '987 Spruce Ave', 'Apt 2D', '10115', '1992-06-30', '2024-06-17', 0),
(22, 'James', 'Taylor', 'SSN', '456789012', '789012345', 'james.taylor@example.com', 'passwordjkl', 'Italy', 'Rome', 'Rome', '123 Cedar St', 'Floor 3', '00184', '1975-04-18', '2024-06-17', 1),
(4, 'Emma', 'Davis', 'Driver License', 'HI123456', '012345678', 'emma.davis@example.com', 'passwordmno', 'Spain', 'Madrid', 'Madrid', '456 Birch St', 'Unit 6A', '28001', '1980-08-12', '2024-06-17', 0),
(30, 'Christopher', 'Miller', 'DNI', '32165498C', '987654321', 'christopher.miller@example.com', 'passwordpqr', 'China', 'Beijing', 'Beijing', '789 Walnut St', 'Suite 5B', '100000', '1983-10-08', '2024-06-17', 1),
(14, 'Olivia', 'Wilson', 'Passport', 'JK321654', '789012345', 'olivia.wilson@example.com', 'passwordstu', 'Japan', 'Tokyo', 'Tokyo', '321 Cherry St', 'Apt 1C', '100-0001', '1997-11-20', '2024-06-17', 0),
(18, 'Matthew', 'Moore', 'SSN', '789012345', '654321987', 'matthew.moore@example.com', 'passwordvwx', 'Brazil', 'Rio de Janeiro', 'Rio de Janeiro', '654 Maple St', 'Unit 7B', '20000-000', '1990-02-28', '2024-06-17', 1),
(3, 'Ava', 'Martinez', 'Driver License', 'LM987654', '012345678', 'ava.martinez@example.com', 'passwordyz1', 'Russia', 'Moscow', 'Moscow', '987 Aspen Ave', 'Suite 4C', '101000', '1987-05-15', '2024-06-17', 0),
(27, 'Andrew', 'Hernandez', 'DNI', '65498732D', '987654321', 'andrew.hernandez@example.com', 'password234', 'India', 'New Delhi', 'New Delhi', '321 Palm St', 'Floor 5', '110001', '1984-07-04', '2024-06-17', 1),
(8, 'Isabella', 'Garcia', 'Passport', 'NO654987', '789012345', 'isabella.garcia@example.com', 'password567', 'South Africa', 'Cape Town', 'Cape Town', '456 Poplar St', 'Unit 8A', '8001', '1993-09-10', '2024-06-17', 0),
(13, 'Joshua', 'Lopez', 'SSN', '012345678', '654321987', 'joshua.lopez@example.com', 'password890', 'South Korea', 'Seoul', 'Seoul', '789 Fir Ave', 'Apt 2B', '03000', '1989-11-22', '2024-06-17', 1),
(19, 'Sophia', 'Gonzalez', 'Driver License', 'PQ654987', '012345678', 'sophia.gonzalez@example.com', 'passwordabc1', 'Mexico', 'Mexico City', 'Mexico City', '123 Sycamore St', 'Suite 3D', '01000', '1996-01-07', '2024-06-17', 0),
(6, 'William', 'Rodriguez', 'DNI', '76549832E', '987654321', 'william.rodriguez@example.com', 'passworddef2', 'Argentina', 'Buenos Aires', 'Buenos Aires', '456 Alder St', 'Unit 5A', '1000', '1981-02-14', '2024-06-17', 1),
(26, 'Emily', 'Wilson', 'Passport', 'RS321654', '789012345', 'emily.wilson@example.com', 'passwordghi3', 'Canada', 'Quebec', 'Quebec City', '789 Hemlock St', 'Apt 6B', 'G1R 2L5', '1986-04-28', '2024-06-17', 0),
(1, 'Ethan', 'Perez', 'SSN', '234567890', '654321987', 'ethan.perez@example.com', 'passwordjkl4', 'Germany', 'Munich', 'Munich', '321 Cypress St', 'Floor 2', '80331', '1994-06-13', '2024-06-17', 1),
(15, 'Madison', 'Sanchez', 'Driver License', 'TU987654', '012345678', 'madison.sanchez@example.com', 'passwordmno5', 'France', 'Nice', 'Nice', '654 Magnolia St', 'Unit 3A', '06000', '1985-08-18', '2024-06-17', 0),
(10, 'Alexander', 'Ramirez', 'DNI', '87654321F', '987654321', 'alexander.ramirez@example.com', 'passwordpqr6', 'Italy', 'Venice', 'Venice', '789 Linden St', 'Apt 4B', '30100', '1991-10-02', '2024-06-17', 1),
(28, 'Mia', 'Torres', 'Passport', 'VW987654', '789012345', 'mia.torres@example.com', 'passwordstu7', 'Spain', 'Barcelona', 'Barcelona', '321 Sequoia St', 'Floor 3', '08001', '1988-12-17', '2024-06-17', 0),
(25, 'Benjamin', 'Nguyen', 'SSN', '345678901', '654321987', 'benjamin.nguyen@example.com', 'passwordvwx8', 'UK', 'Manchester', 'Manchester', '456 Redwood St', 'Suite 7C', 'M1 1AE', '1995-02-01', '2024-06-17', 1),
(12, 'Charlotte', 'Kim', 'Driver License', 'XY987654', '012345678', 'charlotte.kim@example.com', 'passwordyz19', 'USA', 'New York', 'New York', '789 Willow St', 'Apt 5D', '10001', '1982-03-27', '2024-06-17', 0),
(2, 'Daniel', 'Le', 'DNI', '98765432G', '987654321', 'daniel.le@example.com', 'password23410', 'Australia', 'Victoria', 'Melbourne', '321 Maple Ave', 'Unit 6A', '3000', '1987-05-11', '2024-06-17', 1),
(24, 'Avery', 'Tran', 'Passport', 'Z1A987654', '789012345', 'avery.tran@example.com', 'password56711', 'China', 'Shanghai', 'Shanghai', '456 Spruce St', 'Floor 2', '200000', '1992-07-26', '2024-06-17', 0),
(20, 'Grace', 'Pham', 'SSN', '456789012', '654321987', 'grace.pham@example.com', 'password89012', 'Japan', 'Osaka', 'Osaka', '789 Cherry St', 'Unit 3B', '540-0001', '1989-09-09', '2024-06-17', 1),
(21, 'Jackson', 'Choi', 'Driver License', 'B2C987654', '012345678', 'jackson.choi@example.com', 'passwordabc13', 'Brazil', 'Sao Paulo', 'Sao Paulo', '123 Oak St', 'Apt 4C', '01000-000', '1993-11-14', '2024-06-17', 0),
(7, 'Chloe', 'Park', 'DNI', '987654321', '987654321', 'chloe.park@example.com', 'passworddef14', 'Russia', 'Saint Petersburg', 'Saint Petersburg', '456 Pine St', 'Unit 5B', '190000', '1988-01-01', '2024-06-17', 1),
(17, 'Liam', 'Lee', 'Passport', 'D3E987654', '789012345', 'liam.lee@example.com', 'passwordghi15', 'UK', 'London', 'London', '789 Elm St', 'Suite 4C', 'E1 6AN', '1985-12-15', '2024-06-17', 0);
INSERT INTO producto (idcategoria, iddetalle_ingreso_mercaderia, titulo, descripcion, codigo_producto, stock, thumbnail, images, idcategoria_default, rating, estado)
VALUES
(6, 1, 'Camiseta de algodón blanca', 'Camiseta de algodón de manga corta, color blanco, talla L.', 'PRD001', 50, '/thumbnails/prd001.jpg', '["/images/prd001_1.jpg", "/images/prd001_2.jpg"]', 6, 4, 'en stock'),
(7, 2, 'Laptop ultradelgada Core i7', 'Laptop ultradelgada con procesador Core i7 y SSD de 512GB.', 'PRD002', 10, '/thumbnails/prd002.jpg', '["/images/prd002_1.jpg", "/images/prd002_2.jpg"]', 7, 5, 'en stock'),
(4, 3, 'Aceite de oliva extra virgen', 'Aceite de oliva extra virgen, botella de 1 litro.', 'PRD003', 100, '/thumbnails/prd003.jpg', '["/images/prd003_1.jpg", "/images/prd003_2.jpg"]', 4, 4, 'en stock'),
(8, 4, 'Silla de oficina ergonómica', 'Silla de oficina ergonómica con soporte lumbar ajustable.', 'PRD004', 20, '/thumbnails/prd004.jpg', '["/images/prd004_1.jpg", "/images/prd004_2.jpg"]', 8, 4, 'en stock'),
(2, 5, 'Juego de copas de cristal', 'Juego de 6 copas de cristal para vino tinto.', 'PRD005', 30, '/thumbnails/prd005.jpg', '["/images/prd005_1.jpg", "/images/prd005_2.jpg"]', 2, 3, 'en stock'),
(7, 6, 'Paquete de pilas alcalinas AAA', 'Paquete de 12 pilas alcalinas AAA.', 'PRD006', 200, '/thumbnails/prd006.jpg', '["/images/prd006_1.jpg", "/images/prd006_2.jpg"]', 7, 5, 'en stock'),
(7, 7, 'Cámara digital compacta', 'Cámara digital compacta con zoom óptico de 30x.', 'PRD007', 15, '/thumbnails/prd007.jpg', '["/images/prd007_1.jpg", "/images/prd007_2.jpg"]', 7, 4, 'en stock'),
(9, 8, 'Set de herramientas de 50 piezas', 'Set de herramientas de 50 piezas para reparaciones domésticas.', 'PRD008', 5, '/thumbnails/prd008.jpg', '["/images/prd008_1.jpg", "/images/prd008_2.jpg"]', 9, 4, 'en stock'),
(7, 9, 'Tablet con pantalla HD de 10 pulgadas', 'Tablet con pantalla HD de 10 pulgadas y memoria RAM de 4GB.', 'PRD009', 8, '/thumbnails/prd009.jpg', '["/images/prd009_1.jpg", "/images/prd009_2.jpg"]', 7, 4, 'en stock'),
(11, 10, 'Batería recargable de iones de litio', 'Batería recargable de iones de litio para vehículo eléctrico.', 'PRD010', 2, '/thumbnails/prd010.jpg', '["/images/prd010_1.jpg", "/images/prd010_2.jpg"]', 11, 5, 'en stock'),
(10, 11, 'Zapatos deportivos para correr', 'Zapatos deportivos para correr, talla 9, color azul.', 'PRD011', 25, '/thumbnails/prd011.jpg', '["/images/prd011_1.jpg", "/images/prd011_2.jpg"]', 10, 4, 'en stock'),
(7, 12, 'Licuadora de alta potencia', 'Licuadora de alta potencia con vaso de vidrio templado.', 'PRD012', 12, '/thumbnails/prd012.jpg', '["/images/prd012_1.jpg", "/images/prd012_2.jpg"]', 7, 4, 'en stock'),
(2, 13, 'Pack de 6 tazas de cerámica', 'Pack de 6 tazas de cerámica para café con diseño moderno.', 'PRD013', 18, '/thumbnails/prd013.jpg', '["/images/prd013_1.jpg", "/images/prd013_2.jpg"]', 2, 4, 'en stock'),
(12, 14, 'Reloj analógico de acero inoxidable', 'Reloj analógico de acero inoxidable con cronógrafo.', 'PRD014', 7, '/thumbnails/prd014.jpg', '["/images/prd014_1.jpg", "/images/prd014_2.jpg"]', 12, 3, 'en stock'),
(7, 15, 'Cafetera automática', 'Cafetera automática con capacidad para 12 tazas.', 'PRD015', 5, '/thumbnails/prd015.jpg', '["/images/prd015_1.jpg", "/images/prd015_2.jpg"]', 7, 4, 'en stock'),
(10, 16, 'Mochila resistente al agua', 'Mochila resistente al agua con compartimentos múltiples.', 'PRD016', 15, '/thumbnails/prd016.jpg', '["/images/prd016_1.jpg", "/images/prd016_2.jpg"]', 10, 4, 'en stock'),
(13, 17, 'Teclado mecánico RGB', 'Teclado mecánico RGB con retroiluminación personalizable.', 'PRD017', 3, '/thumbnails/prd017.jpg', '["/images/prd017_1.jpg", "/images/prd017_2.jpg"]', 13, 5, 'en stock'),
(8, 18, 'Juego de ollas y sartenes antiadherentes', 'Juego de ollas y sartenes antiadherentes de alta calidad.', 'PRD018', 10, '/thumbnails/prd018.jpg', '["/images/prd018_1.jpg", "/images/prd018_2.jpg"]', 8, 4, 'en stock'),
(7, 19, 'Teléfono inteligente con cámara triple', 'Teléfono inteligente con cámara triple y carga rápida.', 'PRD019', 6, '/thumbnails/prd019.jpg', '["/images/prd019_1.jpg", "/images/prd019_2.jpg"]', 7, 4, 'en stock'),
(11, 20, 'Mesa de centro de madera maciza', 'Mesa de centro de madera maciza con acabado rústico.', 'PRD020', 4, '/thumbnails/prd020.jpg', '["/images/prd020_1.jpg", "/images/prd020_2.jpg"]', 11, 4, 'en stock'),
(7, 21, 'Audífonos inalámbricos con cancelación de ruido', 'Audífonos inalámbricos con cancelación de ruido y micrófono.', 'PRD021', 8, '/thumbnails/prd021.jpg', '["/images/prd021_1.jpg", "/images/prd021_2.jpg"]', 7, 4, 'en stock'),
(14, 22, 'Saco de dormir ligero para camping', 'Saco de dormir ligero para camping en temperaturas moderadas.', 'PRD022', 2, '/thumbnails/prd022.jpg', '["/images/prd022_1.jpg", "/images/prd022_2.jpg"]', 14, 4, 'en stock'),
(7, 23, 'Secadora de ropa de gran capacidad', 'Secadora de ropa de gran capacidad con programas de secado rápido.', 'PRD023', 3, '/thumbnails/prd023.jpg', '["/images/prd023_1.jpg", "/images/prd023_2.jpg"]', 7, 4, 'en stock'),
(10, 24, 'Paraguas automático compacto', 'Paraguas automático compacto con resistencia al viento.', 'PRD024', 20, '/thumbnails/prd024.jpg', '["/images/prd024_1.jpg", "/images/prd024_2.jpg"]', 10, 4, 'en stock'),
(7, 25, 'Cargador portátil de alta capacidad', 'Cargador portátil de alta capacidad para dispositivos móviles.', 'PRD025', 15, '/thumbnails/prd025.jpg', '["/images/prd025_2.jpg"]', 10, 4, 'en stock');
	INSERT INTO detalle_ingreso_mercaderia (idproveedor, idimpuesto, idcomprobante, codigo_producto, descripcion_producto, cantidad, precio_compra, total, estado, fecha_ingreso, fecha_vencimiento, lote_o_serie, condicion_almacenamiento, notas, categoria_producto, marca, sku, fecha_fabricacion, pais_origen)
	VALUES
	(12, 5, 25, 'PRD001', 'Camiseta de algodón de manga corta, color blanco, talla L.', 50, 15.50, 825.00, 'en stock', '2023-05-15 09:00:00', '2024-05-15', 'LOT123', 'Almacenado en ambiente seco', 'Ninguna observación adicional', 'Ropa', 'Marca A', 'PRD001', '2023-04-01', 'Argentina'),
	(23, 17, 18, 'PRD002', 'Laptop ultradelgada con procesador Core i7 y SSD de 512GB.', 10, 1200.00, 13500.00, 'en stock', '2023-05-16 10:30:00', '2025-05-16', 'SER789', 'Almacenado en caja sellada', 'No exponer a altas temperaturas', 'Electrónica', 'Marca B', 'PRD002', '2023-03-15', 'China'),
	(6, 8, 15, 'PRD003', 'Aceite de oliva extra virgen, botella de 1 litro.', 100, 8.50, 900.00, 'en stock', '2023-05-17 14:45:00', '2024-12-31', 'SER987', 'Almacenado en lugar fresco y oscuro', 'Producto frágil, manipular con cuidado', 'Alimentos', 'Marca C', 'PRD003', '2023-01-10', 'España'),
	(19, 30, 8, 'PRD004', 'Silla de oficina ergonómica con soporte lumbar ajustable.', 20, 85.00, 1900.00, 'en stock', '2023-05-18 08:00:00', '2025-05-18', 'LOT456', 'Almacenado en almacén seco y ventilado', 'Requiere montaje simple', 'Mobiliario', 'Marca D', 'PRD004', '2023-02-20', 'Argentina'),
	(10, 12, 22, 'PRD005', 'Juego de 6 copas de cristal para vino tinto.', 30, 25.00, 780.00, 'en stock', '2023-05-19 11:00:00', '2024-06-30', 'LOT789', 'Almacenado en caja original', 'Manejar con cuidado para evitar roturas', 'Hogar y Cocina', 'Marca E', 'PRD005', '2023-03-05', 'Italia'),
	(14, 13, 13, 'PRD006', 'Paquete de 12 pilas alcalinas AAA.', 200, 1.50, 330.00, 'en stock', '2023-05-20 13:30:00', '2025-05-20', 'SER555', 'Almacenado en lugar seco y fresco', 'Mantener fuera del alcance de los niños', 'Electrónica', 'Marca F', 'PRD006', '2023-01-25', 'Estados Unidos'),
	(27, 3, 4, 'PRD007', 'Cámara digital compacta con zoom óptico de 30x.', 15, 280.00, 4410.00, 'en stock', '2023-05-21 16:00:00', '2024-05-21', 'LOT111', 'Almacenado en estuche protector', 'Evitar golpes y caídas', 'Electrónica', 'Marca G', 'PRD007', '2023-02-28', 'Japón'),
	(25, 24, 7, 'PRD008', 'Set de herramientas de 50 piezas para reparaciones domésticas.', 5, 45.00, 247.50, 'en stock', '2023-05-22 09:30:00', '2025-05-22', 'LOT222', 'Almacenado en caja metálica resistente', 'Ideal para regalo', 'Herramientas', 'Marca H', 'PRD008', '2023-04-10', 'China'),
	(16, 15, 21, 'PRD009', 'Tablet con pantalla HD de 10 pulgadas y memoria RAM de 4GB.', 8, 180.00, 1620.00, 'en stock', '2023-05-23 10:00:00', '2024-05-23', 'SER333', 'Almacenado en caja original con accesorios', 'Para uso personal o profesional', 'Electrónica', 'Marca I', 'PRD009', '2023-03-15', 'China'),
	(1, 18, 29, 'PRD010', 'Batería recargable de iones de litio para vehículo eléctrico.', 2, 850.00, 1870.00, 'en stock', '2023-05-24 11:30:00', '2025-05-24', 'LOT333', 'Almacenado en lugar seco y fresco', 'Requiere instalación profesional', 'Automotriz', 'Marca J', 'PRD010', '2023-01-20', 'Estados Unidos'),
	(4, 20, 14, 'PRD011', 'Zapatos deportivos para correr, talla 9, color azul.', 25, 55.00, 1450.00, 'en stock', '2023-05-25 14:00:00', '2024-05-25', 'LOT444', 'Almacenado en caja original', 'Ideal para actividades deportivas', 'Calzado Deportivo', 'Marca K', 'PRD011', '2023-02-10', 'Vietnam'),
	(15, 7, 3, 'PRD012', 'Licuadora de alta potencia con vaso de vidrio templado.', 12, 65.00, 816.00, 'en stock', '2023-05-26 16:30:00', '2024-05-26', 'SER222', 'Almacenado en lugar fresco y seco', 'Evitar el uso continuo por más de 5 minutos', 'Electrodomésticos', 'Marca L', 'PRD012', '2023-04-05', 'China'),
	(26, 28, 19, 'PRD013', 'Pack de 6 tazas de cerámica para café con diseño moderno.', 18, 18.00, 342.00, 'en stock', '2023-05-27 08:45:00', '2024-05-27', 'LOT555', 'Almacenado en caja original', 'Manejar con cuidado para evitar roturas', 'Hogar y Cocina', 'Marca M', 'PRD013', '2023-03-20', 'México'),
	(3, 16, 26, 'PRD014', 'Reloj analógico de acero inoxidable con cronógrafo.', 7, 120.00, 910.00, 'en stock', '2023-05-28 10:00:00', '2024-05-28', 'LOT666', 'Almacenado en estuche acolchado', 'No sumergir en agua', 'Accesorios', 'Marca N', 'PRD014', '2023-02-01', 'Suiza'),
	(21, 27, 28, 'PRD015', 'Cafetera automática con capacidad para 12 tazas.', 5, 55.00, 275.00, 'en stock', '2023-05-29 11:30:00', '2024-05-29', 'LOT777', 'Almacenado en caja original', 'Instrucciones incluidas', 'Electrodomésticos', 'Marca O', 'PRD015', '2023-01-15', 'China'),
	(7, 11, 23, 'PRD016', 'Mochila resistente al agua con compartimentos múltiples.', 15, 32.00, 520.00, 'en stock', '2023-05-30 14:00:00', '2024-05-30', 'SER444', 'Almacenado en lugar seco y fresco', 'Ideal para uso diario', 'Indumentaria', 'Marca O', 'PRD015', '2023-01-15', 'China');
INSERT INTO `persona` (`idrol`, `nombre`, `apellido`, `tipo_documento`, `num_documento`, `telefono`, `email`, `password`, `pais`, `provincia`, `ciudad`, `direccion1`, `direccion2`, `codigo_postal`, `fecha_nacimiento`, `fecha_modificacion`, `genero`)
VALUES
(1, 'Juan', 'Pérez', 'DNI', '12345678', '1122334455', 'juan.perez@example.com', 'password123', 'Argentina', 'Buenos Aires', 'CABA', 'Calle Falsa', '123', '1234', '1990-01-15', '2023-06-01', 1),
(2, 'María', 'Gómez', 'CI', '87654321', '5544332211', 'maria.gomez@example.com', 'pass456', 'Argentina', 'Córdoba', 'Córdoba', 'Av. Principal', '456', '5678', '1988-05-20', '2023-06-01', 0),
(3, 'Carlos', 'Rodríguez', 'DNI', '23456789', '6677889900', 'carlos.rodriguez@example.com', 'clave789', 'Argentina', 'Santa Fe', 'Rosario', 'Av. Libertador', '789', '9012', '1985-11-10', '2023-06-01', 1),
(4, 'Ana', 'Martínez', 'DNI', '34567890', '1122334455', 'ana.martinez@example.com', 'segura123', 'Argentina', 'Buenos Aires', 'La Plata', 'Rivadavia', '456', '1234', '1992-03-25', '2023-06-01', 0),
(5, 'Luis', 'López', 'CI', '98765432', '9988776655', 'luis.lopez@example.com', 'contra321', 'Argentina', 'Salta', 'Salta', 'Av. Bolívar', '789', '5678', '1995-08-12', '2023-06-01', 1),
(6, 'Laura', 'Fernández', 'DNI', '45678901', '3344556677', 'laura.fernandez@example.com', 'pass1234', 'Argentina', 'Mendoza', 'Mendoza', 'San Martín', '890', '9012', '1987-12-03', '2023-06-01', 0),
(7, 'Jorge', 'González', 'DNI', '56789012', '5566778899', 'jorge.gonzalez@example.com', 'clave5678', 'Argentina', 'Entre Ríos', 'Paraná', 'Belgrano', '123', '3456', '1991-07-18', '2023-06-01', 1),
(8, 'Carolina', 'Díaz', 'CI', '87654321', '1122334455', 'carolina.diaz@example.com', 'contrasena987', 'Argentina', 'Neuquén', 'Neuquén', 'Av. San Martín', '456', '6789', '1993-04-30', '2023-06-01', 0),
(9, 'Miguel', 'Suárez', 'DNI', '67890123', '9988776655', 'miguel.suarez@example.com', 'password5678', 'Argentina', 'San Juan', 'San Juan', 'Rivadavia', '789', '0123', '1989-09-08', '2023-06-01', 1),
(10, 'Silvia', 'López', 'DNI', '78901234', '3344556677', 'silvia.lopez@example.com', 'seguridad321', 'Argentina', 'Chubut', 'Rawson', 'Av. Belgrano', '012', '4567', '1994-02-14', '2023-06-01', 0),
(11, 'Roberto', 'Martín', 'CI', '89012345', '5566778899', 'roberto.martin@example.com', 'clave9876', 'Argentina', 'Tierra del Fuego', 'Ushuaia', 'San Martín', '345', '6789', '1996-06-25', '2023-06-01', 1),
(12, 'Andrea', 'García', 'DNI', '90123456', '1122334455', 'andrea.garcia@example.com', 'pass7890', 'Argentina', 'Santa Cruz', 'Río Gallegos', 'Av. San Martín', '678', '9012', '1990-11-05', '2023-06-01', 0),
(13, 'Pablo', 'Hernández', 'DNI', '01234567', '9988776655', 'pablo.hernandez@example.com', 'contrasena123', 'Argentina', 'Catamarca', 'San Fernando del Valle', 'Rivadavia', '901', '2345', '1993-08-30', '2023-06-01', 1),
(14, 'Victoria', 'Pérez', 'CI', '12345678', '3344556677', 'victoria.perez@example.com', 'password2468', 'Argentina', 'La Rioja', 'La Rioja', 'Av. Belgrano', '234', '5678', '1995-05-20', '2023-06-01', 0),
(15, 'Alejandro', 'Gómez', 'DNI', '23456789', '1122334455', 'alejandro.gomez@example.com', 'seguro123', 'Argentina', 'Buenos Aires', 'CABA', 'Av. Principal', '567', '8901', '1988-03-15', '2023-06-01', 1),
(16, 'Florencia', 'Díaz', 'CI', '34567890', '9988776655', 'florencia.diaz@example.com', 'clave654', 'Argentina', 'Córdoba', 'Córdoba', 'Av. Libertador', '789', '0123', '1991-09-25', '2023-06-01', 0),
(17, 'Gustavo', 'Rodríguez', 'DNI', '45678901', '3344556677', 'gustavo.rodriguez@example.com', 'password987', 'Argentina', 'Santa Fe', 'Rosario', 'Av. Bolívar', '901', '2345', '1994-07-10', '2023-06-01', 1),
(18, 'Marcela', 'Martínez', 'DNI', '56789012', '1122334455', 'marcela.martinez@example.com', 'segura567', 'Argentina', 'Buenos Aires', 'La Plata', 'Rivadavia', '234', '5678', '1987-05-05', '2023-06-01', 0),
(19, 'Esteban', 'López', 'CI', '67890123', '9988776655', 'esteban.lopez@example.com', 'contrasena789', 'Argentina', 'Salta', 'Salta', 'Av. San Martín', '567', '8901', '1990-10-18', '2023-06-01', 1),
(20, 'Camila', 'Suárez', 'DNI', '78901234', '3344556677', 'camila.suarez@example.com', 'pass654', 'Argentina', 'Mendoza', 'Mendoza', 'San Martín', '890', '1234', '1993-12-01', '2023-06-01', 0),
(21, 'Martín', 'González', 'DNI', '89012345', '1122334455', 'martin.gonzalez@example.com', 'clave321', 'Argentina', 'Entre Ríos', 'Paraná', 'Belgrano', '345', '6789', '1996-08-22', '2023-06-01', 1),
(22, 'Lucía', 'Díaz', 'CI', '90123456', '9988776655', 'lucia.diaz@example.com', 'password9876', 'Argentina', 'Neuquén', 'Neuquén', 'Av. Libertador', '567', '8901', '1989-01-12', '2023-06-01', 0),
(23, 'Diego', 'Pérez', 'DNI', '01234567', '3344556677', 'diego.perez@example.com', 'seguridad456', 'Argentina', 'San Juan', 'San Juan', 'Rivadavia', '901', '2345', '1992-04-05', '2023-06-01', 1),
(24, 'Valentina', 'Martín', 'CI', '12345678', '1122334455', 'valentina.martin@example.com', 'clave6543', 'Argentina', 'Chubut', 'Rawson', 'Av. Belgrano', '234', '5678', '1985-06-30', '2023-06-01', 0),
(25, 'Ramiro', 'Gómez', 'DNI', '23456789', '9988776655', 'ramiro.gomez@example.com', 'password1234', 'Argentina', 'Tierra del Fuego', 'Ushuaia', 'San Martín', '567', '8901', '1994-03-15', '2023-06-01', 1),
(26, 'Daniela', 'Hernández', 'DNI', '34567890', '3344556677', 'daniela.hernandez@example.com', 'segura987', 'Argentina', 'Santa Cruz', 'Río Gallegos', 'Av. San Martín', '890', '1234', '1988-09-25', '2023-06-01', 0),
(27, 'Maximiliano', 'Pérez', 'CI', '45678901', '1122334455', 'maximiliano.perez@example.com', 'contrasena456', 'Argentina', 'Catamarca', 'San Fernando del Valle', 'Rivadavia', '012', '3456', '1991-05-10', '2023-06-01', 1),
(28, 'Constanza', 'Martínez', 'DNI', '56789012', '9988776655', 'constanza.martinez@example.com', 'pass123', 'Argentina', 'La Rioja', 'La Rioja', 'Av. Belgrano', '345', '6789', '1996-07-18', '2023-06-01', 0),
(29, 'Facundo', 'López', 'CI', '67890123', '3344556677', 'facundo.lopez@example.com', 'clave789', 'Argentina', 'Buenos Aires', 'CABA', 'Av. Principal', '567', '8901', '1987-10-05', '2023-06-01', 1),
(30, 'Juliana', 'González', 'DNI', '78901234', '1122334455', 'juliana.gonzalez@example.com', 'segura456', 'Argentina', 'Córdoba', 'Córdoba', 'Av. Libertador', '789', '0123', '1990-03-30', '2023-06-01', 0);
INSERT INTO `empleado` (`idpersona`, `cargo`, `salario`, `horas_trabajadas`, `fecha_contratacion`, `estado`)
VALUES
(1, 'Gerente', 75000.00, 38, '2022-01-10 09:00:00', 'activo'),
(2, 'Ingeniero', 65000.00, 35, '2021-03-15 09:00:00', 'inactivo'),
(3, 'Técnico', 45000.00, 40, '2020-06-01 09:00:00', 'activo'),
(4, 'Administrador', 55000.00, 42, '2021-11-23 09:00:00', 'activo'),
(5, 'Analista', 50000.00, 37, '2019-08-19 09:00:00', 'inactivo'),
(6, 'Diseñador', 60000.00, 39, '2023-02-11 09:00:00', 'activo'),
(7, 'Especialista RRHH', 52000.00, 36, '2018-05-10 09:00:00', 'activo'),
(8, 'Personal de apoyo', 35000.00, 41, '2020-09-14 09:00:00', 'activo'),
(9, 'Auxiliar', 32000.00, 34, '2022-07-25 09:00:00', 'activo'),
(10, 'Consultor', 80000.00, 40, '2023-01-03 09:00:00', 'activo'),
(11, 'Gerente', 78000.00, 37, '2020-12-21 09:00:00', 'inactivo'),
(12, 'Ingeniero', 67000.00, 35, '2019-04-10 09:00:00', 'activo'),
(13, 'Técnico', 46000.00, 40, '2021-06-15 09:00:00', 'activo'),
(14, 'Administrador', 57000.00, 42, '2018-02-14 09:00:00', 'activo'),
(15, 'Analista', 51000.00, 36, '2022-10-10 09:00:00', 'activo'),
(16, 'Diseñador', 61000.00, 40, '2017-11-05 09:00:00', 'activo'),
(17, 'Especialista RRHH', 53000.00, 39, '2019-09-01 09:00:00', 'inactivo'),
(18, 'Personal de apoyo', 36000.00, 34, '2020-04-17 09:00:00', 'activo'),
(19, 'Auxiliar', 33000.00, 35, '2021-05-29 09:00:00', 'activo'),
(20, 'Consultor', 82000.00, 40, '2018-07-23 09:00:00', 'activo'),
(21, 'Gerente', 76000.00, 37, '2021-11-30 09:00:00', 'activo'),
(22, 'Ingeniero', 68000.00, 39, '2023-03-09 09:00:00', 'activo'),
(23, 'Técnico', 47000.00, 41, '2019-05-15 09:00:00', 'inactivo'),
(24, 'Administrador', 58000.00, 40, '2017-10-20 09:00:00', 'activo'),
(25, 'Analista', 52000.00, 36, '2020-08-05 09:00:00', 'activo'),
(26, 'Diseñador', 62000.00, 38, '2022-04-16 09:00:00', 'activo'),
(27, 'Especialista RRHH', 54000.00, 35, '2018-01-09 09:00:00', 'inactivo'),
(28, 'Personal de apoyo', 37000.00, 34, '2021-12-12 09:00:00', 'activo'),
(29, 'Auxiliar', 34000.00, 40, '2023-05-01 09:00:00', 'activo'),
(30, 'Consultor', 83000.00, 37, '2019-02-18 09:00:00', 'activo');
INSERT INTO `cliente` (`idpersona`, `cantidad_devuelta`, `motivo_devolucion`, `estado_devolucion`, `notificaciones_activas`, `estado`, `ultima_visita_sitio`, `ultima_compra`, `metodo_pago_preferido`, `total_compras`, `puntos_cliente`)
VALUES
(1, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-05-15 08:30:00', '2023-05-10', 'Tarjeta de crédito', 3, 50),
(2, NULL, NULL, 'Rechazada', true, 'activo', '2023-05-12 14:45:00', '2023-05-05', 'PayPal', 5, 80),
(3, 1, 'Daño en el envío', 'Aceptada', true, 'activo', '2023-05-18 11:20:00', '2023-05-15', 'Transferencia bancaria', 2, 30),
(4, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-05-20 09:00:00', '2023-05-18', 'Tarjeta de débito', 1, 10),
(5, 2, 'Producto no recibido', 'Aceptada', true, 'activo', '2023-05-22 16:30:00', '2023-05-20', 'Efectivo', 4, 70),
(6, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-05-25 13:10:00', '2023-05-23', 'Tarjeta de crédito', 6, 120),
(7, 3, 'Producto roto', 'Rechazada', true, 'activo', '2023-05-28 10:45:00', '2023-05-25', 'PayPal', 2, 40),
(8, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-06-02 09:20:00', '2023-06-01', 'Tarjeta de crédito', 8, 160),
(9, NULL, NULL, 'Aceptada', true, 'activo', '2023-06-05 15:00:00', '2023-06-03', 'Transferencia bancaria', 3, 50),
(10, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-06-08 11:50:00', '2023-06-06', 'Tarjeta de débito', 7, 140),
(11, 1, 'Defecto de fabricación', 'Aceptada', true, 'activo', '2023-06-10 08:40:00', '2023-06-09', 'Efectivo', 5, 90),
(12, NULL, NULL, 'Rechazada', true, 'activo', '2023-06-12 14:15:00', '2023-06-11', 'Tarjeta de crédito', 4, 60),
(13, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-06-15 10:30:00', '2023-06-13', 'PayPal', 9, 180),
(14, 2, 'Producto dañado', 'Aceptada', true, 'activo', '2023-06-18 16:20:00', '2023-06-16', 'Tarjeta de crédito', 6, 120),
(15, NULL, NULL, 'Rechazada', true, 'activo', '2023-06-20 12:00:00', '2023-06-19', 'Transferencia bancaria', 2, 30),
(16, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-06-22 09:40:00', '2023-06-21', 'Tarjeta de débito', 3, 50),
(17, 3, 'Producto incorrecto', 'Aceptada', true, 'activo', '2023-06-25 13:50:00', '2023-06-24', 'Efectivo', 8, 160),
(18, NULL, NULL, 'Rechazada', true, 'activo', '2023-06-28 11:25:00', '2023-06-27', 'Tarjeta de crédito', 1, 10),
(19, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-07-01 08:55:00', '2023-06-30', 'PayPal', 4, 70),
(20, NULL, NULL, 'Aceptada', true, 'activo', '2023-07-04 15:15:00', '2023-07-03', 'Tarjeta de crédito', 5, 90),
(21, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-07-07 14:00:00', '2023-07-06', 'Transferencia bancaria', 7, 140),
(22, 1, 'Defecto de fabricación', 'Aceptada', true, 'activo', '2023-07-10 10:10:00', '2023-07-09', 'Tarjeta de débito', 2, 30),
(23, NULL, NULL, 'Rechazada', true, 'activo', '2023-07-13 09:35:00', '2023-07-12', 'Efectivo', 6, 120),
(24, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-07-16 12:40:00', '2023-07-15', 'Tarjeta de crédito', 9, 180),
(25, 2, 'Producto defectuoso', 'Aceptada', true, 'activo', '2023-07-19 16:00:00', '2023-07-18', 'PayPal', 3, 50),
(26, NULL, NULL, 'Rechazada', true, 'activo', '2023-07-22 14:30:00', '2023-07-21', 'Tarjeta de débito', 7, 140),
(27, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-07-25 11:55:00', '2023-07-24', 'Efectivo', 5, 90),
(28, 3, 'Producto usado', 'Aceptada', true, 'activo', '2023-07-28 08:20:00', '2023-07-27', 'Tarjeta de crédito', 4, 60),
(29, NULL, NULL, 'Rechazada', true, 'activo', '2023-07-31 10:05:00', '2023-07-30', 'PayPal', 8, 160),
(30, NULL, NULL, 'En proceso de revisión', true, 'activo', '2023-08-03 13:45:00', '2023-08-02', 'Tarjeta de débito', 6, 120);
INSERT INTO `venta` (`idcliente`, `idempleado`, `idimpuesto`, `idcomprobante`, `monto`, `estado`, `metodo_de_pago`, `cantidad`, `descuento`, `cantidad_devuelta`, `estado_devolucion`)
VALUES
(1, 3, 1, 1, 150.00, 'completada', 'efectivo', 1, 0.00, NULL, NULL),
(2, 5, 2, 2, 250.00, 'completada', 'credito', 2, 10.00, NULL, NULL),
(3, 7, 3, 3, 180.00, 'en proceso', 'debito', 1, 5.00, NULL, NULL),
(4, 9, 1, 4, 300.00, 'completada', 'cuenta corriente', 3, 15.00, NULL, NULL),
(5, 11, 2, 1, 200.00, 'cancelada', 'transferencia bancaria', 1, 0.00, NULL, NULL),
(1, 6, 3, 2, 220.00, 'completada', 'efectivo', 2, 8.00, NULL, NULL),
(2, 8, 1, 3, 260.00, 'completada', 'credito', 1, 12.00, NULL, NULL),
(3, 10, 2, 4, 190.00, 'en proceso', 'debito', 2, 3.00, NULL, NULL),
(4, 12, 3, 1, 320.00, 'completada', 'cuenta corriente', 1, 20.00, NULL, NULL),
(5, 14, 1, 2, 180.00, 'cancelada', 'transferencia bancaria', 3, 0.00, NULL, NULL),
(1, 4, 2, 3, 210.00, 'completada', 'efectivo', 1, 6.00, NULL, NULL),
(2, 6, 3, 4, 280.00, 'completada', 'credito', 2, 10.00, NULL, NULL),
(3, 8, 1, 1, 170.00, 'en proceso', 'debito', 3, 8.00, NULL, NULL),
(4, 10, 2, 2, 340.00, 'completada', 'cuenta corriente', 1, 25.00, NULL, NULL),
(5, 12, 3, 3, 160.00, 'cancelada', 'transferencia bancaria', 2, 0.00, NULL, NULL),
(1, 5, 1, 4, 200.00, 'completada', 'efectivo', 2, 7.00, NULL, NULL),
(2, 7, 3, 1, 270.00, 'completada', 'credito', 1, 11.00, NULL, NULL),
(3, 9, 1, 2, 150.00, 'en proceso', 'debito', 2, 4.00, NULL, NULL),
(4, 11, 2, 3, 310.00, 'completada', 'cuenta corriente', 3, 18.00, NULL, NULL),
(5, 13, 3, 4, 140.00, 'cancelada', 'transferencia bancaria', 1, 0.00, NULL, NULL),
(1, 6, 2, 1, 230.00, 'completada', 'efectivo', 1, 5.00, NULL, NULL),
(2, 8, 1, 2, 290.00, 'completada', 'credito', 2, 9.00, NULL, NULL),
(3, 10, 2, 3, 160.00, 'en proceso', 'debito', 3, 6.00, NULL, NULL),
(4, 12, 3, 4, 330.00, 'completada', 'cuenta corriente', 1, 22.00, NULL, NULL),
(5, 14, 1, 1, 190.00, 'cancelada', 'transferencia bancaria', 2, 0.00, NULL, NULL),
(1, 7, 3, 2, 240.00, 'completada', 'efectivo', 2, 8.00, NULL, NULL),
(2, 9, 1, 3, 300.00, 'completada', 'credito', 1, 10.00, NULL, NULL),
(3, 11, 2, 4, 140.00, 'en proceso', 'debito', 2, 2.00, NULL, NULL),
(4, 13, 3, 1, 350.00, 'completada', 'cuenta corriente', 3, 20.00, NULL, NULL),
(5, 15, 1, 2, 170.00, 'cancelada', 'transferencia bancaria', 1, 0.00, NULL, NULL);

