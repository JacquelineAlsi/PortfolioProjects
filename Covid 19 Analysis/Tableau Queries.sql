--Queries used in Tableau Project


--looking at total cases vs total deaths globally  
SELECT SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS int)) AS total_deaths,  
SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage  
FROM Covid.dbo.CovidDeaths   
WHERE continent IS NOT NULL   
ORDER BY 1,2;      
--The global death percentage is 1.01% 

 

--showing continents in order of highest to lowest death rate per population 
--canada is now included in north america.  
--The data contains ‘Income bracket’ reported in the location column, which has been filtered out in this query. 

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count    
FROM Covid.dbo.CovidDeaths    
WHERE continent IS NULL  
AND location NOT LIKE'%income'  
AND location NOT IN ('World', 'European Union', 'International') 
GROUP BY location    
ORDER BY total_death_count DESC;            
--Europe has the highest death count at 2,032,535 and Oceania has the least at 24754 

 

--looking at countries with the highest infection rate compared to their population.  
-- Which country has the highest infection rate?  

SELECT location, population, MAX(total_cases) AS highest_infection_count,  
MAX((total_cases/population))* 100 AS percent_popu_infected  
FROM Covid.dbo.CovidDeaths  
WHERE continent IS NOT NULL  
GROUP BY location, population  
ORDER BY percent_popu_infected DESC;        
-- included WHERE continent IS NOT NULL because some continents are listed in the location column. 
-- Cyprus has the highest infection rate at 72% 
-- The US ranks 56 with an infection rate at 31% 

 

 Select Location, Population,date, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected  
 From Covid.dbo.CovidDeaths  
 WHERE continent IS NOT NULL 
 Group by Location, Population, date  
 order by percent_population_infected desc; 
