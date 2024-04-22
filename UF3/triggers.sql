-- Exercici 3
use rrhh;
CREATE TABLE auditoria_taules(
    usuari      VARCHAR(100),
    data        DATETIME,
    taula       VARCHAR(64),
    accio       VARCHAR(20),
    valors      VARCHAR(250)

);

DROP TRIGGER IF EXISTS auditar_INS
DELIMITER //
CREATE TRIGGER auditar_INS AFTER INSERT 
    ON empleats FOR EACH ROW 
BEGIN
    INSERT INTO auditoria_taules(usuari,data,taula,accio,valors)
    VALUES (USER(),NOW(),"empleats","AFEGIR",NEW.empleat_id);
END;
// DELIMITER ;

DROP TRIGGER IF EXISTS auditar_UDT
DELIMITER //
CREATE TRIGGER auditar_UDT AFTER UPDATE 
    ON empleats FOR EACH ROW 
BEGIN

    DECLARE oldvals VARCHAR(200)  DEFAULT "";

    IF (OLD.nom!=NEW.nom) THEN
        SET oldvals=CONCAT(oldvals,"nom: ",OLD.nom,",");
    END IF;

    IF (OLD.cognoms!=NEW.cognoms) THEN
        SET oldvals=CONCAT(oldvals,"cognoms: ",OLD.cognoms,",");
    END IF;    
    IF (OLD.email!=NEW.email) THEN
        SET oldvals=CONCAT(oldvals,"email: ",OLD.email,",");
    END IF;    
    IF (OLD.telefon!=NEW.telefon) THEN
        SET oldvals=CONCAT(oldvals,"telefon: ",OLD.telefon,",");
    END IF;
    IF (OLD.data_contractacio!=NEW.data_contractacio) THEN
        SET oldvals=CONCAT(oldvals,"data_contractacio: ",OLD.data_contractacio,",");
    END IF;
    IF (OLD.feina_codi!=NEW.feina_codi) THEN
        SET oldvals=CONCAT(oldvals,"feina_codi: ",OLD.feina_codi,",");
    END IF;
    IF (OLD.salari!=NEW.salari) THEN
        SET oldvals=CONCAT(oldvals,"salari: ",OLD.salari,",");
    END IF;
    IF (OLD.pct_comissio!=NEW.pct_comissio) THEN
        SET oldvals=CONCAT(oldvals,"pct_comissio: ",OLD.pct_comissio,",");
    END IF;
    IF (OLD.id_cap!=NEW.id_cap) THEN
        SET oldvals=CONCAT(oldvals,"id_cap: ",OLD.id_cap,",");
    END IF;
    IF (OLD.departament_id!=NEW.departament_id) THEN
        SET oldvals=CONCAT(oldvals,"departament_id: ",OLD.departament_id,",");
    END IF;

    INSERT INTO auditoria_taules(usuari,data,taula,accio,valors)
            VALUES (USER(),NOW(),"empleats","MODIFICAR",oldvals);
    
END
// DELIMITER ;

DROP TRIGGER IF EXISTS auditar_DEL
DELIMITER //
CREATE TRIGGER auditar_DEL AFTER DELETE
    ON empleats FOR EACH ROW 
BEGIN
    INSERT INTO auditoria_taules(usuari,data,taula,accio,valors)
    VALUES (USER(),NOW(),"empleats","ELIMINAR",OLD.empleat_id);
END;
// DELIMITER ;

INSERT INTO empleats(empleat_id,cognoms,email,data_contractacio,feina_codi)
    VALUES (1000,"test","algo@email.com","2022-01-01","AC_MGR");

UPDATE empleats
    SET nom="un hola",
        telefon="938475645"
WHERE empleat_id=1000;

DELETE FROM empleats
WHERE empleat_id=1000;

SELECT * FROM empleats;
SELECT * FROM auditoria_taules

-- Exercici 4

DROP TRIGGER IF EXISTS trg_salari_empleats;
DELIMITER //
CREATE TRIGGER trg_salari_empleats BEFORE UPDATE ON empleats FOR EACH ROW
BEGIN
    DECLARE vSalariMin DECIMAL(8,2);
    DECLARE vSalariMax DECIMAL(8,2);

    SELECT salari_min,salari_max INTO vSalariMin,vSalariMax
    FROM feines
    WHERE feina_codi = NEW.feina_codi;


        IF(NEW.salari < vSalariMin OR NEW.salari > vSalariMax) THEN
            SET NEW.salari = OLD.salari;

    END IF;
END // DELIMITER;

DELIMITER //
CREATE TRIGGER trg_salari_empleats_Insert BEFORE INSERT ON empleats FOR EACH ROW
BEGIN
    DECLARE vSalariMin DECIMAL(8,2);
    DECLARE vSalariMax DECIMAL(8,2);

    SELECT salari_min,salari_max INTO vSalariMin,vSalariMax
    FROM feines
    WHERE feina_codi = NEW.feina_codi;

    IF(NEW.salari < vSalariMin OR NEW.salari > vSalariMax) THEN
            SET NEW.salari = vSalariMin;
        SIGNAL SQLSTATE '43000' SET MESSAGE_TEXT = "El salari introduit no compleix el rang de salari de la feina codi";
    END IF;

END
// DELIMITER ;

-- Exercici 5


ALTER TABLE departaments
    ADD COLUMN num_empleats INT DEFAULT 0;

DELIMITER //
CREATE FUNCTION spComptarEmpleats(depCodi INT) RETURNS INT
BEGIN

    DECLARE numEmpleats INT DEFAULT 0;

    SELECT COUNT(*) INTO numEmpleats
    FROM empleats
    WHERE departament_id = depCodi;

    RETURN numEmpleats;
END

// DELIMITER;

DELIMITER //
CREATE TRIGGER contarEmpleats AFTER INSERT ON empleats FOR EACH ROW
BEGIN
    
    UPDATE departaments
        SET num_empleats=spComptarEmpleats(NEW.departament_id)
    WHERE departament_id=NEW.departament_id;
END
// DELIMITER;

-- SELECT * FROM empleats

-- INSERT INTO empleats(empleat_id,cognoms,email,data_contractacio,feina_codi,departament_id)
--     VALUES (1002,"test","a@email.com","2022-01-01","AC_MGR",1);

-- DELETE FROM empleats
-- WHERE empleat_id > 211

