-- Create table Users
CREATE TABLE Users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Create table Products
CREATE TABLE Products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  quantity INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Create table Orders
CREATE TABLE Orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  status ENUM('PENDING', 'SHIPPED', 'DELIVERED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(id)
);
CREATE INDEX idx_orders_user_id ON Orders(user_id);
-- Create table OrderDetails
CREATE TABLE OrderDetails (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  FOREIGN KEY (order_id) REFERENCES Orders(id),
  FOREIGN KEY (product_id) REFERENCES Products(id)
);
CREATE INDEX idx_orderdetails_order_id ON OrderDetails(order_id);
CREATE INDEX idx_orderdetails_product_id ON OrderDetails(product_id);

-- Seed data
INSERT INTO Users (name, email, password) VALUES
('John Doe', 'john@doe.com', 'password'),
('Jane Doe', 'jane@doe.com', 'password');

INSERT INTO Products (name, price, quantity) VALUES
('Product 1', 10.00, 100),
('Product 2', 20.00, 50),
('Product 3', 30.00, 25);

INSERT INTO Orders (user_id, status) VALUES
(1, 'PENDING'),
(2, 'PENDING');

INSERT INTO OrderDetails (order_id, product_id, quantity) VALUES
(1, 1, 5),
(1, 2, 10),
(2, 3, 2);


-- Stored procedure for adding a new order
DELIMITER //
CREATE PROCEDURE add_order(IN user_id INT)
BEGIN
  INSERT INTO Orders (user_id) VALUES (user_id);
END //
DELIMITER ;


-- Stored procedure for adding a new order detail
DELIMITER //
CREATE PROCEDURE insert_order(IN user_id INT, IN order_id INT, IN product_id INT, IN user_quantity INT)

BEGIN
  DECLARE product_quantity INT;

  START TRANSACTION;
  SELECT quantity INTO product_quantity FROM Products WHERE id = product_id FOR UPDATE;

  IF product_quantity < user_quantity THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Not enough stocks';
  END IF;

  INSERT INTO OrderDetails (order_id, product_id, quantity) VALUES (order_id, product_id, quantity);
  UPDATE Products SET quantity = quantity - user_quantity WHERE id = product_id;

  COMMIT;
END //
DELIMITER ;