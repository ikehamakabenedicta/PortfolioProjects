SELECT *
  FROM [Datakliq].[dbo].[international-breweries]

--I.	Within the space of the last three years, what was the profit worth of the breweries, inclusive of the anglophone and the francophone territories?

SELECT p.Territories, Sum(p.profit) as Total_Profit
from(
select
    CASE
        WHEN Countries IN ('Ghana', 'Nigeria', 'Benin') THEN 'Anglophone'
        WHEN Countries IN ('Togo', 'Senegal') THEN 'Francophone'
        ELSE 'Unknown'
    END AS  Territories, *
FROM [Datakliq].[dbo].[international-breweries]
) p
group by p.Territories;


SELECT q.Territories, SUM(profit_2017) as total_profit_2017, SUM(profit_2018) as total_profit_2018, SUM(profit_2019) as total_profit_2019
FROM (
    SELECT
        CASE
            WHEN years = '2017' THEN p.profit
            ELSE 0
        END as profit_2017,
        CASE
            WHEN years = '2018' THEN p.profit
            ELSE 0
        END as profit_2018,
        CASE
            WHEN years = '2019' THEN p.profit
            ELSE 0
        END as profit_2019,
        Territories
    FROM (
        SELECT
            CASE
                WHEN Countries IN ('Ghana', 'Nigeria', 'Benin') THEN 'Anglophone'
                WHEN Countries IN ('Togo', 'Senegal') THEN 'Francophone'
                ELSE 'Unknown'
            END AS Territories, *
        FROM [Datakliq].[dbo].[international-breweries]
    ) p
) q
GROUP BY q.Territories;

----------------------------------------------------------------------------------------------------------------------------------------------
---II. Compare the total profit between these two territories in order for the territory manager, Mr. Stone made a strategic decision that will aid profit maximization in 2020. 

SELECT Territory, SUM(profit) as Total_Profit
FROM (
    SELECT
        CASE
            WHEN Countries IN ('Ghana', 'Nigeria', 'Benin') THEN 'Anglophone'
            WHEN Countries IN ('Togo', 'Senegal') THEN 'Francophone'
            ELSE 'Unknown'
        END AS Territory, profit
    FROM [Datakliq].[dbo].[international-breweries]
) p
GROUP BY Territory;

-----------------------------------------------------------------------------------------------------------------------------------
---III.Country that generated the highest profit in 2019 

SELECT TOP 1 Countries, SUM(profit) as Total_Profit_2019
FROM [Datakliq].[dbo].[international-breweries]
WHERE years = '2019'
GROUP BY Countries
ORDER BY Total_Profit_2019 DESC;

---------------------------------------------------------------------------------------------------------------------------------
---IV.	Help him find the year with the highest profit

SELECT TOP 1 years, SUM(profit) as Highest_Profit
FROM [Datakliq].[dbo].[international-breweries]
GROUP BY years
ORDER BY Highest_Profit DESC;

------------------------------------------------------------------------------------------------------------------------------------------
--V.	Which month in the three years was the least profit generated?

SELECT top 1
    Months, years,
    MIN(Profit) AS Least_Profit 
FROM [Datakliq].[dbo].[international-breweries]
GROUP BY Months, years
ORDER BY Least_Profit;

------------------------------------------------------------------------------------------------------------------------
--VI.	What was the minimum profit in the month of December 2018?

SELECT 
    MIN(Profit) AS Minimum_Profit_December_2018 
FROM [Datakliq].[dbo].[international-breweries]
WHERE Years = '2018' AND 
      CASE
        WHEN Months = 'January' THEN 1
        WHEN Months = 'February' THEN 2
        WHEN Months = 'March' THEN 3
        WHEN Months = 'April' THEN 4
        WHEN Months = 'May' THEN 5
        WHEN Months = 'June' THEN 6
        WHEN Months = 'July' THEN 7
        WHEN Months = 'August' THEN 8
        WHEN Months = 'September' THEN 9
        WHEN Months = 'October' THEN 10
        WHEN Months = 'November' THEN 11
        WHEN Months = 'December' THEN 12
      END = 12;
-------------------------------------------------------------------------------------------------

--VII.Compare the profit in percentage for each of the month in 2019 

SELECT r.Months, SUM(r.Profit_Percentage_Change) AS Total_Profit_Percentage_Change
FROM (
    SELECT DISTINCT Months, 
        (Profit - LAG(Profit) OVER (PARTITION BY Months ORDER BY Months desc)) / LAG(Profit) OVER (PARTITION BY Months ORDER BY Months desc) AS Profit_Percentage_Change
    FROM [Datakliq].[dbo].[international-breweries]
    WHERE Years = '2019'
) AS r
GROUP BY r.Months;


-------------------------------------------------------------------------------------------------------------------------------
--VIII. Which particular brand generated the highest profit in Senegal?

SELECT 
    Brands, 
    MAX(Profit) AS Highest_Profit_Senegal
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Senegal' 
GROUP BY Brands
order by Highest_Profit_Senegal desc

---------------------------------------------------------------------------------------------------------------------------------------


