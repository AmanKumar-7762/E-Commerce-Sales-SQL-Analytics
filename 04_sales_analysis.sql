USE ecommerce_sales_db;


-- 1. Display orders with customer names
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status,
    o.payment_method
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;


-- 2. Display order details with product names
SELECT
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.selling_price
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id;


-- 3. Calculate revenue for each order
SELECT
    o.order_id,
    SUM(oi.quantity * oi.selling_price) AS order_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.order_id;


-- 4. Total revenue
SELECT
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- 5. Revenue by product
SELECT
    p.product_name,
    SUM(oi.quantity * oi.selling_price) AS revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;


-- 6. Revenue by category
SELECT
    p.category,
    SUM(oi.quantity * oi.selling_price) AS revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;


-- 7. Units sold by product
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC;


-- 8. Find products selling more than 1 unit
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) > 1
ORDER BY units_sold DESC;


-- 9. Revenue by customer
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;


-- 10. Customer order count
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;


-- 11. Repeat customers
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1;


-- 12. Revenue classification using CASE WHEN
SELECT
    c.customer_name,
    SUM(oi.quantity * oi.selling_price) AS revenue,
    CASE
        WHEN SUM(oi.quantity * oi.selling_price) >= 50000
            THEN 'High Value'
        WHEN SUM(oi.quantity * oi.selling_price) >= 20000
            THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC;


-- 13. Revenue by customer segment
SELECT
    c.customer_segment,
    SUM(oi.quantity * oi.selling_price) AS revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_segment
ORDER BY revenue DESC;


-- 14. Payment method analysis
SELECT
    o.payment_method,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.selling_price) AS revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.payment_method
ORDER BY revenue DESC;


-- 15. Order status analysis
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;
