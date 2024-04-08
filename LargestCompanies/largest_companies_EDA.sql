-- Exploration of LargestCompanies database

-- Start by exploring TopCompanies table
USE LargestCompanies;

-- The type of the prices columns were checked and all of them are integer values.
-- However, they are lack of primary keys.

ALTER TABLE PrimaryValues
CHANGE COLUMN MyUnknownColumn ID INT;

ALTER TABLE PrimaryValues 
ADD PRIMARY KEY (ID); 

ALTER TABLE MarketValues
CHANGE COLUMN MyUnknownColumn ID INT;

ALTER TABLE MarketValues 
ADD PRIMARY KEY (ID); 

SELECT *
FROM PrimaryValues;

-- COMPANY LEVEL
-- 1
-- find the top 10 companies in terms of revenue

SELECT *
FROM PrimaryValues
ORDER BY revenue DESC
LIMIT 10;

-- 2
-- Repeat the same query above for all the three features and create a table from them to see if any company shows up in all the top 10 lists. 

-- create table for top 10 companies in revenue
DROP TABLE IF EXISTS LargestCompanies.revenue10;

CREATE TABLE revenue10
AS SELECT *
FROM PrimaryValues
ORDER BY revenue DESC
LIMIT 10;

-- create table for top 10 companies in profit
DROP TABLE IF EXISTS LargestCompanies.profits10;

CREATE TABLE profits10
AS SELECT *
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 10;

-- create table for top 10 companies in assets
DROP TABLE IF EXISTS LargestCompanies.assets10;

CREATE TABLE assets10
AS SELECT *
FROM PrimaryValues
ORDER BY assets DESC
LIMIT 10;

-- see the intersection of the three tables created above
SELECT *
FROM profits10 p10 
JOIN revenue10 r10
     ON p10.ID = r10.ID 
JOIN (SELECT * FROM assets10 ) a10
     ON a10.ID = r10.ID;

-- Comment:
-- There is no company showing up in all the three values' top 10. 
-- When we limit results to the top 30, we see three companies showing up in all.

-- 3
-- find the proportion of profits from the revenue and see which companies make the most profit from its revenue (viz)

SELECT ID, "rank", organizationName, country, revenue, profits, profits / revenue * 100 AS PrftRevPerc
FROM PrimaryValues
ORDER BY PrftRevPerc DESC;

-- 4
-- Join table with MarketValues table 
-- How many times market value do companies have than their revenue?

SELECT pm.organizationName, pm.revenue, mv.marketValue, mv.marketValue / pm.revenue AS mv_over_r
FROM PrimaryValues pm
JOIN MarketValues mv ON pm.ID = mv.ID
ORDER BY mv_over_r DESC;

-- Compare this table with the top 10 countries in market value
-- top 10 countries in market value
SELECT pm.organizationName, mv.marketValue
FROM MarketValues mv
JOIN PrimaryValues pm ON pm.ID = mv.ID
ORDER BY mv.marketValue DESC
LIMIT 10;

-- COUNTRY LEVEL
-- 1
-- How many unique countries are in the list? 
-- (to compare the number with the total number of countries in the world, which is 195)

SELECT DISTINCT country
FROM PrimaryValues;

-- 2
-- How many companies from a country is in the dataset? (proportion of companies by countries) (viz-bars)

SELECT country, COUNT(country)
FROM PrimaryValues
GROUP BY country;

-- 3 
-- Find the running sum of revenue after partitioning by country.

SELECT country, organizationName, revenue,
SUM(revenue) OVER (PARTITION BY country ORDER BY organizationName) RunningSum
FROM PrimaryValues;

-- 4
-- What is the most profitting countries among the top 50 profitting companies?  (viz-worldheatmap)

-- solution with CTE
WITH top50profitingcountry (country, profits) 
AS 
(SELECT country, profits
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 50)
SELECT country, COUNT(country) AS "count"
FROM top50profitingcountry
GROUP BY country
ORDER BY count DESC;

-- solution with a subquery
SELECT country, COUNT(country) AS count
FROM (SELECT country
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 50) AS subquery_pm
GROUP BY country
ORDER BY count DESC;


-- create view of the query above
CREATE VIEW top50profitingcountry as
SELECT country, COUNT(country) as count
FROM (SELECT country
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 50) as subquery_pm
GROUP BY country
ORDER BY count DESC;



