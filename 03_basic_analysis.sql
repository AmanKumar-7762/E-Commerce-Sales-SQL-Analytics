USE ecommerce_sales_db;


-- 1. Display all customers
SELECT *
FROM customers;


-- 2. Display all products
SELECT *
FROM products;


-- 3. Display only customer names and cities
SELECT 
    customer_name,
    city
FROM customers;


-- 4. Find Premium customers
SELECT *
FROM customers
WHERE customer_segment = 'Premium';


-- 5. Find products from Electronics category
SELECT *
FROM products
WHERE category = 'Electronics';


-- 6. Find products with price greater than 5000
SELECT 
    product_name,
    unit_price
FROM products
WHERE unit_price > 5000;


-- 7. Sort products by price from highest to lowest
SELECT 
    product_name,
    unit_price
FROM products
ORDER BY unit_price DESC;


-- 8. Find the cheapest products
SELECT 
    product_name,
    unit_price
FROM products
ORDER BY unit_price ASC
LIMIT 3;


-- 9. Find different customer cities
SELECT DISTINCT city
FROM customers;


-- 10. Find different payment methods
SELECT DISTINCT payment_method
FROM orders;


-- 11. Count total customers
SELECT COUNT(*) AS total_customers
FROM customers;


-- 12. Count total products
SELECT COUNT(*) AS total_products
FROM products;


-- 13. Find total orders
SELECT COUNT(*) AS total_orders
FROM orders;


-- 14. Find total completed orders
SELECT COUNT(*) AS completed_orders
FROM orders
WHERE order_status = 'Completed';


-- 15. Find total cancelled orders
SELECT COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'Cancelled';


-- 16. Find highest product price
SELECT MAX(unit_price) AS highest_price
FROM products;


-- 17. Find lowest product price
SELECT MIN(unit_price) AS lowest_price
FROM products;


-- 18. Find average product price
SELECT ROUND(AVG(unit_price), 2) AS average_price
FROM products;


-- 19. Find total quantity sold
SELECT SUM(quantity) AS total_units
FROM order_items;


-- 20. Find total sales before discounts
SELECT 
    SUM(quantity * selling_price) AS total_sales
FROM order_items;
