/*
==========================================
Database and Schemas
==========================================
Purpose: 
	This script checks whether the "DataWarehouse" database already exists. If it does, it gets dropped and rebuilt from scratch. Afterwards, it sets up three layers within the database (bronze, silver, and gold) to organize the data as it moves through the pipeline.


USE master;

DROP DATABASE IF EXISTS DataWarehouse; -- Drop the database if it already exists

CREATE DATABASE DataWarehouse; -- Create data warehouse

USE DataWarehouse;

-- Create layers within the database: "bronze", "silver", and "gold"
CREATE TABLE bronze (
	id INT AUTO_INCREMENT PRIMARY KEY);
CREATE TABLE silver (
	id INT AUTO_INCREMENT PRIMARY KEY);
CREATE TABLE gold (
	id INT AUTO_INCREMENT PRIMARY KEY);
