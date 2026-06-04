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
In this update, we have dropped (and removed from the script) the tables that were previously named "bronze" because we are unable to create a table within a table in MySQL Workbench. So instead, we will need to create several tables that are prefixed with "bronze" to differentiate the different layers.

We are currently working with two tables within the bronze layer, named the exact way the table was provided to us by the client.
Client provided tables are:
	- customer_info : sensitive customer-related information also containing their churn rate
    - interaction_info : call details that contain basic call center KPIs and metrics
    
WARNING: This query will drop your tables if they already exist in your database and rebuild them from scratch!

*/


USE DataWarehouse; -- enter the DataWarehouse schema.

DROP TABLE IF EXISTS bronze; -- drop the bronze table we created before if it hasn't been removed already.

-- create table for customer_info_churn in DataWarehouse Schema. Since the data is MOSTLY for internal business operations and contains sensitive details like customer names, invoices, and billing, we will use the erp prefix.

DROP TABLE IF EXISTS `bronze_erp_customer_info_churn`; -- Drop the table if it exists and build from scratch
CREATE TABLE bronze_erp_customer_info_churn (
	customer_ID INT,
	gender VARCHAR(8),
	senior_citzen INT,
	partner VARCHAR (3),
	dependents VARCHAR (3),
	tenure INT,
	phone_service VARCHAR (3),
	multiple_lines VARCHAR (20),
	service_kind VARCHAR (20),
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

/* create table for interaction details in bronze layer. Since the data is client-facing, we will use the crm prefix. */
DROP TABLE IF EXISTS `bronze_crm_interaction_info`; -- Drop the table if it exists and build from scratch
CREATE TABLE bronze_crm_interaction_info (
	call_id VARCHAR(6),
	date DATE,
	time TIME,
	topic VARCHAR(25),
	answered VARCHAR(1),
	resolved VARCHAR(1),
	speed_of_answer INT,
	aht_hhmmss TIME,
	avg_handling_time INT,
	csat INT
);


/* Load data from local desktop into the database */
LOAD DATA LOCAL INFILE "/Users/sokchim/Desktop/customer_info_churn.csv" -- nested folders on MacOS fixed via symlink on command line
	INTO TABLE bronze_erp_customer_info_churn
    FIELDS TERMINATED BY ","
    LINES TERMINATED BY "\n"
    IGNORE 1 LINES; -- first row has headers so ignore

SHOW VARIABLES LIKE 'local_infile'; -- check local infile permissions exist
SELECT * FROM bronze_erp_customer_info_churn LIMIT 20; -- return loaded data
