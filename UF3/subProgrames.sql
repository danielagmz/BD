# enunciats de procediments

-- Exercici 1
DELIMITER //
CREATE PROCEDURE spObtenirDataUsuari ()
BEGIN
    SELECT NOW(),USER()
END
// DELIMITER ;

-- Exercici 2
DROP PROCEDURE IF EXISTS spSwapSou;
DELIMITER //
CREATE PROCEDURE spSwapSou (IN pEmpId1 INT ,IN pEmpId2 INT)
BEGIN
    DECLARE vT DECIMAL(8,2);
    -- hay que comprobar que los id existan y tambien explicar paso a paso en lenguaje natural lo que se quiere lograr
    SELECT salari INTO vT
        FROM empleats
    WHERE empleat_id=pEmpId1;

    UPDATE empleats SET salari = (SELECT salari FROM empleats WHERE empleat_id=pEmpId2)
         WHERE empleat_id=pEmpId1;
    UPDATE empleats SET salari = vT
         WHERE empleat_id=pEmpId2;
END
// DELIMITER ;

-- Exercici 3
DROP PROCEDURE IF EXISTS spSwapDep;
DELIMITER //
CREATE PROCEDURE spSwapDep (IN pEmpId1 INT ,IN pEmpId2 INT)
BEGIN

    DECLARE vT INT;

    -- obtener el departamento del empleado 1 y guardarlo en la variable temporal
    SELECT departament_id INTO vT 
        FROM empleats 
    WHERE empleat_id=pEmpId1;

    -- asignarle al empleado dos el departamento id del empleado 1 (esta guardado en la variable vT)
   UPDATE empleats
        departament_id=vT;
    WHERE empleat_id =pEmpId2;
END
// DELIMITER ;

-- Exercici  4
DROP PROCEDURE IF EXISTS spReasignarEmpleats;
DELIMITER //
CREATE PROCEDURE spReasignarEmpleats (IN pdep1 INT ,IN pdep2 INT)
BEGIN
    -- no hay que comprobarlo porque el update no hara nada si no se encuentra, si se podria comprobar que no se entre un null
    UPDATE empleats
        SET departament_id = pdep1 -- si este esta mal dara error de FK
    WHERE departament_id = pdep2; -- si este esta mal no hara nada porque no hay coincidencia con los datos
END
// DELIMITER ;

-- Exercici 5
DROP PROCEDURE IF EXISTS spLlista;
DELIMITER //
CREATE PROCEDURE spLlista ()
BEGIN
    SELECT e.empleat_id as id_empleat,e.nom as nom_empleat,d.nom as nom_departament,l.ciutat as localitzacio_dept
        FROM empleats e
        LEFT JOIN departaments d ON e.departament_id = d.departament_id
        LEFT JOIN localitzacions l ON d.localitzacio_id = l.localitzacio_id;

END
// DELIMITER ;

-- Exercici 6

DELIMITER //
CREATE PROCEDURE spInfoEmp (IN pEmpcodi INT)
BEGIN
    SELECT *
        FROM empleats
    WHERE empleat_id = pEmpcodi;
END
// DELIMITER ;

-- Exercici 7

CREATE TABLE
    logs_usuaris (
        usuari VARCHAR(100),
        data DATETIME,
    );

-- Exercici 8
DELIMITER //
CREATE PROCEDURE  spInserirlogs()
BEGIN
    INSERT INTO logs_usuaris
    SELECT CURRENT_USER(), NOW();
END
// DELIMITER ;

-- Exercici 9

DELIMITER //
CREATE PROCEDURE  spAfegirDep(pCodiDep INT,pNomDep VARCHAR(30),pCodiLoc INT)
BEGIN
    IF (spComprovarLoc(pCodiLoc)) THEN
        INSERT INTO departaments(departament_id,nom,localitzacio_id)
        VALUES(pCodiDep,pNomDep,pCodiLoc);
    ELSE
        INSERT INTO departaments(departament_id,nom,localitzacio_id)
        VALUES(pCodiDep,pNomDep,NULL);
    END IF;

END
// DELIMITER ;

CALL spAfegirDep(1,'sapa',1);

DELIMITER //
CREATE FUNCTION spComprovarLoc(pLocId INT) RETURNS BOOLEAN
NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE locExisteix BOOLEAN DEFAULT FALSE;

    SELECT EXISTS(SELECT * FROM localitzacions WHERE localitzacio_id = pLocId) INTO locExisteix;

    RETURN locExisteix;

END
// DELIMITER ;

-- Exercici 10
DROP PROCEDURE IF EXISTS spNomCognom;
-- no retorna. como hacerlo retornar
DELIMITER //
CREATE PROCEDURE spNomCognom (IN pEmpcodi INT,OUT vNom VARCHAR(20),OUT vCognom VARCHAR(25))
BEGIN
    SELECT nom,cognoms INTO vNom,vCognom 
        FROM empleats
    WHERE empleat_id=pEmpcodi;

END
// DELIMITER ;

CALL spNomCognom(100)

