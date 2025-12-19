CREATE DATABASE retail_analytics;
USE retail_analytics;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    country VARCHAR(50)
);

CREATE TABLE products (
    stock_code VARCHAR(20) PRIMARY KEY,
    description VARCHAR(255),
    unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
    invoice_no VARCHAR(20) PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    country VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10,2),
    revenue DECIMAL(12,2),
    PRIMARY KEY (invoice_no, stock_code),
    FOREIGN KEY (invoice_no) REFERENCES orders(invoice_no),
    FOREIGN KEY (stock_code) REFERENCES products(stock_code)
);

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE "C:\\Users\\DELL\\Downloads\\customers.csv"
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\DELL\\Downloads\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\DELL\\Downloads\\orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\DELL\\Downloads\\order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 1. Disable FK checks
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Truncate in correct order
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE products;
TRUNCATE TABLE customers;

-- 3. Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM customers;

LOAD DATA LOCAL INFILE 'C:\\Users\\DELL\\Downloads\\customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, country);

#Removing duplicates in customers table
DELETE c1
FROM customers c1
JOIN customers c2
ON c1.customer_id = c2.customer_id
AND c1.country > c2.country;

SELECT COUNT(*) FROM customers;
SELECT COUNT(DISTINCT customer_id) FROM customers;

LOAD DATA LOCAL INFILE 'C:\\Users\\DELL\\Downloads\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(stock_code, description, unit_price);

SELECT stock_code, COUNT(*)
FROM products
GROUP BY stock_code
HAVING COUNT(*) > 1;

DELETE p1
FROM products p1
JOIN products p2
ON p1.stock_code = p2.stock_code
AND p1.unit_price > p2.unit_price;


ALTER TABLE order_items DROP PRIMARY KEY;

ALTER TABLE order_items
ADD COLUMN order_item_id INT AUTO_INCREMENT PRIMARY KEY;

#Disable FK checks
SET FOREIGN_KEY_CHECKS = 0;

#Drop FK constraints on order_items
SHOW CREATE TABLE order_items;

ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_1;
ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_2;

#Redesign Primary Key Correctly
ALTER TABLE order_items DROP PRIMARY KEY;

ALTER TABLE order_items
ADD COLUMN order_item_id INT AUTO_INCREMENT PRIMARY KEY;

#Recreate Foreign Keys
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (invoice_no) REFERENCES orders(invoice_no);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (stock_code) REFERENCES products(stock_code);

#Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM order_items;

#Check Table Structure
DESCRIBE order_items;

#Explicitly Map CSV Columns
LOAD DATA LOCAL INFILE 'C:/Users/DELL/Downloads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(invoice_no, stock_code, quantity, unit_price, revenue);

#Got 0 entries in orders table
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;

#Check orders Table Structure
DESCRIBE orders;

#Load orders with Explicit Column Mapping (CRITICAL)
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Downloads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(invoice_no, customer_id, order_date, country);

SET FOREIGN_KEY_CHECKS = 1;

#Verify Orders Loaded
SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 5;

#Now Load order_items
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Downloads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(invoice_no, stock_code, quantity, unit_price, revenue);

SET FOREIGN_KEY_CHECKS = 1;

SELECT COUNT(*) FROM order_items;



















