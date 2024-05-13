#Firstly, we will calculate the current MRR (of users that are still working with us). Gladly, we have a separate column dedicated to monthly charges, which signigifantly
#simplifies the calculation. Otherwise, we would have needed to use the ARPU * Monthly Customers to calculate MRR

SELECT round(sum(MonthlyCharges), 2) as MRR
FROM churn_data
WHERE Churn = 'No';

#Next, it is essential analyse the retention rate. Gladly, we have a chyrn column,
#which indicates whether the customer has stopped using the service until the end of the month shown in the tenure column

WITH churn as (SELECT tenure, SUM(COUNT(churn)) OVER (ORDER BY tenure) AS churn_count
FROM churn_data
WHERE Churn = 'Yes'
GROUP BY tenure
ORDER BY tenure),

total_count as (
SELECT COUNT(customerID) as total
FROM churn_data)

SELECT c.tenure, ROUND((total-churn_count)/total * 100, 2) as retention_rate
FROM churn as c, 
total_count as tc
ORDER BY 1;

#As you can see, the trend seems quite unusual at a first glance, however, we should keep in mind that Telco
#is a company that provides telecommunication services, which are always needed and rarely get changed.
#The retention rate is exceptionally high (reaching 73% for customers that have lasted untill the end of their 72nd month)
#This can be explained by the specifics of the business model that telecommunication services have

#Now, since we have the retention it will be easy to calculate average lifetime of a user.
#Liftime is an integral of retention. The area under the retention curve can be calculated by
#adding all of the values (we can accomplish that because the size of a break is one month).
# We already have a query to get the retention rate, thus, it only needs to be slightly modified

with churn as (SELECT tenure, sum(COUNT(churn)) over (order by tenure) AS churn_count
FROM churn_data
WHERE Churn = 'Yes'
GROUP BY tenure
ORDER BY tenure),

total_count as (
SELECT COUNT(customerID) as total
FROM churn_data)

SELECT sum(retention_rate) as Lifetime
FROM (SELECT c.tenure, round((total-churn_count)/total, 2) as retention_rate
FROM churn as c, 
total_count as tc
order by 1) AS t;

#As we can see, the outstanding work of the Telco team has manifested in a 57 month average lifespan

#Next, we will calculate the current ARPPU. This metric easily explains the revenue that each customer
#brings to the company, allowing the stakeholders to make informed decisions regarding
#marketing and customer attraction programs. In addition, it will come in handy later on in the analysis

SELECT round(avg(Monthlycharges), 2) as ARPPU
FROM churn_data
WHERE Churn = 'No';

#Since we now have two core components of the LTV metric (ARPPU * LT), we can easily calculate it
with churn as (SELECT tenure, sum(COUNT(churn)) over (order by tenure) AS churn_count
FROM churn_data
WHERE Churn = 'Yes'
GROUP BY tenure
ORDER BY tenure),

total_count as (
SELECT COUNT(customerID) as total
FROM churn_data),
ARPPU AS (
SELECT round(avg(Monthlycharges), 2) as ARPPU
FROM churn_data
WHERE Churn = 'No'
 ), 
LT AS (
SELECT sum(retention_rate) as Lifetime
FROM (SELECT c.tenure, round((total-churn_count)/total, 2) as retention_rate
FROM churn as c, 
total_count as tc
order by 1) AS t
 )
 
 SELECT round(Lifetime * ARPPU,2) as LTV
 FROM LT, ARPPU;
 
 #As we can see, the LTV is $3518. The following metric indicates a high cost efficiency of 
 #acquiring new customers and supporting them over a prolonged period of time.
 

