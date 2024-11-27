select * from public."Walmart"
select payment_method,count(*) from public."Walmart" group by 1
select branch from public."Walmart"

-- Business Problems
-- 1 Find the different payment method and numbers of transactions, number of qty sold
select payment_method,count(*),sum(quantity) from public."Walmart" group by 1

-- 2 Identify the higest-rated category in each branch , displaying the branch, category avg-rating
select * from(
select category,branch,avg(rating),rank()
over (partition by branch order by avg(rating) desc ) as rank 
from public."Walmart" group by 1,2 )where rank=1

-- Q.3 Identify the busiest day for each branch based on the number of transactions
select * from(
select branch, to_char(to_date(date,'dd-mm-YYYY'),'Day')  as days,count(*),rank() over(partition by branch order by
count(*) desc) as rank  from public."Walmart" group by 1,2 ) where rank=1

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
select payment_method as payment_method,sum(quantity) as total_quantity from public."Walmart" group by 1

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
select city,category,avg(rating)  as avg_rating,min(rating) as min_rating,
max(rating) as max_rating from public."Walmart" group by 1,2

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
select category,sum(unit_price * quantity * profit_margin) as total_profit 
from public."Walmart" group by 1 order by 2 desc

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
select * from(
select branch,payment_method,count(*),rank() over (partition by branch order by count(*) desc) as rank 
from public."Walmart" group by 1,2  ) where rank =1

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
select
      branch,
case
	 when extract(hour from(time::time)) <=12 then 'Morning'
	 when extract(hour from(time::time)) <=17 then 'Afternoon'
	 else 'Evening'
	 end as shift,count(*)
from  public."Walmart" group by 1 ,2 order by 1,3 desc

-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100

with year_2022 as(
select branch,sum(unit_price*quantity) as ly_revenue from public."Walmart" where 
extract(year from to_date(date,'dd-mm-yyyy'))=2022 group by 1)

,year_2023 as(
select branch,sum(unit_price*quantity) as cy_revenue from public."Walmart" where 
extract(year from to_date(date,'dd-mm-yyyy'))=2023 group by 1)

select year_2022.branch,year_2022.ly_revenue as last_year,year_2023.cy_revenue as curr_year,
round((year_2022.ly_revenue-year_2023.cy_revenue)::numeric/year_2022.ly_revenue::numeric*100,2) as revenue_ratio
from year_2022 inner join year_2023 on 
year_2022.branch=year_2023.branch where year_2022.ly_revenue > year_2023.cy_revenue order by 4 desc limit 5













