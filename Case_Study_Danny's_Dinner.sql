create database Dinner;
use Dinner;

create table sales 
( customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- What is the total amount each customer spent at the restaurant?
  select s.customer_id, sum(m.price) as Total_spent
  from sales as s
  join menu as m
  on s.product_id = m.product_id
  group by 1
  order by 2 desc;
  
  -- How many days has each customer visited the restaurant?
  select customer_id, count(distinct order_date) as Cust_visited
  from sales
  group by 1
  order by 2 desc;
  
  -- What was the first item from the menu purchased by each customer?
select s.customer_id, m.product_name, rank() over(partition by s.customer_id order by s.order_date) as rank1
 from sales as s
 join menu as m
 on s.product_id = m.product_id
group by 1;

with first_item as
( select s.customer_id,s.order_date, m.product_name, rank() over(partition by s.customer_id order by s.order_date) as rank1
		from sales as s
        join menu as m
        on s.product_id = m.product_id
)
select customer_id, product_name
from first_item
where rank1 =1
group by 1,2;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT COUNT(s.product_id) AS most_purchased, product_name
FROM sales AS s
JOIN menu AS m
   ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC;

-- Which item was the most popular for each customer?
with popular_item as
( select s.customer_id, m.product_name, count(m.product_id) as count_orders,
	dense_rank() over(partition by s.customer_id order by count(s.customer_id) desc) as top1
    from sales as s
    join menu as m on s.product_id = m.product_id
    group by 1,2
)
select customer_id, product_name, count_orders
from popular_item
where top1 = 1;

-- Which item was purchased first by the customer after they became a member?
with member_joined as
( select s.customer_id, s.product_id, s.order_date,
			row_number() over(partition by mm.customer_id order  by s.order_date) as joined
	from sales as s
    join members as mm on s.customer_id = mm.customer_id
		and s.order_date > mm.join_date
)
select customer_id, product_name, order_date
from member_joined as mj
join menu as m on mj.product_id = m.product_id
where joined = 1
order by 1;

-- Which item was purchased just before the customer became a member?
with member_joined_before as
( select s.customer_id, s.product_id, s.order_date,
			row_number() over(partition by mm.customer_id order  by s.order_date) as joined
	from sales as s
    join members as mm on s.customer_id = mm.customer_id
		and s.order_date < mm.join_date
)
select customer_id, product_name, order_date
from member_joined_before as mj
join menu as m on mj.product_id = m.product_id
where joined = 1;

-- What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as total_unit, sum(m.price) as total_amount
from sales as s
join menu as m on s.product_id = m.product_id
join members as mm on s.customer_id = mm.customer_id and mm.join_date > s.order_date
group by 1
order by 1;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as 
( select m.product_id,
		case when product_id = 1 then price*10
        else price*20
        end as gain_points
	from menu as m
)
select s.customer_id, sum(p.gain_points) as total_points
from sales as s
join points as p on s.product_id = p.product_id
group by 1
order by 1;