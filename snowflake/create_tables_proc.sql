USE ROLE SYSADMIN;
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE olist_dw;
CREATE OR REPLACE SCHEMA olist_dw.olist_analytics;

-- IMPORTANT: Set your context to the new schema
USE SCHEMA olist_dw.olist_analytics;

CREATE OR REPLACE PROCEDURE CREATE_TABLES_PROC()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
    


    -- DIMENSIONS

    CREATE OR REPLACE TABLE customer_dim(
        customer_unique_id_pk VARCHAR(50) NOT NULL PRIMARY KEY,
        customer_city VARCHAR(50),
        customer_state VARCHAR(3),
        customer_zip_code_prefix INT,
        customer_estimated_lat DOUBLE,
        customer_estimated_lng DOUBLE
    );

    CREATE OR REPLACE TABLE seller_dim(
        seller_id_pk VARCHAR(50) NOT NULL PRIMARY KEY,
        seller_zip_code_prefix INT,
        seller_city VARCHAR(50),
        seller_state VARCHAR(3),
        seller_estimated_lat DOUBLE,
        seller_estimated_lng DOUBLE
    );


    CREATE OR REPLACE TABLE product_dim(
        product_id_pk VARCHAR(50) NOT NULL PRIMARY KEY,
        product_category_name VARCHAR(50),
        product_category_name_english VARCHAR(50),
        product_name_length INT,
        product_description_length INT,
        product_photos_qty INT,
        product_weight_g INT,
        product_length_cm INT,
        product_width_cm INT,
        product_height_cm INT
    );

    CREATE OR REPLACE TABLE order_status_dim(
        order_status_id_pk INT NOT NULL PRIMARY KEY,
        order_status VARCHAR(50)
    );


    CREATE OR REPLACE TABLE payment_type_dim(
        payment_type_id_pk INT NOT NULL PRIMARY KEY,
        payment_type VARCHAR(50)
    );

    CREATE OR REPLACE TABLE date_dim(
        date_id_pk INT NOT NULL PRIMARY KEY,
        date_timestamp TIMESTAMP,
        date_year INT,
        date_month INT,
        date_month_name VARCHAR(3),
        date_day_of_month INT,
        day_of_week INT, 
        date_day_type VARCHAR(10)
    );

    CREATE OR REPLACE TABLE review_dim(
        review_id_pk VARCHAR(50) NOT NULL PRIMARY KEY,
        review_title VARCHAR(30),
        review_comment_message VARCHAR(350)
    );


    -- FACT TABLES


    CREATE OR REPLACE TABLE order_fact(
        order_id_pk VARCHAR(50) NOT NULL PRIMARY KEY,
        customer_unique_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.customer_dim (customer_unique_id_pk),
        order_status_id_fk INT
            REFERENCES olist_dw.olist_analytics.order_status_dim (order_status_id_pk),
        order_purchase_date_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        order_approved_date_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        order_delivered_carrier_date_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        order_delivered_customer_date_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        order_delivered_estimate_date_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk)
    );


    CREATE OR REPLACE TABLE review_fact(
        review_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.review_dim (review_id_pk),
        order_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.order_fact (order_id_pk),
        review_score INT,
        review_created_at_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        review_answered_at_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        
        PRIMARY KEY (review_id_fk, order_id_fk)
    );



    CREATE OR REPLACE TABLE order_item_fact(
        order_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.order_fact (order_id_pk),
        order_item_id INT,
        product_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.product_dim (product_id_pk),
        seller_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.seller_dim (seller_id_pk),
        shipping_limit_date_fk INT
            REFERENCES olist_dw.olist_analytics.date_dim (date_id_pk),
        price DOUBLE,
        freight_value DOUBLE,

        PRIMARY KEY(order_id_fk, order_item_id)
    );

    CREATE OR REPLACE TABLE payment_fact(
        order_id_fk VARCHAR(50)
            REFERENCES olist_dw.olist_analytics.order_fact (order_id_pk),
        payment_sequential INT,
        payment_type_id_fk INT
            REFERENCES olist_dw.olist_analytics.payment_type_dim (payment_type_id_pk),
        payment_value DOUBLE,
        payment_installments INT,
        PRIMARY KEY (order_id_fk, payment_sequential)
    );
    
    RETURN 'Olist_dw veri ambarı ve şeması başarıyla oluşturuldu.';

END;
$$;