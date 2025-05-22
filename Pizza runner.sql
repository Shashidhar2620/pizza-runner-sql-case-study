-- Create schema and set default (SQL Server doesn't support SET search_path)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'pizza_runner')
    EXEC('CREATE SCHEMA pizza_runner');

-- Use schema in object names explicitly

-- Drop and create runners table
IF OBJECT_ID('pizza_runner.runners', 'U') IS NOT NULL
    DROP TABLE pizza_runner.runners;

CREATE TABLE pizza_runner.runners (
    runner_id INT,
    registration_date DATE
);

INSERT INTO pizza_runner.runners (runner_id, registration_date) VALUES
    (1, '2021-01-01'),
    (2, '2021-01-03'),
    (3, '2021-01-08'),
    (4, '2021-01-15');

-- Drop and create customer_orders table
IF OBJECT_ID('pizza_runner.customer_orders', 'U') IS NOT NULL
    DROP TABLE pizza_runner.customer_orders;

CREATE TABLE pizza_runner.customer_orders (
    order_id INT,
    customer_id INT,
    pizza_id INT,
    exclusions VARCHAR(10),
    extras VARCHAR(10),
    order_time DATETIME
);

INSERT INTO pizza_runner.customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
    (1, 101, 1, '', '', '2020-01-01 18:05:02'),
    (2, 101, 1, '', '', '2020-01-01 19:00:52'),
    (3, 102, 1, '', '', '2020-01-02 23:51:23'),
    (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
    (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
    (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
    (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
    (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
    (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
    (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
    (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
    (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
    (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
    (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

-- Drop and create runner_orders table
IF OBJECT_ID('pizza_runner.runner_orders', 'U') IS NOT NULL
    DROP TABLE pizza_runner.runner_orders;

CREATE TABLE pizza_runner.runner_orders (
    order_id INT,
    runner_id INT,
    pickup_time VARCHAR(19),
    distance VARCHAR(10),
    duration VARCHAR(15),
    cancellation VARCHAR(30)
);

INSERT INTO pizza_runner.runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
    (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
    (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
    (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
    (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
    (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
    (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
    (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
    (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
    (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
    (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

-- Drop and create pizza_names table
IF OBJECT_ID('pizza_runner.pizza_names', 'U') IS NOT NULL
    DROP TABLE pizza_runner.pizza_names;

CREATE TABLE pizza_runner.pizza_names (
    pizza_id INT,
    pizza_name VARCHAR(50)
);

INSERT INTO pizza_runner.pizza_names (pizza_id, pizza_name) VALUES
    (1, 'Meatlovers'),
    (2, 'Vegetarian');

-- Drop and create pizza_recipes table
IF OBJECT_ID('pizza_runner.pizza_recipes', 'U') IS NOT NULL
    DROP TABLE pizza_runner.pizza_recipes;

CREATE TABLE pizza_runner.pizza_recipes (
    pizza_id INT,
    toppings VARCHAR(100)
);

INSERT INTO pizza_runner.pizza_recipes (pizza_id, toppings) VALUES
    (1, '1, 2, 3, 4, 5, 6, 8, 10'),
    (2, '4, 6, 7, 9, 11, 12');

-- Drop and create pizza_toppings table
IF OBJECT_ID('pizza_runner.pizza_toppings', 'U') IS NOT NULL
    DROP TABLE pizza_runner.pizza_toppings;

CREATE TABLE pizza_runner.pizza_toppings (
    topping_id INT,
    topping_name VARCHAR(50)
);

INSERT INTO pizza_runner.pizza_toppings (topping_id, topping_name) VALUES
    (1, 'Bacon'),
    (2, 'BBQ Sauce'),
    (3, 'Beef'),
    (4, 'Cheese'),
    (5, 'Chicken'),
    (6, 'Mushrooms'),
    (7, 'Onions'),
    (8, 'Pepperoni'),
    (9, 'Peppers'),
    (10, 'Salami'),
    (11, 'Tomatoes'),
    (12, 'Tomato Sauce');

--A. Pizza Metrics
---1.How many pizzas were ordered?

select count(*) total_odered_pizza from pizza_runner.customer_orders

--2.How many unique customer orders were made?
select count( distinct customer_id) total_unique_order from pizza_runner.customer_orders

--3.How many successful orders were delivered by each runner?
select count(distinct [runner_id]) runner_delivered from pizza_runner.runner_orders
where [cancellation] is null

--4.How many of each type of pizza was delivered?

select count(*) types_of_prizza from pizza_runner.pizza_recipes

--5.How many Vegetarian and Meatlovers were ordered by each customer?

select [pizza_name],count(*) orders_pizza_count from pizza_runner.[pizza_names] pn
inner join pizza_runner.customer_orders co on 
pn.[pizza_id]=co.[pizza_id]
group by [pizza_name]


--6.What was the maximum number of pizzas delivered in a single order?
SELECT MAX(pizza_count) AS max_pizzas_in_order
FROM (SELECT order_id, COUNT(*) AS pizza_count
    FROM pizza_runner.customer_orders
    GROUP BY order_id) AS order_pizza_counts;


--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 select *from  pizza_runner.runner_orders

UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE TRY_CONVERT(DATETIME, pickup_time) IS NULL
  AND pickup_time IS NOT NULL;





ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN duration INT





UPDATE pizza_runner.runner_orders
SET
  distance = NULLIF(distance, 'null'),
  duration = NULLIF(duration, 'null'),
  cancellation = NULLIF(cancellation, 'null');


  UPDATE pizza_runner.runner_orders
SET distance = 
  CASE
    WHEN distance LIKE '%km' THEN TRIM(TRAILING 'km' FROM distance)
    ELSE distance
  END;

  UPDATE pizza_runner.runner_orders
SET duration = 
  CASE
    WHEN duration LIKE '%mins' THEN TRIM(TRAILING 'mins' FROM duration)
    WHEN duration LIKE '%minute' THEN TRIM(TRAILING 'minute' FROM duration)
    WHEN duration LIKE '%minutes' THEN TRIM(TRAILING 'minutes' FROM duration)
    ELSE duration
  END;


  SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
    ELSE 0
    END) AS no_change
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;

----





--8.How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?