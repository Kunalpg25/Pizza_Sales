CREATE DATABASE pizzahut;

USE pizzahut;

CREATE TABLE orders
(
	Order_ID INT PRIMARY KEY,
    Order_date DATE NOT NULL,
    Order_time TIME NOT NULL
);

CREATE TABLE orders_details
(
	Order_Details_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Pizza_ID TEXT NOT NULL,
    Quantity INT NOT NULL
);

/* BASIC */ 
-- Retrieve the total number of orders placed.

SELECT COUNT(Order_ID) as Total_Orders FROM orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM((orders_details.quantity * pizzas.price)),
            2) AS Total_Revenue
FROM
    orders_details
        INNER JOIN
    pizzas ON orders_details.Pizza_ID = pizzas.pizza_ID;

-- Identify the highest-priced pizza.

SELECT MAX(price) as Highest_Priced_Pizza FROM pizzas;
SELECT pizza_types.name, pizzas.price
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_Id = pizzas.pizza_type_ID
ORDER BY pizzas.price DESC LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(orders_details.order_detailS_ID) AS Order_Count
FROM pizzas
INNER JOIN orders_details
ON pizzas.pizza_ID = orders_details.pizza_ID
GROUP BY pizzas.size
ORDER BY Order_Count DESC ;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_ID = pizzas.pizza_type_ID
INNER JOIN orders_details
ON orders_details.pizza_ID = pizzas.pizza_ID
GROUP BY pizza_types.name
ORDER BY Quantity DESC LIMIT 5;


/* INTERMEDIATE */

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category, SUM(orders_details.quantity) AS Total_Quantity
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_ID = pizzas.pizza_type_ID
INNER JOIN orders_details
ON orders_details.pizza_ID = pizzas.pizza_ID
GROUP BY pizza_types.category
ORDER BY Total_Quantity;

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(Order_time) AS Hour, COUNT(Order_ID) AS Order_Count 
FROM orders
GROUP BY HOUR(Order_time)
ORDER BY Order_Count DESC;

-- Join relevant tables to find the category-wise distribution of pizzas

SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0) AS Avg_Orders_Per_Day FROM
(SELECT orders.order_date, SUM(orders_details.quantity) AS quantity
FROM orders
INNER JOIN orders_details
ON orders.order_ID = orders_details.order_ID
GROUP BY orders.order_date) AS Order_quan;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_ID = pizzas.pizza_type_ID
INNER JOIN orders_details
ON orders_details.pizza_ID = pizzas.pizza_ID
GROUP BY pizza_types.name
ORDER BY Revenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category, ROUND((SUM(orders_details.quantity * pizzas.price)/
(SELECT 
ROUND(SUM((orders_details.quantity * pizzas.price)),2) AS Total_Revenue
FROM orders_details
INNER JOIN pizzas 
ON orders_details.Pizza_ID = pizzas.pizza_ID))*100,2) AS Revenue
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_ID = pizzas.pizza_type_ID
INNER JOIN orders_details
ON orders_details.pizza_ID = pizzas.pizza_ID
GROUP BY pizza_types.category
ORDER BY Revenue DESC;


-- Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(Revenue) OVER (ORDER BY order_date) AS Cum_Revenue
FROM
(SELECT orders.order_date, ROUND(SUM(orders_details.quantity * pizzas.price),2) AS Revenue
FROM orders_details
INNER JOIN pizzas
ON orders_details.pizza_ID = pizzas.pizza_ID
INNER JOIN orders
ON orders.order_ID = orders_details.order_ID
GROUP BY orders.order_date) AS Rev;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT category, name, revenue
FROM
(SELECT category, name, revenue,
rank() OVER(PARTITION BY category ORDER BY revenue DESC) AS Rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_ID = pizzas.pizza_type_ID
INNER JOIN orders_details
ON orders_details.pizza_ID = pizzas.pizza_ID
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE Rn <= 3;


















