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