DROP PROCEDURE IF EXISTS spModNomCognom;
-- no retorna. como hacerlo retornar
DELIMITER //
CREATE PROCEDURE spModNomCognom (IN pEmpcodi INT,IN pNom VARCHAR(20),IN pCognom VARCHAR(25))
BEGIN

    IF (pNom IS NOT NULL AND pCognom IS NOT NULL) THEN
        UPDATE empleats
            SET nom = pNom,
                cognoms = pCognom
        WHERE empleat_id=pEmpcodi;
    END IF;

END
// DELIMITER ;

DROP PROCEDURE IF EXISTS spRegLog;
-- no retorna. como hacerlo retornar
DELIMITER //
CREATE PROCEDURE spRegLog (IN pEmpcodi INT,IN ptaula VARCHAR(20),IN pVpk VARCHAR(25))
BEGIN

    INSERT INTO logs_usuaris(usuari,data,taula,valor_pk)
        VALUES(user(),now(),ptaula,pVpk);
END
// DELIMITER ;

-- DROP PROCEDURE IF EXISTS spEliminarDeps;
-- -- no retorna. como hacerlo retornar
-- DELIMITER //
-- CREATE PROCEDURE spEliminarDeps (IN pCodi INT)
-- BEGIN

--     DELETE FROM departaments
--     WHERE departament_id=pCodi;

--     /* sol clase -> ROW_COUNT() > 0 como condicion retorna si la ultima instruccion ha modificado algun registro  */

--     IF (!spComprovarDep(pCodi)) THEN 
--         CALL spRegLog ('departaments', 'ELIMINAR', pCodi);
--     END IF;

--     -- petara por empleats

--     UPDATE empleats
--         SET id_cap=NULL -- esto no funciona 
--     WHERE empleat_id IN (SELECT empleat_id FROM empleats WHERE departament_id=pCodi)

--     -- petara por historial_feines

-- END
-- // DELIMITER ;



# enunciats de funcions

-- Exercici 1
CREATE FUNCTION spData (data DATE) RETURNS char(10)
BEGIN
	RETURN DATE_FORMAT(data,"%d-%m-%Y");
END

-- Exercici 2
DROP FUNCTION IF EXISTS spPotencia;
CREATE FUNCTION spPotencia (pbase INT,pexp INT) RETURNS INT
BEGIN
    DECLARE res INT DEFAULT 1;
    DECLARE cont INT DEFAULT 0;

    IF(pexp!=0) THEN
        WHILE(cont < pexp) DO
            SET res=res*pbase;
            SET cont=cont+1;    
        END WHILE;
    ELSE
        SET res=1;
    END IF;
	RETURN res;
END;

-- Exercici 4
DROP FUNCTION IF EXISTS spPringat;
use rrhh;
DELIMITER //
CREATE FUNCTION spPringat(pdepCodi INT) RETURNS INT
NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE vcodiEmp INT DEFAULT -1;

    IF(spComprovarDep(pdepCodi)) THEN
        SELECT empleat_id INTO vcodiEmp
            FROM empleats
        WHERE departament_id=pdepCodi AND salari=(SELECT MIN(salari)
                                                    FROM empleats 
                                                WHERE departament_id =pdepCodi)
        LIMIT 1;
    END IF;

    RETURN vcodiEmp;
END
// DELIMITER;

SELECT spPringat(20)

DELIMITER //
CREATE FUNCTION spComprovarDep(pdepId INT) RETURNS BOOLEAN
NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE depExisteix BOOLEAN DEFAULT FALSE;

    SELECT EXISTS(SELECT * FROM departaments WHERE departament_id = pdepId) INTO depExisteix;

    RETURN depExisteix;

END
// DELIMITER ;


-- Exercici 6
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
        WHEN edat BETWEEN 0 AND 1 THEN SET cat = " Auxiliar";
        WHEN edat BETWEEN 2 AND 10 THEN SET cat = "Oficial de Segona";
        WHEN edat BETWEEN 11 AND 20 THEN SET cat = "Oficial de Primera";
        ELSE SET cat = "Que es jubili!";
    END CASE;
    
    RETURN cat;
END //
DELIMITER ;

-- Exercici 7
SELECT empleat_id,nom,TIMESTAMPDIFF(YEAR, data_contractacio, CURDATE()) anys_treballats,spCategoria(empleat_id) categoria
	FROM empleats;

-- Exercici 8
use rrhh;
DROP FUNCTION IF EXISTS spEdat;

DELIMITER //
CREATE FUNCTION spEdat(pdata Date) RETURNS INT
DETERMINISTIC 
BEGIN
    DECLARE edat INT;

    IF (pdata > CURDATE()) THEN  
        SET edat = 0;
    ELSE
        SELECT TIMESTAMPDIFF(YEAR, pdata, CURDATE())
        INTO edat;
    END IF;

    RETURN edat;
END //
DELIMITER ;
 
--  Exercici 9 

DROP FUNCTION IF EXISTS spDirectors;

DELIMITER //
CREATE FUNCTION spDirectors()  RETURNS INT
DETERMINISTIC 
BEGIN
    DECLARE num INT;

    SELECT COUNT(DISTINCT id_cap)  INTO num
        FROM empleats;

    RETURN num;
END //
DELIMITER ;

SELECT spDirectors()





