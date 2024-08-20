-- Question 1
SELECT *
FROM orders
WHERE order_status != 'canceled'
    AND order_purchase_timestamp >= (
        SELECT DATETIME(MAX(order_purchase_timestamp), '-3 months')
        FROM orders
    )
    AND order_estimated_delivery_date > DATETIME(order_delivered_customer_date, '+3 days');
-- Question 2
SELECT s.seller_id,
    SUM(oi.price) as total_sales
FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id
HAVING total_sales > 100000;
-- Question 3 
WITH Seller_First_Sale AS (
    SELECT oi.seller_id,
        MIN(o.order_purchase_timestamp) AS first_sale_date
    FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id
),
Latest_Date AS (
    SELECT MAX(first_sale_date) AS max_date
    FROM Seller_First_Sale
)
SELECT sfs.seller_id,
    sfs.first_sale_date,
    COUNT(oi.product_id) AS total_products_sold
FROM Seller_First_Sale sfs
    JOIN order_items oi ON sfs.seller_id = oi.seller_id
    JOIN Latest_Date ld ON sfs.first_sale_date >= DATETIME(ld.max_date, '-3 months')
GROUP BY sfs.seller_id
HAVING total_products_sold > 30;
-- Question 4
WITH Max_Order_Date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date
    FROM orders
),
Recent_Orders AS (
    SELECT o.order_id,
        c.customer_zip_code_prefix,
        o.order_purchase_timestamp
    FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        JOIN Max_Order_Date m ON o.order_purchase_timestamp >= DATETIME(m.max_date, '-12 months')
)
SELECT ro.customer_zip_code_prefix,
    AVG(r.review_score) AS avg_review_score,
    COUNT(ro.order_id) AS total_orders
FROM Recent_Orders ro
    JOIN order_reviews r ON ro.order_id = r.order_id
GROUP BY ro.customer_zip_code_prefix
HAVING total_orders > 30
ORDER BY avg_review_score ASC
LIMIT 5;