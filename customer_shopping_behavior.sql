select * from customer 

-- What is the total revenue generatred by male vs female
select gender, SUM(purchase_amount) as Revenue
from customer
group by gender

--Which Customers used a discount but still spent more than average purchase amount
select customer_id, purchase_amount 
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

--Which are the top 5 products with the highest average reveiw rating 
SELECT item_purchased,
      ROUND( AVG(review_rating :: numeric),2) AS average_rating
FROM customer
GROUP BY item_purchased
ORDER BY average_rating DESC
LIMIT 5;

--Compare the Average Purchase amounts between Standard and Express Shipping
Select shipping_type,
Round(Avg(purchase_amount),2)
from customer
where shipping_type in ('Standard', 'Express')
group by shipping_type

--Do subscribed customer spend more? Compare avg spend and total revenue between subscribers and non subscribers
SELECT subscription_status,
       ROUND(AVG(purchase_amount), 2) AS average_spend,
       SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY subscription_status;

--Which 5 products have the highest percentage of purchases wehn discounts are applied 
select item_purchased,
Round(100 * SUM (CASE WHEN discount_applied = 'Yes' Then 1 Else 0 END)/Count(*), 2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5

--Segment Customers into new, returning, loyal, based on total number of previous purchases, and count of each segment 
WITH customer_type as (
select customer_id, previous_purchases,
case when previous_purchases = 1 then 'New'
when previous_purchases between 2 and 10 then 'Returning'
Else 'loyal'
End as customer_segment 
from customer)

select customer_segment, count (*) as "Number of customers"
from customer_type	
group by customer_segment

--What are the top 3 most purchased products within each category
WITH product_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS purchase_count,
        RANK() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM customer
    GROUP BY category, item_purchased
)

SELECT *
FROM product_counts
WHERE rnk <= 3;

--Are Cusotmer who are repeat customers ( purchase more than 5 times) also subcribers
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases>5
group by subscription_status

--What is the revenue of each age group 
select age_group, sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc