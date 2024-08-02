DROP PROCEDURE IF EXISTS InsertRatings;
DELIMITER $$

CREATE PROCEDURE InsertRatings()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE batch_size INT DEFAULT 100;  -- Number of records per batch

    WHILE i <= 1000000 DO
        INSERT INTO Ratings (user_id, movie_id, rating)
        SELECT
            i + n AS user_id,
            1 AS movie_id,  -- Fixed movie_id
            FLOOR(1 + (RAND() * 10)) AS rating  -- Random rating between 1 and 10
        FROM (
            SELECT @n := @n + 1 AS n
            FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) t1,
                 (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) t2,
                 (SELECT @n := -1) t0
        ) AS numbers
        WHERE i + n <= i + batch_size;

        SET i = i + batch_size;

        COMMIT;  -- Commit after each batch
    END WHILE;
END$$

DELIMITER ;

CALL InsertRatings();
