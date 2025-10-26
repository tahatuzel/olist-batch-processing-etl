USE ROLE SYSADMIN;
USE SCHEMA olist_dw.olist_analytics;

CREATE OR REPLACE PROCEDURE LOAD_DIMENSION_TABLES_PROC()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    
    
    
    COPY INTO customer_dim
    FROM @s3_stage/customer_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO order_status_dim
    FROM @s3_stage/order_status_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO payment_type_dim
    FROM @s3_stage/payment_type_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO product_dim
    FROM @s3_stage/product_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO review_dim
    FROM @s3_stage/review_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO seller_dim
    FROM @s3_stage/seller_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';
    
    
    COPY INTO date_dim
    FROM @s3_stage/date_dimension
    FILE_FORMAT = (TYPE = 'PARQUET')
    MATCH_BY_COLUMN_NAME= CASE_INSENSITIVE
    PATTERN = '.*\.parquet';



END;
$$;