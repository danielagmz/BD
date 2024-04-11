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
    VALUES  ("C1","Auxiliar",vC1),
	    	("C2","Oficial de Segona",vC2),
            ("C3","Oficial de Primera",vC3),
            ("C4","Que es jubili!",vC4);
	CLOSE emp;
END //
DELIMITER ;

use rrhh;

-- Exercici 3

ALTER TABLE departaments
	ADD COLUMN salari_avg DECIMAL(8,2);
DROP PROCEDURE IF EXISTS spAvgSalary;
DELIMITER //
CREATE PROCEDURE spAvgSalary()
BEGIN
	DECLARE vDep INT;
	DECLARE vSalary DECIMAL(8,2) DEFAULT 0;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
	DECLARE deps CURSOR FOR (SELECT DISTINCT departament_id 
									FROM empleats
									WHERE departament_id IS NOT NULL);

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	SET fi_curs=TRUE;
	END;
		
	OPEN deps;
	FETCH deps INTO vDep;
	
	WHILE NOT fi_curs DO

		SELECT AVG(salari) INTO vSalary
			FROM empleats
		WHERE departament_id = vDep;
		
		UPDATE departaments
			SET salari_avg = vSalary
		WHERE departament_id=vDep;
		
		FETCH deps INTO vDep;

	END WHILE;	

	CLOSE deps;
	
END 
// DELIMITER;

-- Exercici 4
CREATE TABLE pringats (
		empleat_id INT,
		departament_id INT,

		CONSTRAINT PK_PRINGATS PRIMARY KEY (departament_id, empleat_id)
);

DROP PROCEDURE IF EXISTS spTaulapringats;

DELIMITER // 
CREATE PROCEDURE spTaulapringats () 
BEGIN 

	DECLARE vDep INT;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
	DECLARE deps CURSOR FOR (SELECT DISTINCT departament_id 
									FROM empleats
									WHERE departament_id IS NOT NULL);

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	SET fi_curs=TRUE;
	END;

	TRUNCATE TABLE pringats;
		
	OPEN deps;
	FETCH deps INTO vDep;
	
	WHILE NOT fi_curs DO

		INSERT INTO pringats(empleat_id,departament_id)
			VALUES(spPringat(vDep),vDep);

		FETCH deps INTO vDep;

	END WHILE;

	CLOSE deps;

END 
// DELIMITER ;

-- Exercici 5

DROP PROCEDURE IF EXISTS spTaulapringats;

DELIMITER // 
CREATE PROCEDURE spTaulapringats() 
BEGIN 

	DECLARE vDep INT;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
	DECLARE deps CURSOR FOR (SELECT DISTINCT departament_id 
									FROM empleats
									WHERE departament_id IS NOT NULL);

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	SET fi_curs=TRUE;
	END;
		
	OPEN deps;
	FETCH deps INTO vDep;
	
	WHILE NOT fi_curs DO

		IF(spPringat(vDep) NOT IN(SELECT empleat_id FROM pringats)) THEN
			INSERT INTO pringats(empleat_id,departament_id)
				VALUES(spPringat(vDep),vDep);
		END IF;

		FETCH deps INTO vDep;

	END WHILE;

	CLOSE deps;

END 
// DELIMITER ;

-- Exercici 6
use rrhh;
CREATE TABLE empleats_segregats(
	id_empleat	INT,
	mes			INT
);

DROP PROCEDURE IF EXISTS spSepararEmpleats;
DELIMITER // 
CREATE PROCEDURE spSepararEmpleats() 
BEGIN 
	DECLARE vEmp INT;
	DECLARE vMesCont INT;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
	DECLARE emps CURSOR FOR (SELECT empleat_id,DATE_FORMAT(data_contractacio,'%m') from empleats);

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	SET fi_curs=TRUE;
	END;
		
	OPEN emps;
	FETCH emps INTO vEmp,vMesCont ;
	
	WHILE NOT fi_curs DO

		INSERT INTO empleats_segregats(id_empleat,mes)
			VALUES(vEmp,vMesCont);

		FETCH emps INTO vEmp,vMesCont;
	END WHILE;
		
	CLOSE emps;

END
// DELIMITER ;

CALL spSepararEmpleats();

SELECT *
	FROM empleats_segregats

