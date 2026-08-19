USE ecommerce_sales_db;


-- =====================================================
-- 1. Total Orders
-- =====================================================

SELECT
    COUNT(*) AS total_orders
FROM orders;


-- =====================================================
-- 2. Completed Orders
-- =====================================================

SELECT
    COUNT(*) AS completed_orders
FROM orders
WHERE order_status = 'Completed';


-- =====================================================
-- 3. Cancelled Orders
-- =====================================================

SELECT
    COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'Cancelled';


-- =====================================================
-- 4. Cancellation Rate
-- =====================================================

SELECT
    ROUND(
        100.0 *
        SUM(CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END)
        / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders;


-- =====================================================
-- 5. Total Units Sold
-- =====================================================

SELECT
    SUM(oi.quantity) AS total_units_sold
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- =====================================================
-- 6. Total Revenue
-- =====================================================

SELECT
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- =====================================================
-- 7. Total Discount
-- =====================================================

SELECT
    SUM(discount_amount) AS total_discount
FROM orders
WHERE order_status = 'Completed';


-- =====================================================
-- 8. Net Revenue
-- =====================================================

WITH order_revenue AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.selling_price) AS revenue,
        o.discount_amount
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id, o.discount_amount
)
SELECT
    SUM(revenue) AS gross_revenue,
    SUM(discount_amount) AS total_discount,
    SUM(revenue - discount_amount) AS net_revenue
FROM order_revenue;


-- =====================================================
-- 9. Gross Profit
-- =====================================================

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


-- =====================================================
-- 10. Profit Margin
-- =====================================================

SELECT
    ROUND(
        100 *
        SUM(
            oi.quantity * (oi.selling_price - p.cost_price)
        )
        /
        SUM(
            oi.quantity * oi.selling_price
        ),
        2
    ) AS profit_margin
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';


-- =====================================================
-- 11. Average Order Value (AOV)
-- =====================================================

WITH order_revenue AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
)
SELECT
    ROUND(AVG(revenue), 2) AS average_order_value
FROM order_revenue;


-- =====================================================
-- 12. Revenue by Category
-- =====================================================

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


-- =====================================================
-- 13. Revenue by Customer Segment
-- =====================================================

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


-- =====================================================
-- 14. Repeat Customers
-- =====================================================

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS repeat_customer_list;


-- =====================================================
-- 15. Repeat Customer Rate
-- =====================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;


-- =====================================================
-- 16. Revenue by Payment Method
-- =====================================================

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


-- =====================================================
-- 17. Monthly Revenue
-- =====================================================

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * oi.selling_price) AS revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;


-- =====================================================
-- 18. Top 5 Products by Revenue
-- =====================================================

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
ORDER BY revenue DESC
LIMIT 5;


-- =====================================================
-- 19. Top 5 Customers by Revenue
-- =====================================================

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.selling_price) AS revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 5;


-- =====================================================
-- 20. Executive KPI Summary
-- =====================================================

WITH order_summary AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.selling_price) AS revenue,
        o.discount_amount
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id, o.discount_amount
),
profit_summary AS (
    SELECT
        SUM(
            oi.quantity * (oi.selling_price - p.cost_price)
        ) AS gross_profit
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.order_status = 'Completed'
)
SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Completed') AS completed_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Cancelled') AS cancelled_orders,

    ROUND(
        100.0 *
        (SELECT COUNT(*)
         FROM orders
         WHERE order_status = 'Cancelled')
        /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS cancellation_rate,

    SUM(revenue) AS gross_revenue,

    SUM(discount_amount) AS total_discount,

    SUM(revenue - discount_amount) AS net_revenue,

    (SELECT gross_profit FROM profit_summary) AS gross_profit,

    ROUND(
        100 *
        (SELECT gross_profit FROM profit_summary)
        / SUM(revenue),
        2
    ) AS profit_margin,

    ROUND(AVG(revenue), 2) AS average_order_value

FROM order_summary;
