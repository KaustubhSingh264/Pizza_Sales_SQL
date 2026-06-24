CREATE TABLE order_details (
    order_details_id INT,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);

CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR(50),
    size VARCHAR(5),
    price NUMERIC(5,2)
);

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients TEXT
);



select * from pizza_types
limit 5;


select * from orders
limit 5;


select * from order_details
limit 5;


select *from pizzas
limit 5;




--1/ RETRIVE THE TOTAL NUMBER OF ORDERS PLACED--
SELECT COUNT(order_id) AS Total_Order FROM orders



--2/Calculate the total revenue generated from pizza sales.

SELECT SUM(os.quantity*p.price)  AS total_revenue
FROM order_details AS os
JOIN pizzas p ON os.pizza_id=p.pizza_id



--3/Identify the highest-priced pizza.
SELECT pt.name,
       p.price
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


--4/Identify the most common pizza size ordered.

SELECT p.size,COUNT(p.size) FROM pizzas AS p
JOIN order_details od ON p.pizza_id=od.pizza_id
GROUP BY p.size
ORDER BY  COUNT(p.size) DESC


--5/List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name,SUM(od.quantity) FROM order_details AS od
JOIN pizzas p ON od.pizza_id=p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(od.quantity) DESC
LIMIT 5;


--Intermediate:
--6/Join the necessary tables to find the total quantity of each pizza category ordered.


SELECT pt.category,SUM(od.quantity)FROM pizza_types AS pt
JOIN pizzas p ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details od ON p.pizza_id=od.pizza_id
GROUP BY  pt.category
ORDER BY SUM(od.quantity) DESC


--7/Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM time) AS hour,
       COUNT(order_id) AS orders_per_hour
FROM orders
GROUP BY EXTRACT(HOUR FROM time)
ORDER BY  count(order_id) desc;



--8/Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity),2)AS avg_pizza_per_day
FROM
(SELECT o.date,SUM(od.quantity) AS quantity FROM orders AS o
JOIN order_details od on o.order_id=od.order_id
GROUP BY o.date) 



--9/Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name,round(SUM(od.quantity*p.price),0) AS revenue 
FROM order_details AS od
JOIN pizzas p ON od.pizza_id=p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

 
 
                                  --Advance--


--10/Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category,
ROUND(SUM(p.price*od.quantity)*100/
      ( SELECT SUM(p.price * od.quantity) 
       FROM order_details od
       JOIN pizzas p
       ON od.pizza_id = p.pizza_id),2) 
AS percent_contri
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY percent_contri DESC;



--11/Analyze the cumulative revenue generated over time.
SELECT date,revenue,
SUM(revenue) OVER (ORDER BY date) AS cumulative_sum
from
    (SELECT o.date,SUM(p.price*od.quantity) AS revenue 
	 FROM orders AS o
     JOIN order_details od ON o.order_id=od.order_id
     JOIN pizzas p ON od.pizza_id=p.pizza_id
     GROUP BY o.date
     ORDER BY o.date)




--12/Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT * FROM
             (
			  SELECT pt.category,pt.name, SUM(p.price*od.quantity) AS revenue,
              RANK() OVER(partition by pt.category
              ORDER BY SUM(p.price * od.quantity)DESC) AS rn 
              FROM order_details AS od
              JOIN pizzas p ON od.pizza_id=p.pizza_id
              JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
              GROUP BY pt.category,pt.name
			  )
WHERE rn<=3




