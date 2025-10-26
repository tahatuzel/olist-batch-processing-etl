USE ROLE SYSADMIN;
USE SCHEMA olist_dw.olist_analytics;

CREATE OR REPLACE PROCEDURE LOAD_FACT_TABLES_PROC()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN

    
    COPY INTO order_fact
    FROM @s3_stage/order_fact
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO payment_fact
    FROM @s3_stage/payment_fact
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO review_fact
    FROM @s3_stage/review_fact
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO order_item_fact
    FROM @s3_stage/order_item_fact
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';


END;
$$;