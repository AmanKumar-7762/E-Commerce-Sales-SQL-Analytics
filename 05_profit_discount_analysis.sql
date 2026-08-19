USE ecommerce_sales_db;


-- 1. Gross Sales
SELECT
    SUM(oi.quantity * oi.selling_price) AS gross_sales
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- 2. Total Discount
SELECT
    SUM(discount_amount) AS total_discount
FROM orders
WHERE order_status = 'Completed';


-- 3. Net Revenue
SELECT
    SUM(oi.quantity * oi.selling_price) - 
    SUM(DISTINCT o.discount_amount) AS net_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- 4. Gross Profit
SELECT
    SUM(
        oi.quantity * (oi.selling_price - p.cost_price)
    ) AS gross_profit
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';


-- 5. Profit Margin
SELECT
    ROUND(
        100 * SUM(
            oi.quantity * (oi.selling_price - p.cost_price)
        ) /
        SUM(oi.quantity * oi.selling_price),
        2
    ) AS profit_margin_percentage
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';


-- 6. Profit by Product
SELECT
    p.product_name,
    SUM(
        oi.quantity * (oi.selling_price - p.cost_price)
    ) AS gross_profit
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY gross_profit DESC;


-- 7. Profit by Category
SELECT
    p.category,
    SUM(
        oi.quantity * (oi.selling_price - p.cost_price)
    ) AS gross_profit
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY gross_profit DESC;


-- 8. Profit Margin by Category
SELECT
    p.category,
    ROUND(
        100 * SUM(
            oi.quantity * (oi.selling_price - p.cost_price)
        ) /
        SUM(oi.quantity * oi.selling_price),
        2
    ) AS profit_margin_percentage
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY profit_margin_percentage DESC;


-- 9. Discount by Customer
SELECT
    c.customer_name,
    SUM(o.discount_amount) AS total_discount
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_discount DESC;


-- 10. Discount by Customer Segment
SELECT
    c.customer_segment,
    SUM(o.discount_amount) AS total_discount
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_segment
ORDER BY total_discount DESC;


-- 11. Cancellation Count
SELECT
    COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'Cancelled';


-- 12. Cancellation Rate
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders;


-- 13. Revenue Lost from Cancelled Orders
SELECT
    SUM(oi.quantity * oi.selling_price) AS cancelled_order_value
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Cancelled';


-- 14. Completed vs Cancelled Orders
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status;


-- 15. Product Cost vs Selling Price
SELECT
    product_name,
    unit_price,
    cost_price,
    unit_price - cost_price AS profit_per_unit
FROM products
ORDER BY profit_per_unit DESC;
