--Let's explore the products 

--Are any product prices are missing? 
SELECT COUNT
  (*) AS missing_prices 
FROM `portfolioprojects2023.MavenToys.products`  
WHERE Product_Cost IS NULL OR Product_Price IS NULL; 
--No prices are missing  

 
-- Let's get an overview of the product prices. 
SELECT 
 MIN(Product_Price) AS min_price  
 , MAX(Product_Price) AS max_price 
 , ROUND (AVG (Product_Price),2) AS avg_price 
FROM `portfolioprojects2023.MavenToys.products` ; 
--prices range from $2.99 - $39.99, with the average being $14.76. 

 
How much are total Sales? 
SELECT 
  ROUND(SUM(p.Product_Price * s.Units)) AS total_sales 
FROM `portfolioprojects2023.MavenToys.products` AS p 
  INNER JOIN `portfolioprojects2023.MavenToys.sales` AS s 
  ON p.Product_ID = s.Product_ID; 
--$14.4M  
 

-- What are the categories and how many products are in each? 
SELECT 
  Product_Category
  , COUNT(Product_Name) AS product_count  
FROM `portfolioprojects2023.MavenToys.products`   
GROUP BY Product_Category 
ORDER BY product_count DESC; 
--There are 5 categories: Toys, Games, Arts & crafts, Sports & Outdoors and Electronics. The first 4 have about the same number of products ~8. And Electronics only has 3 products. 

 
--How many stores are there, and which cities contain stores? 
SELECT 
  Store_City 
 , COUNT (DISTINCT Store_ID) AS stores 
FROM `portfolioprojects2023.MavenToys.stores`  
GROUP BY Store_City 
ORDER BY stores DESC; 
--There are 50 stores across 29 cities across Mexico, 12 cities have more than one store. 
 

--What type of locations are these stores found in? 
SELECT 
  Store_Location 
 , COUNT (DISTINCT Store_ID) AS location_type 
FROM `portfolioprojects2023.MavenToys.stores`  
GROUP BY Store_Location 
ORDER BY location_type DESC; 
--There are 4 location types (Airport, Residential, Downtown and commercial) with Downtown (with 29 stores) and commercial (with 12 stores) being most popular. 

 
--In order to narrow down potential locations let's find the 3 cities with the most sales. 
SELECT 
  st.Store_City
  , ROUND(SUM(p.Product_Price * s.Units)) AS total_sales 
FROM `portfolioprojects2023.MavenToys.stores` AS st 
  INNER JOIN `portfolioprojects2023.MavenToys.sales` AS s 
  ON st.Store_ID = s.Store_ID 
  INNER JOIN `portfolioprojects2023.MavenToys.products` AS p 
  ON s.Product_ID = p.Product_ID 
GROUP BY st.Store_City 
ORDER BY total_sales DESC 
LIMIT 3; 
--Cuidad de Mexico has $1,649,492 in sales, Guadalajara has $1,322,099 and Monterrey has $1,261,846 

 
--Since some cities have multiple stores, let's look at the stores with the overall best performance, the cities they are in and their location type.  
SELECT  
  st.Store_Name
  , st.Store_City
  , ROUND(SUM(s.Units * p.Product_Price)) AS Total_Sales 
FROM `portfolioprojects2023.MavenToys.stores` AS st 
  INNER JOIN `portfolioprojects2023.MavenToys.sales` AS s 
  ON st.Store_ID=s.Store_ID 
  INNER JOIN `portfolioprojects2023.MavenToys.products` p 
  ON s.Product_ID=p.Product_ID 
GROUP BY st.Store_Name, st.Store_City 
ORDER BY Total_Sales DESC 
LIMIT 5; 
Maven Toys Ciudad de Mexico 2, Cuidad de Mexico, Airport, $554,553, 
Maven Toys Guadalajara 3, Guadalajara, Airport, $449,355  
Maven Toys Ciudad de Mexico 1, Cuidad de Mexico, Downtown, $433,556 
Maven Toys Toluca 1, Toluca, Downtown, $411,157 
Maven Toys Monterrey 2, Monterrey, Downtown, $372,999 

 
--Since the top 2 stores are located at airports, look at Toluca and Monterrey to see if they don't have any stores at airports for possible expansion. 
SELECT 
  Store_Name
  , Store_City
  , Store_Location 
FROM `portfolioprojects2023.MavenToys.stores`  
WHERE Store_City IN("Toluca","Monterrey") 
ORDER BY Store_City; 
-- Monterrey already has an airport location, but Toluca does not. 
