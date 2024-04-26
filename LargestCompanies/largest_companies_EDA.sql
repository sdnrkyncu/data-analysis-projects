-- Exploration of LargestCompanies database

-- See Tableau visualisations: https://public.tableau.com/app/profile/sudenur.koyuncu/viz/LargestCompanies_17140754034800/Dashboard1

-- Start by exploring TopCompanies table
USE LargestCompanies;

-- The types of the prices columns were checked and all of them are integer values.
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
-- Find the top 10 companies in terms of revenue.

SELECT *
FROM PrimaryValues
ORDER BY revenue DESC
LIMIT 10;

-- 2
-- Repeat the same query above for all the three features,
-- and create a table from them to see if any company shows up in all the top 10 lists. 

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
-- Find the percentile of profits from the revenue and see which companies make the most profit from their revenues. (viz)

SELECT organizationName, country, revenue, profits, TRUNCATE((profits / revenue * 100), 0) AS PrftRevPerc
FROM PrimaryValues
ORDER BY PrftRevPerc DESC
LIMIT 10;

-- 4
-- Join PrimaryValues table with MarketValues table.
-- How many times market value do companies have than their revenue?

SELECT pm.organizationName, pm.revenue, mv.marketValue, mv.marketValue / pm.revenue AS mv_over_r
FROM PrimaryValues pm
JOIN MarketValues mv ON pm.ID = mv.ID
ORDER BY mv_over_r DESC;

-- 4.5
-- Compare this table with the top 10 countries in market value.

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
-- How many companies from a country is in the dataset? (viz)

SELECT country, COUNT(country) AS 'count'
FROM PrimaryValues
GROUP BY country
ORDER BY COUNT(country) DESC;

-- 2.5
-- Find percentile of companies by countries.

SELECT country, TRUNCATE((count / 998 * 100), 1) AS percentile 
FROM (SELECT country, COUNT(country) AS 'count'
FROM PrimaryValues
GROUP BY country) AS subquery
ORDER BY percentile  DESC;

-- 3 
-- Find the running sum of revenue after partitioning by country.

SELECT country, organizationName, revenue,
SUM(revenue) OVER (PARTITION BY country ORDER BY organizationName) RunningSum
FROM PrimaryValues;

-- 4
-- What are the most profitting countries among the top 50 companies in revenue? (viz)

-- solution with CTE
WITH top50profitingcountry (country, profits, revenue) 
AS 
(SELECT country, profits, revenue
FROM PrimaryValues
ORDER BY revenue DESC
LIMIT 50)
SELECT country, SUM(profits) AS "sum_of_profits"
FROM top50profitingcountry
GROUP BY country
ORDER BY sum_of_profits DESC;

-- solution with a subquery
SELECT country, SUM(profits) AS "sum_of_profits"
FROM (SELECT country, profits, revenue
FROM PrimaryValues
ORDER BY revenue DESC
LIMIT 50) AS subquery_pm50
GROUP BY country
ORDER BY sum_of_profits DESC;

-- create view of the query above
CREATE VIEW top50profitingcountry AS
SELECT country, COUNT(country) AS 'count'
FROM (SELECT country
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 50) AS subquery_pm
GROUP BY country
ORDER BY count DESC;

-- 5
-- In the table of most profitting 100 companies,
-- compare the 10 countries which have the biggest number of companies
-- with the 10 countries which have the biggest number of profit in total (regardless of the number of companies the country have)

-- biggest number of companies
SELECT country, COUNT(country) AS 'count'
FROM (SELECT country, profits
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 100) AS subquery_pm100
GROUP BY country
ORDER BY count DESC
LIMIT 10;

-- biggest number of profit in total
SELECT country, SUM(profits) AS total_profit
FROM (SELECT country, profits
FROM PrimaryValues
ORDER BY profits DESC
LIMIT 100) AS subquery_pm100
GROUP BY country
ORDER BY total_profit DESC
LIMIT 10;

-- Comment: 
-- Only the first two countries secures their order in the both queries. 
-- There are also countries like Brazil and Taiwan that are in the list of most profiting countries in total (second query),
-- even though they have less number of companies in the table of biggest number of companies (first query).