-- Exercici 7

ALTER TABLE feines
	ADD COLUMN qt_historicTreballadors INT;


DROP PROCEDURE IF EXISTS spQtFeinesHist;

DELIMITER // 
CREATE PROCEDURE spQtFeinesHist() 
BEGIN 

	DECLARE vCodif CHAR(10);
	DECLARE vCountHistoric INT DEFAULT 0;
	DECLARE vCountActual INT DEFAULT 0;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
	DECLARE cursfeines CURSOR FOR (SELECT feina_codi FROM feines);

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
	SET fi_curs=TRUE;
	END;
		
	OPEN cursfeines;
	FETCH cursfeines INTO vCodif;
	
	WHILE NOT fi_curs DO
		-- contar el historico de esa feina codi
		SELECT COUNT(empleat_id ) INTO vCountHistoric
			FROM historial_feines
		WHERE feina_codi=vCodif;

		/* contar los empleados actuales en esa profesion que no 
		   esten en el historial para evitar contarlos de nuevo*/
		

		SELECT COUNT(empleat_id) INTO vCountActual
			FROM empleats e
		WHERE feina_codi=vCodif AND 
		(e.empleat_id, feina_codi) NOT IN (SELECT empleat_id, feina_codi FROM historial_feines);
		
		-- update de la tabla y reinicio de contadores
		UPDATE feines
			SET qt_historicTreballadors=vCountHistoric+vCountActual
		WHERE feina_codi=vCodif;

		SET vCountHistoric=0;
		SET vCountActual=0;

		FETCH cursfeines INTO vCodif;

	END WHILE;

	CLOSE cursfeines;

END;

-- Exercici 8

CREATE TABLE factura (
		numf INT (8) PRIMARY KEY,
		data DATETIME,
		import DECIMAL(8, 2)
) Engine = InnoDB;

CREATE TABLE linia_factura (
		numf INT (8),
		linia INT (4),
		article VARCHAR(2),
		descripcio VARCHAR(100),
		unitats INT (4),
		preuU DECIMAL(5, 2),
		PRIMARY KEY (numf, linia),
		FOREIGN KEY (numf) REFERENCES factura (numf)
) Engine InnoDB;

INSERT INTO
	factura (numf, data)
VALUES
	(1, '2012-04-30');

INSERT INTO
	linia_factura
VALUES
	(1, 1, '01', 'Pistons Wiseco', 2, 120);

INSERT INTO
	linia_factura
VALUES
	(1, 2, '02', 'Culata Scream Eagle', 1, 240);

INSERT INTO
	factura (numf, data)
VALUES
	(2, '2012-03-21');

INSERT INTO
	linia_factura
VALUES
	(2, 1, '03', 'Arbol de levas', 3, 221.5);

INSERT INTO
	factura (numf, data)
VALUES
	(3, '2012-04-28');

INSERT INTO
	linia_factura
VALUES
	(3, 1, '04', 'Centralita ThunderMax', 3, 355);

INSERT INTO
	linia_factura
VALUES
	(3, 2, '05', 'Filtro Aire K&N', 2, 60);

INSERT INTO
	linia_factura
VALUES
	(3, 3, '01', 'Pistons Wiseco', 4, 120);

DROP PROCEDURE IF EXISTS spCalcularImport;

DELIMITER // 
CREATE PROCEDURE spCalcularImport() 
BEGIN 
	
	DECLARE vFact INT DEFAULT 0;
	DECLARE vTot DECIMAL(10,2) DEFAULT 0;
	DECLARE fi_curs BOOLEAN DEFAULT FALSE;
	DECLARE facturesCurs CURSOR FOR (SELECT numf FROM factura);

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
		SET fi_curs=TRUE;
	END;
		
	OPEN facturesCurs;
	FETCH facturesCurs INTO vFact;
	
	WHILE NOT fi_curs DO

		SELECT SUM(preuU*unitats) INTO vTot
			FROM linia_factura
		WHERE numf=vFact;

		UPDATE factura
				SET import=vTot
		WHERE numf=vFact;

		SET vTot=0;

		FETCH facturesCurs INTO vFact;
	END WHILE;
	CLOSE facturesCurs;

END
DELIMITER // 

CALL spCalcularImport();

SELECT * FROM factura;