-- # created the database 
CREATE database pizza_runner;

-- # using the database
use pizza_runner;

-- # creating the tables and inserting values in thier respective tables
CREATE TABLE runners 
(
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date)
VALUES
  (1, "2021-01-01"),
  (2, "2021-01-03"),
  (3, "2021-01-08"),
  (4, "2021-01-15");



CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');



CREATE TABLE runner_orders (
	order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');



CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');



CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');



CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
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
  
  -- Before we go to question, some table have missing and null values so for that,
  -- we need to clean and manipulate the data where is required
  -- creating a copy of the customer_orders table, so that we are not changing the raw data which is provided to us
create table clean_customer_orders as
select order_id, customer_id, pizza_id,
		case 
			when exclusions is null or exclusions = 'null' then null
            else exclusions
            end exclusions,
		case
			when extras is null or extras ='null' then null
            else extras
            end extras,
		order_time
from customer_orders;


-- Before we go to question, some table have missing and null values so for that,
  -- we need to clean and manipulate the data where is required
-- creating a copy of the customer_orders table 
drop table clean_runners_order;
create table clean_runners_order as
select order_id, runner_id,
		cast(case when pickup_time like 'null' then null 
			else pickup_time 
		end as datetime)  as pickup_time,
        cast(case when distance = 'null' or distance is null then null
			when distance like '%km' then trim('km' from distance)
			else distance
		end as float) as distance,
        case when duration like 'null' then null
			when duration like '%mins' then trim('mins' from duration)
            when duration like '%minute' then trim('minute' from duration)
            when duration like '%minutes' then trim('minutes' from duration)
			else duration 
		end as duration,
        case when cancellation in ('', 'null', 'NaN') then Null
			else cancellation
		end as cancellation
from runner_orders;
-- # here cast() helps us to convert the property of the column
select * from clean_runners_order;

-- changing the column's property using alter and modify command
alter table clean_runners_order
modify column duration int;


  -- Question_1: How many pizzas were ordered?
  select count(order_id) as total_order
  from customer_orders;
  
  -- Question_2: How many unique customer orders were made?
  select count(distinct order_id) as unique_cust
  from clean_customer_orders;
  
-- Question_3: How many successful orders were delivered by each runner?
select runner_id, count(order_id) as succ_orders
from clean_runners_order
where cancellation is null
group by runner_id;

-- Question_4: How many of each type of pizza was delivered?
select pn.pizza_name, count(*) as delivered_pizza
from clean_customer_orders as co
join clean_runners_order as ro on co.order_id = ro.order_id
join pizza_names as pn on co.pizza_id = pn.pizza_id
where ro.cancellation is null
group by pn.pizza_name;

-- Question_5: How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, 
		sum( case when pizza_id = 1 then 1 else 0 end) Meatlover,
        sum( case when pizza_id = 2 then 1 else 0 end) Vegetarian
from clean_customer_orders
group by customer_id;

-- Question_6: What was the maximum number of pizzas delivered in a single order?
select max(pizza_count) as max_delivered_pizza
from (
		select co.order_id, count(co.pizza_id) as pizza_count
        from clean_customer_orders as co
        join clean_runners_order as ro
        on co.order_id = ro.order_id
        where ro.cancellation is null
        group by co.order_id
	) a;

-- Question_7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select co.customer_id,
		sum(case when exclusions != '' or extras != '' then 1 else 0 end) as changed,
        sum(case when exclusions ='' or extras = '' then 1 else 0 end) as not_changed
from clean_customer_orders as co
join clean_runners_order as ro on co.order_id = ro.order_id
group by co.customer_id;

--  Question_8: How many pizzas were delivered that had both exclusions and extras?
select sum( case when exclusions != '' and extras != '' then 1 else 0 end) as both_add_ons
from clean_customer_orders as co
join clean_runners_order as ro
on co.order_id = ro.order_id
where ro.cancellation is null;

-- Question_9: What was the total volume of pizzas ordered for each hour of the day?
select 
	hour(order_time) as Day_hours,
    count(order_id) as pizza_count
from clean_customer_orders
group by 1
order by 2 desc;
-- # here 1 is used for Day_hours and 2 is used for Pizza_count

-- Question_10: What was the volume of orders for each day of the week?
select dayname(order_time) as Days,
		count(order_id) as pizza_count
from clean_customer_orders
group by 1
order by 2;
-- # here 1 is used for Days and 2 is used for pizza_count