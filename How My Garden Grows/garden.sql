--Exploring the days to harvest of plants I grew 

--Which plant varieties have the shortest and longest days to harvest 
SELECT Plant_Category, Variety, Days_to_Harvest 
FROM `portfolioprojects2023.my_garden.garden` 
ORDER BY Days_to_Harvest; 

 
SELECT Plant_Category, Variety, Days_to_Harvest 
FROM `portfolioprojects2023.my_garden.garden` 
ORDER BY Days_to_Harvest DESC; 

 
--What is the average days to harvest  
SELECT ROUND(AVG(Days_to_Harvest)) AS Avg_Harvest_Days 
FROM `portfolioprojects2023.my_garden.garden`; 

--Exploring pests and diseases in my garden 

 --Which plant varieties are the most heat tolerant and have the least amount of pests 
SELECT Plant_Category, Variety, Summer_Heat_Tolerant AS Most_Heat_Tolerant 
FROM `portfolioprojects2023.my_garden.garden` 
WHERE Summer_Heat_Tolerant = CAST('true' AS bool) 
AND Pests_Small = 'none' 
AND Pests_Large = 'none'; 

 
--Which plant varieties have the most amount of pests 
SELECT Plant_Category, Variety, Pests_ Small, Pests_ Large 
FROM `portfolioprojects2023.my_garden.garden` 
WHERE Pests_Small != 'none' 
AND Pests_Large != 'none'; 
 

--Which are the most common small pests in the garden 
SELECT Pests_Small, COUNT(Pests_Small) AS Count 
FROM `portfolioprojects2023.my_garden.garden`  
GROUP BY Pests_Small 
ORDER BY Count DESC; 
--aphids and white flies were tied at 10 each while the majority was none (no pests) at 30 
 

--Which are the most common large pests in the garden 
SELECT Pests_Large, COUNT(Pests_Large) AS Count 
FROM `portfolioprojects2023.my_garden.garden`  
GROUP BY Pests_Large 
ORDER BY Count DESC; 
--caterpillars were the most prevalent large pest at 7 but the majority was none (no pests) at 42 

 
--Which is the most prevalent disease in the garden 
SELECT Disease, COUNT(Disease) AS Count 
FROM `portfolioprojects2023.my_garden.garden` 
GROUP BY Disease 
ORDER BY Count DESC; 

--How do my plants grow 

-Which is the most common sowing method  
SELECT Sow_Method, COUNT(Sow_Method) AS Count 
FROM `portfolioprojects2023.my_garden.garden` 
GROUP BY Sow_Method 
ORDER BY Count DESC; 
--most plants are grown by direct seed 

 
-Which is the most common growing method 
SELECT Grow_Method, COUNT(Grow_Method) AS Count  
FROM `portfolioprojects2023.my_garden.garden`  
GROUP BY Grow_Method 
ORDER BY Count DESC; 
--most plants are grown in grow bags 

 
--How many plants grow in each season 
SELECT Season_Type, COUNT(Season_Type) AS Count  
FROM `portfolioprojects2023.my_garden.garden`  
GROUP BY Season_Type 
ORDER BY Count DESC; 
--most plants grown are warm season crops 

 
--what type of location is most popular 
SELECT Location, COUNT(Location) AS Count  
FROM `portfolioprojects2023.my_garden.garden`  
GROUP BY Location 
ORDER BY Count DESC; 
--most plants are grown in partial sun 


--Which plants I should grow?

--Which are the most productive and best tasting plant varieties 
SELECT DISTINCT Taste,   
FROM `portfolioprojects2023.my_garden.garden`; 
--There are 4 categories of taste: really good, good, bad and so-so 
 

SELECT DISTINCT Productivity   
FROM `portfolioprojects2023.my_garden.garden`; 
--There are 3 categories of taste: very productive, productive and not productive 
 

SELECT Plant_Category, Variety, Taste, Productivity    
FROM `portfolioprojects2023.my_garden.garden`  

 
WHERE Taste = 'really good'  
AND Productivity = 'very productive' 
LIMIT 10;  
--varieties from the categories okra, herbs, greens and tomatoes should be grown 
 

--Which are the least productive and worst tasting plant varieties 
SELECT Plant_Category, Variety, Taste, Productivity   
FROM `portfolioprojects2023.my_garden.garden` 
WHERE Taste IN('so-so','bad') 
AND Productivity = 'not productive'; 
--Turkish Orange Eggplant is a variety that I should not grow again 
 
 
--Which are the top 10 most expensive per lb at the supermarket 
SELECT Plant_Category, Variety, Price_per_lb 
FROM `portfolioprojects2023.my_garden.prices` 
ORDER BY Price_per_lb DESC 
LIMIT 10; 
--herbs are the most expensive crops at $70 per lb 

 
--Which are the cheapest 
SELECT Plant_Category, Variety, Price_per_lb 
FROM `portfolioprojects2023.my_garden.prices` 
ORDER BY Price_per_lb 
LIMIT 10; 
--carrots are the cheapest per lb 

 
--Which crops are the tastiest, productive, have the least pest/disease and most expensive to buy at the supermarket 
SELECT G.Plant_Category, G.Variety, Price_per_lb 
FROM `portfolioprojects2023.my_garden.garden` AS G 
JOIN `portfolioprojects2023.my_garden.prices` AS P 
ON G.Variety = P.Variety 
WHERE Pests_Small = 'none'  
AND Pests_Large = 'none' 
AND Disease = 'none' 
AND Taste IN('really good','good') 
AND Productivity IN ('very productive','productive') 
AND Price_per_lb > 5 
ORDER BY Price_per_lb DESC; 
--herbs and greens are crops that I should always grow 
 

--which crops should I not grow again 
SELECT Plant_Category,Variety 
FROM `portfolioprojects2023.my_garden.garden`  
WHERE Grown_Again = 'no'; 
