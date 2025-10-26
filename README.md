# End-to-End E-Commerce Data Warehouse (Databricks, PySpark, & Snowflake)

## 1\. Project Overview

This project implements a complete, end-to-end ELT pipeline designed for a junior data engineer portfolio. It processes the [Olist E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), ingesting raw CSV files from an S3 data lake, transforming them through a Medallion Architecture using PySpark on Databricks, and finally loading them into a **Star Schema** data warehouse in Snowflake.

The entire pipeline is automated and orchestrated as a **Databricks Workflow Job**.

## 2\. Project Architecture

The pipeline follows a modern data stack architecture, separating storage, transformation, and compute.

The data flows through three main stages:

1.  **Bronze Layer (S3):** Raw, untouched CSV files are stored in an S3 bucket, acting as the single source of truth.
2.  **Silver Layer (S3):** The raw data is cleaned, validated, de-duplicated, and standardized using PySpark. The output is stored as optimized Parquet files back in S3.
3.  **Gold Layer (S3 & Snowflake):**
      * **Transformation:** The Silver data is transformed using PySpark into a **dimensional model (Star Schema)**, creating separate fact and dimension tables. These are first saved as Parquet files in S3.
      * **Load:** A Databricks notebook triggers Snowflake stored procedures to load the Gold Parquet files from S3 into the final, analytics-ready tables in the data warehouse.

## 3\. Tech Stack

  * **Data Lake:** AWS S3
  * **Transformation & Orchestration:** Databricks, Apache Spark (PySpark), Python
  * **Data Warehouse:** Snowflake
  * **Core Languages:** Python, SQL

## 4\. Pipeline Workflow

The project is orchestrated by a Databricks Job that runs a series of notebooks in sequence.

### Step 1: Bronze-to-Silver Transformation

**Notebook:** `bronze_to_silver.py`

  * **Reads:** Raw CSV files from the `s3://.../bronze/` path.
  * **Action:**
      * Applies correct data types and schemas .
      * Validates business logic .
      * Cleans string data and handles null values.
      * De-duplicates records based on primary keys.
  * **Writes:** Cleaned data as Parquet files to the `s3://.../silver/` path.

### Step 2: Silver-to-Gold Transformation

**Notebook:** `silver_to_gold.py`

  * **Reads:** Silver Parquet files from the `s3://.../silver/` path.
  * **Action:**
      * **Builds Dimension Tables:** Creates and denormalizes dimensions.
      * **Builds a Conformed Date Dimension:** Gathers all timestamp columns from the project to create a single `date_dim` table.
      * **Generates Surrogate Keys:** Uses Spark window functions to create surrogate keys for small dimensions.
      * **Builds Fact Tables:** Creates `order_fact`, `payment_fact`, etc., by joining Silver tables and looking up the new surrogate keys.
  * **Writes:** Modeled data as Parquet files to the `s3://.../gold/` path.

### Step 3: Snowflake Warehouse Load

**Notebook:** `run_snowflake_load.py`

  * **Action:** This notebook connects to Snowflake and orchestrates the final "Load" step. It calls stored procedures in the correct, dependent order.
  * **Code:**
    1.  `CALL CREATE_TABLES_PROC();`
          * Runs the DDL to create the empty star schema tables (Facts & Dimensions) with all `PRIMARY KEY` and `FOREIGN KEY` constraints.
    2.  `CALL LOAD_DIMENSION_TABLES_PROC();`
          * Loads data from the `s3://.../gold/` dimension folders into the dimension tables using the `COPY INTO` command. This step is run first to ensure referential integrity.
    3.  `CALL LOAD_FACT_TABLES_PROC();`
          * Loads data from the `s3://.../gold/` fact folders into the fact tables.

*(The SQL for the stored procedures can be found in `snowflake/ddl_and_load_procs.sql`)*

## 5\. How to Run

1.  **AWS S3:** Create an S3 bucket and upload the Olist dataset CSVs to a `bronze/` folder.
2.  **Snowflake:**
      * Create a database (`OLIST_DW`), schema (`ANALYTICS`), and a virtual warehouse.
      * Create an external S3 stage (`@s3_stage`) that points to your S3 bucket's `gold/` path.
      * Run the SQL in `snowflake/ddl_and_load_procs.sql` to create all the stored procedures.
3.  **Databricks:**
      * Import the notebooks into your Databricks workspace.
      * Store your Snowflake credentials (user, password, account) in **Databricks Secrets**.
      * Update the `snowflake_options` notebook to retrieve credentials using `dbutils.secrets.get()`.
4.  **Automation:**
      * Create a **Databricks Workflow Job**.
      * Add the notebooks as sequential tasks:
        1.  `bronze_to_silver.py`
        2.  `silver_to_gold.py`
        3.  `run_snowflake_load.py`
      * Run the job.

## 6\. Key Features & Engineering Concepts

This project demonstrates proficiency in several key data engineering concepts:

  * **End-to-End Pipeline:** Full data lifecycle management, from raw ingestion to an analytics-ready warehouse.
  * **Medallion Architecture:** Best-practice separation of data into Bronze (raw), Silver (cleaned), and Gold (modeled) layers.
  * **Dimensional Modeling:** Design and implementation of a **Star Schema**, the foundation of business intelligence, to optimize for analytical queries.
  * **Data Integrity:** Enforcement of data relationships and quality using `PRIMARY KEY` and `FOREIGN KEY` constraints in the warehouse.
  * **Idempotency:** The pipeline is designed to be re-runnable. Snowflake procedures use `CREATE OR REPLACE`, and loads can be made idempotent by adding `TRUNCATE` logic.
  * **Automation:** The entire pipeline is orchestrated and scheduled as a single Databricks Job, moving it from a script to a real-world automated process.
  * **Separation of Concerns:** A clean architecture where PySpark handles heavy transformations and Snowflake handles data loading and serving.
