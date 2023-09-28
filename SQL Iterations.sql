USE SAKILA;

SELECT table_name
FROM information_schema.columns
WHERE table_schema = 'sakila' 
  AND column_name = 'store_id';
  -- STORE_ID: CUSTOMER, INVENTORY, STAFF, STORE

SELECT table_name
FROM information_schema.columns
WHERE table_schema = 'sakila' 
  AND column_name = 'amount';
  -- AMOUNT: PAYMENT --> CUSTOMER (CUSTOMER_ID)

-- 1. Write a query to find what is the total business done by each store.
SELECT C.STORE_ID, SUM(P.AMOUNT) AS TOTAL FROM CUSTOMER C
JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
GROUP BY STORE_ID
ORDER BY STORE_ID ASC;

-- 2. Convert the previous query into a stored procedure.
DROP PROCEDURE IF EXISTS SALES_BY_STORE

DELIMITER //
CREATE PROCEDURE SALES_BY_STORE ()
BEGIN 
	SELECT C.STORE_ID, SUM(P.AMOUNT) AS TOTAL FROM CUSTOMER C
	JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
	GROUP BY STORE_ID
	ORDER BY STORE_ID ASC;
END;
//
DELIMITER ;

CALL SALES_BY_STORE;

-- 3. Convert the previous query into a stored procedure that takes the input for store_id and displays the total sales for that store.
DROP PROCEDURE IF EXISTS SALES_STORE

DELIMITER //
CREATE PROCEDURE SALES_STORE (IN PARAM1 VARCHAR (10))
BEGIN 
	SELECT C.STORE_ID, SUM(P.AMOUNT) AS TOTAL FROM CUSTOMER C
	JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
	WHERE C.STORE_ID COLLATE utf8mb4_general_ci = PARAM1
    GROUP BY STORE_ID
	ORDER BY STORE_ID ASC;
END;
//
DELIMITER ;

CALL SALES_STORE ("2");

-- 4. Update the previous query. Declare a variable total_sales_value of float type, that will store the returned result (of the total sales amount for the store). 
-- Call the stored procedure and print the results.
DROP PROCEDURE IF EXISTS SALES_STORE_2;

DELIMITER //
CREATE PROCEDURE SALES_STORE_2 (IN PARAM1 VARCHAR (10))
BEGIN 
    DECLARE TOTAL_SALES_VALUE FLOAT DEFAULT 0.0;
    
    SELECT SUM(P.AMOUNT) INTO TOTAL_SALES_VALUE
    FROM CUSTOMER C
    JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
    WHERE C.STORE_ID COLLATE utf8mb4_general_ci = PARAM1;
    
    SELECT C.STORE_ID, TOTAL_SALES_VALUE AS TOTAL
    FROM CUSTOMER C
    WHERE C.STORE_ID COLLATE utf8mb4_general_ci = PARAM1
    GROUP BY STORE_ID
    ORDER BY STORE_ID ASC;
	
    SELECT TOTAL_SALES_VALUE;
END;
//
DELIMITER ;

CALL SALES_STORE_2 ("1");

/* 5. In the previous query, add another variable flag. If the total sales value for the store is over 30.000, then label it as green_flag, otherwise label is as red_flag. 
Update the stored procedure that takes an input as the store_id and returns total sales value for that store and flag value.*/
DROP PROCEDURE IF EXISTS SS;

DELIMITER //
CREATE PROCEDURE SS (IN PARAM1 VARCHAR (10))
BEGIN 
    DECLARE TSV FLOAT DEFAULT 0.0;
    DECLARE FLAG VARCHAR (20);
    
    SELECT STORE_AMOUNT INTO TSV
    FROM (
		SELECT C.STORE_ID, SUM(P.AMOUNT) AS STORE_AMOUNT 
        FROM CUSTOMER C
		JOIN PAYMENT P ON C.CUSTOMER_ID = P.CUSTOMER_ID
		WHERE C.STORE_ID COLLATE utf8mb4_general_ci = PARAM1
        GROUP BY STORE_ID) SUB1;
    
    IF TSV > 32000 THEN SET FLAG = 'GREEN';
	ELSE SET FLAG = 'RED';
	END IF;
    
    SELECT TSV, FLAG;
    
END;
//
DELIMITER ;

CALL SS ("2");




