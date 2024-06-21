CREATE TRIGGER auditar_insert
BEFORE INSERT ON venta
FOR EACH ROW
    INSERT INTO auditoria (
        descripcion,
        descripOld,
        tipo_cambio_realizado,
        fecha_cambio,
        responsable_cambio
    ) VALUES (
        NEW.descripcion,
        NEW.descripcion,
        'INSERT',
        NOW(),
        USER()
    );

CREATE TRIGGER auditar_update
BEFORE UPDATE ON venta
FOR EACH ROW
    INSERT INTO auditoria (
        descripcion,
        descripOld,
        tipo_cambio_realizado,
        fecha_cambio,
        responsable_cambio
    ) VALUES (
        NEW.descripcion,
        OLD.descripcion,
        'UPDATE',
        NOW(),
        USER()
    );

CREATE TRIGGER auditar_delete
BEFORE DELETE ON venta
FOR EACH ROW
    INSERT INTO auditoria (
        descripcion,
        descripOld,
        tipo_cambio_realizado,
        fecha_cambio,
        responsable_cambio
    ) VALUES (
        OLD.descripcion,
        OLD.descripcion,
        'DELETE',
        NOW(),
        USER()
    );
