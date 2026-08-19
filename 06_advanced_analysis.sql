USE ecommerce_sales_db;


-- =====================================================
-- 1. CTE: Product Revenue
-- =====================================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name
)
SELECT *
FROM product_revenue
ORDER BY revenue DESC;


-- =====================================================
-- 2. Rank Products by Revenue
-- =====================================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM product_revenue;


-- =====================================================
-- 3. Dense Rank Products
-- =====================================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM product_revenue;


-- =====================================================
-- 4. Monthly Revenue
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
-- 5. Monthly Revenue Growth using LAG()
-- =====================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY month;


-- =====================================================
-- 6. Monthly Revenue Growth Percentage
-- =====================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
revenue_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_month_revenue,
    ROUND(
        100 * (revenue - previous_month_revenue)
        / previous_month_revenue,
        2
    ) AS growth_percentage
FROM revenue_with_previous
ORDER BY month;


-- =====================================================
-- 7. Customer Revenue Ranking
-- =====================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS customer_rank
FROM customer_revenue;


-- =====================================================
-- 8. High Value Customers
-- =====================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    revenue
FROM customer_revenue
WHERE revenue >= 50000
ORDER BY revenue DESC;


-- =====================================================
-- 9. Customer Order Frequency
-- =====================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;


-- =====================================================
-- 10. Repeat Customer Identification
-- =====================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 1;


-- =====================================================
-- 11. Customer Lifetime Value (Simple CLV)
-- =====================================================

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.selling_price) AS customer_lifetime_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_lifetime_value DESC;


-- =====================================================
-- 12. Customer Segmentation
-- =====================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    revenue,
    CASE
        WHEN revenue >= 60000 THEN 'High Value'
        WHEN revenue >= 30000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_revenue
ORDER BY revenue DESC;


-- =====================================================
-- 13. Top Product in Each Category
-- =====================================================

WITH product_revenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category, p.product_id, p.product_name
),
ranked_products AS (
    SELECT
        category,
        product_name,
        revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS category_rank
    FROM product_revenue
)
SELECT
    category,
    product_name,
    revenue
FROM ranked_products
WHERE category_rank = 1
ORDER BY category, revenue DESC;


-- =====================================================
-- 14. Revenue Contribution Percentage
-- =====================================================

WITH product_revenue AS (
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
)
SELECT
    product_name,
    revenue,
    ROUND(
        100 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_contribution_percentage
FROM product_revenue
ORDER BY revenue DESC;


-- =====================================================
-- 15. Customer Revenue vs Average Customer Revenue
-- =====================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.selling_price) AS revenue
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    revenue,
    ROUND(
        (SELECT AVG(revenue)
         FROM customer_revenue),
        2
    ) AS average_customer_revenue
FROM customer_revenue
ORDER BY revenue DESC;