--BRAND ANALYSIS

--I.	Within the last two years, the brand manager wants to know the top three brands consumed in the francophone countries ***

SELECT TOP 3 Brands, COUNT(*) AS ConsumptionCount
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries IN ('Togo', 'Senegal') 
      AND Years >= YEAR(GETDATE()) - 2
GROUP BY Brands
ORDER BY ConsumptionCount DESC;


------------------------------------------------------------------------------------------------------------------------------------------

--II.	Find out the top two choice of consumer brands in Ghana

SELECT TOP 2 Brands, COUNT(*) AS Consumer_Brand_Ghana
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Ghana'
GROUP BY Brands
ORDER BY Consumer_Brand_Ghana DESC;

-----------------------------------------------------------------------------------------------------------------------------------

--III.	Find out the details of beers consumed in the past three years in the most oil rich country in West Africa.****

SELECT Brands, Years, Months, QUANTITY
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries IN ('Nigeria', 'Ghana')
      AND Years >= YEAR(GETDATE()) - 3
ORDER BY Years, Months;



---------------------------------------------------------------------------------------------------------------------------
--IV.	Favorites malt brand in Anglophone region between 2018 and 2019 

SELECT Brands, COUNT(*) AS Fav_Malt_Anglophone
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries IN ('Ghana', 'Nigeria', 'Benin') 
      AND Years BETWEEN 2018 AND 2019
      AND Brands IN ('grand malt', 'beta malt')
GROUP BY Brands
ORDER BY Fav_Malt_Anglophone DESC;



------------------------------------------------------------------------------------------------------------------
--V.	Which brands sold the highest in 2019 in Nigeria?

SELECT Brands, SUM(QUANTITY) AS Highest_Sales_2019
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Nigeria' AND Years = 2019
GROUP BY Brands
ORDER BY Highest_Sales_2019 DESC;


----------------------------------------------------------------------------------------------------------------
--VI.	Favorites brand in South South region in Nigeria

SELECT Brands, COUNT(*) AS Favorite_Brands
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Nigeria' AND Region = 'southsouth'
GROUP BY Brands
ORDER BY Favorite_Brands DESC;

----------------------------------------------------------------------------------------------------------------------------------
--VII.	Beer consumption in Nigeria

SELECT Brands, SUM(QUANTITY) AS TotalConsumption
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Nigeria'
 AND Brands IN ('budweiser', 'castle lite', 'eagle lager', 'hero', 'trophy')
GROUP BY Brands
ORDER BY TotalConsumption DESC;


-----------------------------------------------------------------------------------------------------------------------------------------
--VIII.	Level of consumption of Budweiser in the regions in Nigeria

SELECT Region, SUM(CASE WHEN Brands = 'Budweiser' THEN QUANTITY ELSE 0 END) AS BudweiserConsumption
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Nigeria'
GROUP BY Region
ORDER BY BudweiserConsumption DESC;

-----------------------------------------------------------------------------------------------------------------------------------------
--IX.	Level of consumption of Budweiser in the regions in Nigeria in 2019 (Decision on Promo)

SELECT Region, SUM(CASE WHEN Brands = 'Budweiser' THEN QUANTITY ELSE 0 END) AS BudweiserConsumption_2019
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Nigeria' AND Years = 2019
GROUP BY Region
ORDER BY BudweiserConsumption_2019 DESC;

---------------------------------------------------------------------------------------------------------------------------


--GEO-LOCATION ANALYSIS

--I.	Country with the highest consumption of beer.

SELECT top 1 Countries, SUM(QUANTITY) AS TotalConsumption_beer
FROM [Datakliq].[dbo].[international-breweries]
GROUP BY Countries
ORDER BY TotalConsumption_beer DESC


--------------------------------------------------------------------------------------------------------------------------------------------

--II.	Highest sales personnel of Budweiser in Senegal

SELECT top 1 SALES_REP, SUM(COST) AS Highest_Sales_Personnel
FROM [Datakliq].[dbo].[international-breweries]
WHERE Countries = 'Senegal' AND Brands = 'Budweiser'
GROUP BY SALES_REP
ORDER BY Highest_Sales_Personnel DESC


-----------------------------------------------------------------------------------------------------------------------------------------------

--III.	Country with the highest profit of the fourth quarter in 2019

SELECT top 1 Countries, SUM(Profit) AS Quarter_Totalprofit_2019
FROM [Datakliq].[dbo].[international-breweries]
WHERE Years = 2019 AND Months IN ('October', 'November', 'December')
GROUP BY Countries
ORDER BY Quarter_Totalprofit_2019 DESC


----------------------------------------------------------------------------------------------------------------------------------------------
--creating views

create view Quarter_Totalprofit_2019 as
SELECT top 1 Countries, SUM(Profit) AS Quarter_Totalprofit_2019
FROM [Datakliq].[dbo].[international-breweries]
WHERE Years = 2019 AND Months IN ('October', 'November', 'December')
GROUP BY Countries
ORDER BY Quarter_Totalprofit_2019 DESC;


