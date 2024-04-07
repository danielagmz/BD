-- Exercici 1 

use rrhh;

DROP PROCEDURE IF EXISTS spCrearCopia;
DELIMITER //
CREATE PROCEDURE spCrearCopia (pEmpId INT)
BEGIN
    
	CREATE TABLE IF NOT EXISTS empleat_copia (
		id_empleat		INT,
        nom				VARCHAR(20),
        cognoms			VARCHAR(25)
    );
    
    IF pEmpId IN (SELECT empleat_id FROM empleats) 
		THEN
			INSERT INTO empleat_copia(id_empleat,nom,cognoms)
				SELECT empleat_id,nom,cognoms
					FROM empleats
				WHERE empleat_id = pEmpId;
		ELSE 
			IF pEmpId NOT IN (SELECT valor_pk FROM logs_usuaris) THEN 
				INSERT INTO logs_usuaris(usuari,data,taula,accio,valor_pk,error)
					VALUES (user(),NOW(),"empleat_copia","COPIA_EMPL",pEmpId,1);
			ELSE 
				INSERT INTO logs_usuaris(usuari,data,taula,accio,valor_pk,error)
					VALUES (user(),NOW(),"empleat_copia","COPIA_EMPL",pEmpId,2);
			END IF;
		END IF;
END

// DELIMITER ;

-- Exercici 2

CREATE TABLE categories ( 
	codi CHAR(2) PRIMARY KEY, 
	nom VARCHAR(30), 
	quantitat SMALLINT UNSIGNED 
);
-- modificar la funcion

DROP FUNCTION IF EXISTS spCategoria;

DELIMITER //
CREATE FUNCTION spCategoria(pcodi INT) RETURNS VARCHAR(17)
DETERMINISTIC 
BEGIN
    DECLARE cat VARCHAR(17);
    DECLARE edat INT;
    
    SELECT TIMESTAMPDIFF(YEAR, data_contractacio, CURDATE()) INTO edat
    FROM empleats
    WHERE empleat_id = pcodi;
    
    CASE 
        WHEN edat BETWEEN 0 AND 1 THEN SET cat = " C1";
        WHEN edat BETWEEN 2 AND 10 THEN SET cat = "C2";
        WHEN edat BETWEEN 11 AND 20 THEN SET cat = "C3";
        ELSE SET cat = "C4";
    END CASE;
    
    RETURN cat;
END //
DELIMITER ;
-- crear el procedure

DROP PROCEDURE IF EXISTS spComptar;
DELIMITER //
CREATE PROCEDURE spComptar()
BEGIN
	
	DECLARE vId	INT;
    DECLARE vC1 INT DEFAULT 0;
    DECLARE vC2 INT DEFAULT 0;
    DECLARE vC3 INT DEFAULT 0;
	DECLARE vC4 INT DEFAULT 0;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
    
	DECLARE emp CURSOR FOR SELECT empleat_id FROM empleats;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	SET fi_curs=TRUE;
	END;

	OPEN emp;
	FETCH emp INTO vId;

	WHILE (fi_curs = FALSE) DO
		
		IF(spCategoria(vId)="C1") THEN 
			SET vC1=(vC1+1);
		ELSEIF (spCategoria(vId)="C2") THEN 
			SET vC2=(vC2+1);
        ELSEIF (spCategoria(vId)="C3") THEN 
			SET vC3=(vC3+1);
        ELSEIF (spCategoria(vId)="C4") THEN 
			SET vC4=(vC4+1);
        END IF;
        FETCH emp INTO vId;
	END WHILE;

	INSERT INTO categories(codi,nom,quantitat)
    VALUES 	("C1","Auxiliar",vC1),
			("C2","Oficial de Segona",vC2),
            ("C3","Oficial de Primera",vC3),
            ("C4","Que es jubili!",vC4);
	CLOSE emp;
END //
DELIMITER ;
