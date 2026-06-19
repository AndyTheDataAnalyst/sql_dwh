/*
==========================================
Database and Schemas
==========================================
Purpose: 
	This script checks whether the "DataWarehouse" database already exists. If it does, it gets dropped and rebuilt from scratch.

WARNING: 
	Running this script will drop the entire "DataWarehouse" database if it already exists and ALL EXISTING DATA WILL BE DELETED!
*/


USE master;

DROP DATABASE IF EXISTS DataWarehouse; -- Drop the database if it already exists

CREATE DATABASE DataWarehouse; -- Create data warehouse


/* 
=============================================
UPDATED QUERY
=============================================
In this update, we are going to nest two schemas (database and layer) within one another using multi-schema isolation: DataWarehouse and Bronze 

We are currently working with three tables within the bronze layer, named the exact way the table was provided to us by the client.
Client provided tables are:
	- customer_info : sensitive customer-related information also containing their churn rate
    - interaction_info : call details that contain basic call center KPIs and metrics
    - agent_info: agent information
    
WARNING: This query will drop your tables if they already exist in your database and rebuild them from scratch!

*/


USE DataWarehouse; -- enter the DataWarehouse schema.

CREATE SCHEMA IF NOT EXISTS bronze;

/* create crm tables in bronze layer. */
DROP TABLE IF EXISTS bronze.crm_customer_info_churn; -- Drop the table if it exists and build from scratch
CREATE TABLE bronze.crm_customer_info_churn (
	customer_ID INT,
	gender VARCHAR(8),
	senior_citzen TINYINT,
	partner VARCHAR (3),
	dependents VARCHAR (3),
	tenure INT,
	phone_service VARCHAR (3),
	multiple_lines VARCHAR (20),
	internet_service VARCHAR (20),
	online_security VARCHAR (3),
	online_backup VARCHAR (3),
	device_protection VARCHAR (3),
	tech_support VARCHAR (3),
	streaming_tv VARCHAR (3),
	streaming_movies VARCHAR (3),
	contract VARCHAR (20),
	paperless_billing VARCHAR (3),
	payment_method VARCHAR (20),
	monthly_charges DECIMAL,
	total_charges DECIMAL,
	num_of_admin_tickets INT,
	num_of_tech_tickets INT,
	churn VARCHAR (3)
);
DROP TABLE IF EXISTS bronze.crm_agent_info; -- Drop the table if it exists and build from scratch
CREATE TABLE bronze.crm_agent_info (
	agent_id VARCHAR(15),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
	hire_date DATE
);
DROP TABLE IF EXISTS bronze.crm_interaction_info; -- Drop the table if it exists and build from scratch
CREATE TABLE bronze.crm_interaction_info (
	call_id VARCHAR(7),
    agent_id VARCHAR(10),
    date DATE,
    time TIME,
    wrap_up_code VARCHAR (25),
    answered TINYINT,
    resolved TINYINT,
    speed_pf_answer INT,
    aht_hhmmss TIME,
    aht_secs INT,
    agent_score INT
);

/* stored procedure */
USE bronze;

DROP PROCEDURE IF EXISTS load_bronze;

DELIMITER $$
CREATE PROCEDURE load_bronze()
BEGIN
	/* checks */
	SET @local_infile := (SELECT @@local_infile);

	SELECT @local_infile AS local_infile_status;

	-- If OFF, stop manually
	IF @local_infile = 0 THEN
		SELECT "ERROR: local_infile is OFF. Aborting load." AS msg;
		-- STOP HERE
	END IF;

	SHOW VARIABLES LIKE "local_infile"; -- check local infile exists
    
	SELECT ">> lLOADING BRONZE LAYER" AS msg;
    SELECT ">> TRUNCATING TABLES" AS msg;
    TRUNCATE TABLE bronze.crm_customer_info_churn;
    TRUNCATE TABLE bronze.crm_interaction_info;
    
    
END $$
DELIMITER ;

 /* Clear existing data and load data from local desktop into the database via symlink */
SELECT "bronze.crm_customer_info_churn (before load)" AS table_name;
LOAD DATA LOCAL INFILE "/Users/sokchim/Desktop/customer_info_churn.csv"
    INTO TABLE bronze.crm_customer_info_churn
    FIELDS TERMINATED BY ","
    LINES TERMINATED BY "\n"
    IGNORE 1 LINES;
    SELECT COUNT(*) AS row_count FROM bronze.crm_customer_info_churn;
    
SELECT "bronze.crm_interaction_info (before load)" AS table_name;
LOAD DATA LOCAL INFILE "/Users/sokchim/Desktop/interaction_info.csv" 
	INTO TABLE bronze.crm_interaction_info
	FIELDS TERMINATED BY ","
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES; -- first row has headers so ignore
    SELECT COUNT(*) FROM bronze.crm_interaction_info;
    
/* show tables */    
DROP PROCEDURE IF EXISTS show_bronze;

DELIMITER $$
CREATE PROCEDURE show_bronze()
BEGIN
	DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- stops on SQL error
    BEGIN
		SELECT " >> ERROR WHILE LOADING DATA" AS msg;
        SELECT " >> ERROR MESSAGE = " + ERROR_MESSAGE();
	END;
    
	SELECT ">>  LOADING DATA" AS msg;
    
    SET start_time = NOW();
	SELECT "bronze.crm_customer_info_churn" AS table_name;
	SELECT * FROM bronze.crm_customer_info_churn LIMIT 20;
    SET end_time = now();
    SELECT CONCAT(
		'>> LOAD DURATION [crm_customer_info_churn] = ',
		TIMESTAMPDIFF(SECOND, start_time, end_time),
		' seconds.'
	) AS msg;

	SET start_time = NOW();
	SELECT "bronze.crm_interaction_info" AS table_name;
	SELECT * FROM bronze.crm_interaction_info LIMIT 20;
    SET end_time = NOW();
    SELECT CONCAT(
		'>> LOAD DURATION [crm_customer_info] = ',
		TIMESTAMPDIFF(SECOND, start_time, end_time),
		' seconds.'
	) AS msg;
    
END $$
DELIMITER ;
