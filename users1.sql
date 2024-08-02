-- Step 0: Check if column exists and drop if it does
SET @column_exists := (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE TABLE_NAME='Users' AND COLUMN_NAME='new_user_id');

-- Conditionally drop the column if it exists
SET @sql := IF(@column_exists, 'ALTER TABLE Users DROP COLUMN new_user_id;', 'SELECT "Column does not exist"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 1: Add a new column
ALTER TABLE Users ADD COLUMN new_user_id INT;

-- Step 2: Update the new column with values from 1 to 1,000,000 in batches
SET @row_number = 0;
SET @batch_size = 10000;
SET @max_id = (SELECT MAX(user_id) FROM Users);

DELIMITER $$

DROP PROCEDURE IF EXISTS BatchUpdateNewUserId;
CREATE PROCEDURE BatchUpdateNewUserId()
BEGIN
    DECLARE start_id INT DEFAULT 0;
    DECLARE end_id INT DEFAULT 0;
    DECLARE batch_end BOOLEAN DEFAULT FALSE;

    WHILE NOT batch_end DO
        SET start_id = end_id + 1;
        SET end_id = start_id + @batch_size - 1;

        IF end_id >= @max_id THEN
            SET end_id = @max_id;
            SET batch_end = TRUE;
        END IF;

        UPDATE Users
        SET new_user_id = (@row_number := @row_number + 1)
        WHERE user_id BETWEEN start_id AND end_id;

        COMMIT;
    END WHILE;
END$$

DELIMITER ;

CALL BatchUpdateNewUserId();

-- Step 3: Replace the user_id with the new column values in batches
SET @batch_size = 10000;
SET @max_id = (SELECT MAX(user_id) FROM Users);

DELIMITER $$
DROP PROCEDURE IF EXISTS BatchUpdateUserId;
CREATE PROCEDURE BatchUpdateUserId()
BEGIN
    DECLARE start_id INT DEFAULT 0;
    DECLARE end_id INT DEFAULT 0;
    DECLARE batch_end BOOLEAN DEFAULT FALSE;

    WHILE NOT batch_end DO
        SET start_id = end_id + 1;
        SET end_id = start_id + @batch_size - 1;

        IF end_id >= @max_id THEN
            SET end_id = @max_id;
            SET batch_end = TRUE;
        END IF;

        UPDATE Users
        SET user_id = new_user_id
        WHERE user_id BETWEEN start_id AND end_id;

        COMMIT;
    END WHILE;
END$$

DELIMITER ;

CALL BatchUpdateUserId();

-- Step 4: Drop the new column
ALTER TABLE Users DROP COLUMN new_user_id;
