--select data that we are going to be using  
SELECT location,date,total_cases,new_cases,total_deaths,population  
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent IS NOT NUll   
ORDER BY 1,2;      

   

--looking at total cases vs. population in the United States  

--shows what percentage of the US population has been infected with Covid  

SELECT location,date,population,total_cases,  
(total_cases/population) * 100 AS percent_popu_infected  
FROM PortfolioProject.dbo.CovidDeaths  
WHERE location = 'United States' AND continent IS NOT NUll  
ORDER BY 1,2       

   

--looking at countries with highest infection rate compared to population  

SELECT location, population, MAX(total_cases) AS highest_infection_count,  
MAX((total_cases/population))* 100 AS percent_popu_infected  
FROM PortfolioProject.dbo.CovidDeaths  
GROUP BY location, population  
ORDER BY percent_popu_infected DESC;       

   

--looking at countries with highest death count per population  
--we are not getting all the continents as a whole, for example north america is missing canada...  

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count  
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent IS NOT NUll  
GROUP BY location  
ORDER BY total_death_count DESC;     

   
   
--showing continents in order of highest to lowest death rate per population--canada is now included in north america. The current data contains Income bracket reported in the location column, which has been filtered out in this query.  

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count   
FROM PortfolioProject.dbo.CovidDeaths   
WHERE continent IS NULL AND location NOT LIKE'%income'  
GROUP BY location   
ORDER BY total_death_count DESC;        

  
  

--original, keep just in case for VIZ in  tableau for drill down effect (canada not included in NAmerica)  
--SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count  
--FROM PortfolioProject.dbo.CovidDeaths 
--WHERE continent IS NOT NULL   
--GROUP BY continent  
--ORDER BY total_death_count DESC     

  
  

--looking at total cases vs total deaths globally by day  

SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,  
SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage  
FROM PortfolioProject.dbo.CovidDeaths   
WHERE continent IS NOT NUll   
GROUP BY date   
ORDER BY 1;      

   

--looking at total cases vs total deaths globally  

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,  
SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage  
FROM PortfolioProject.dbo.CovidDeaths   
WHERE continent IS NOT NUll   
ORDER BY 1,2;      

    
--exploring the vaccination data   

SELECT *  
FROM PortfolioProject.dbo.CovidVaccinations  

  
  
--looking at total population vs. total vaccination with a rolling vaccination sum  

SELECT CD.continent, CD.location, CD.date, population,CV.new_vaccinations,   
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date)   
AS rolling_sum_vaccinations  
FROM PortfolioProject.dbo.CovidDeaths AS CD  
JOIN PortfolioProject.dbo.CovidVaccinations AS CV  
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
FROM PortfolioProject.dbo.CovidDeaths AS CD    
JOIN PortfolioProject.dbo.CovidVaccinations AS CV    
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
FROM PortfolioProject.dbo.CovidDeaths AS CD    
JOIN PortfolioProject.dbo.CovidVaccinations AS CV    
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
FROM PortfolioProject.dbo.CovidDeaths AS CD   
JOIN PortfolioProject.dbo.CovidVaccinations AS CV   
ON CD.location = CV.location    
AND CD.date = CV.date   
WHERE CD.continent IS NOT NULL; 