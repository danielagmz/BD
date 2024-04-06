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
	FROM empleats


 