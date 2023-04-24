Covid Data Exploration 

--exploring the covid death data 
SELECT *  
FROM Covid.dbo.CovidDeaths; 


--select data that we are going to be using  
SELECT location,date,total_cases,new_cases,total_deaths,population  
FROM Covid.dbo.CovidDeaths 
WHERE continent IS NOT NUll   
ORDER BY 1,2;      



--looking at total cases vs. population in the United States  
--shows what percentage of the US population has been infected with Covid on a given day

SELECT location,date,population,total_cases,  
(total_cases/population) * 100 AS percent_popu_infected  
FROM Covid.dbo.CovidDeaths  
WHERE location = 'United States'   
ORDER BY 1,2       



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



Select Location, Population,date, MAX(total_cases) as highest_infection_count,  
Max((total_cases/population))*100 as percent_population_infected  
From Covid.dbo.CovidDeaths  
WHERE continent IS NOT NULL 
Group by Location, Population, date  
order by percent_population_infected desc; 
 
 
 
--looking at countries with highest death count per population  
--we are not getting all the continents as a whole, for example north america is missing canada...  

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count  
FROM Covid.dbo.CovidDeaths 
WHERE continent IS NOT NUll  
GROUP BY location  
ORDER BY total_death_count DESC;     
--The United States ranks 1st with a death count of 1,119,560 

    
    
--showing continents in order of highest to lowest death rate per population
--canada is now included in north america. 
--The current data contains Income bracket reported in the location column, which has been filtered out in this query

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count    
FROM Covid.dbo.CovidDeaths    
WHERE continent IS NULL  
AND location NOT LIKE'%income'  
AND location NOT IN ('World', 'European Union', 'International') 
GROUP BY location    
ORDER BY total_death_count DESC;          
--Europe has the highest death count at 2,032,535 and Oceania has the least at 24,754


 
--looking at total cases vs total deaths globally  

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,  
SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage  
FROM Covid.dbo.CovidDeaths   
WHERE continent IS NOT NUll   
ORDER BY 1,2;      
--The global death percentage is 1.01% 
    
    
    
--exploring the vaccination data   

SELECT *  
FROM Covid.dbo.CovidVaccinations  

  
  
--looking at total population vs. total vaccination with a rolling vaccination sum  

SELECT CD.continent, CD.location, CD.date, population,CV.new_vaccinations,   
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)   
AS rolling_sum_vaccinations  
FROM Covid.dbo.CovidDeaths AS CD  
JOIN Covid.dbo.CovidVaccinations AS CV  
ON CD.location = CV.location   
AND CD.date = CV.date  
WHERE CD.continent IS NOT NULL   
ORDER BY 2,3; 

 
 
--looking at vaccination rate using CTE  

WITH popu_vax (continent,location,date,population,new_vaccinations,rolling_sum_vaccinations)  
AS  
(  
SELECT CD.continent, CD.location, CD.date, population, CV.new_vaccinations,     
SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)     
AS rolling_sum_vaccinations    
FROM Covid.dbo.CovidDeaths AS CD    
JOIN Covid.dbo.CovidVaccinations AS CV    
ON CD.location = CV.location     
AND CD.date = CV.date    
WHERE CD.continent IS NOT NULL     
)    

SELECT *,(rolling_sum_vaccinations/population)*100 AS rate_vaccinations    
FROM popu_vax; 


  
--same thing but using a temp table 

DROP TABLE IF EXISTS #PercentPopVax 
CREATE TABLE #PercentPopVax  
( 
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_sum_vaccinations numeric 
) 



INSERT INTO #PercentPopVax 
SELECT CD.continent, CD.location, CD.date, population, CV.new_vaccinations,     
SUM(CAST(CV.new_vaccinations AS float)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)     
AS rolling_sum_vaccinations    
FROM Covid.dbo.CovidDeaths AS CD    
JOIN Covid.dbo.CovidVaccinations AS CV    
ON CD.location = CV.location     
AND CD.date = CV.date    
WHERE CD.continent IS NOT NULL     

SELECT *,(rolling_sum_vaccinations/population)*100 AS rate_vaccinations   
FROM #PercentPopVax; 
 
 
 
--creating views for later visualizations 

CREATE VIEW percent_popultion_vax AS 
SELECT CD.continent, CD.location, CD.date, population,CV.new_vaccinations,    
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)    
AS rolling_sum_vaccinations   
FROM Covid.dbo.CovidDeaths AS CD   
JOIN Covid.dbo.CovidVaccinations AS CV   
ON CD.location = CV.location    
AND CD.date = CV.date   
WHERE CD.continent IS NOT NULL; 
