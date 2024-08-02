DROP PROCEDURE IF EXISTS InsertMovies;
DELIMITER $$

CREATE PROCEDURE InsertMovies()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 10 DO
        INSERT INTO Movies (title, description, release_date, genre)
        VALUES (CONCAT('Movie ', i), 'Description of movie', '2023-01-01', 'Genre');
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL InsertMovies();
