select * from walmart
select count(distinct Branch) from walmart
drop table walmart

-- Business problems
-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select payment_method, count(*) as no_payments,sum(quantity) as total_qty_in_each
from walmart
group by payment_method


-- Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
select * from (
select branch , category , AVG(rating) as avg_rating,
rank() over (partition by branch order by AVG(rating) DESC) as rank
from walmart
group by 1,2
)
where rank = 1 

-- Q3: Identify the busiest day for each branch based on the number of transactions
select * 
from
( select  branch,
To_CHAR(TO_DATE(date,'DD/MM/YY'), 'Day') as fr_date,
count(*) as no_transactions , 
rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2)
where rank = 1

-- Q4: Calculate the total quantity of items sold per payment method
select payment_method,sum(quantity) as no_qty_sold
from walmart
group by 1


-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select city , category,min(rating) as min_rating,
 MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
from walmart
group by 1,2

-- Q6: Calculate the total profit for each category

select category,
sum(total * profit_margin) as profit
from walmart
group by 1

-- Q7: Determine the most common payment method for each branch 
select branch, payment_method, count(*)as no_trxns
from walmart
group by 1,2 
order by 3 desc

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN Extract(hour from(time::time)) < 12 THEN 'Morning'
        WHEN Extract(hour from(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)


WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY 1
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY 1
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue)::NUMERIC / r2022.revenue)::NUMERIC * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
