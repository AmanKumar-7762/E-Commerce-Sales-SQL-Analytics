USE ecommerce_sales_db;

-- Insert Customers
INSERT INTO customers VALUES
(1, 'Rahul Sharma', 'Mumbai', '2025-01-05', 'Premium'),
(2, 'Priya Verma', 'Delhi', '2025-01-10', 'Standard'),
(3, 'Amit Patel', 'Pune', '2025-01-15', 'Premium'),
(4, 'Sneha Joshi', 'Bangalore', '2025-02-01', 'Standard'),
(5, 'Rohan Gupta', 'Hyderabad', '2025-02-10', 'Premium');


-- Insert Products
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 65000, 52000),
(102, 'Wireless Mouse', 'Accessories', 1200, 700),
(103, 'Office Chair', 'Furniture', 7500, 5200),
(104, 'Smartphone', 'Electronics', 30000, 24000),
(105, 'Backpack', 'Accessories', 1800, 1000);


-- Insert Orders
INSERT INTO orders VALUES
(1001, 1, '2025-02-01', 'Completed', 'UPI', 1000),
(1002, 2, '2025-02-03', 'Completed', 'Card', 500),
(1003, 3, '2025-02-05', 'Completed', 'UPI', 1500),
(1004, 4, '2025-02-07', 'Cancelled', 'Card', 0),
(1005, 5, '2025-02-10', 'Completed', 'Net Banking', 800),
(1006, 1, '2025-03-01', 'Completed', 'UPI', 1200),
(1007, 3, '2025-03-05', 'Completed', 'Card', 2000);


-- Insert Order Items
INSERT INTO order_items VALUES
(1, 1001, 101, 1, 65000),
(2, 1001, 102, 2, 1200),
(3, 1002, 103, 1, 7500),
(4, 1003, 104, 1, 30000),
(5, 1004, 105, 2, 1800),
(6, 1005, 101, 1, 65000),
(7, 1006, 102, 3, 1200),
(8, 1007, 104, 2, 30000);
