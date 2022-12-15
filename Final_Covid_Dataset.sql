
--new_deaths vs new_cases in Canada

SELECT  
location,
date,
population,
new_cases,
new_deaths,
(new_deaths)*100/new_cases AS DeathPercentage
FROM  CovidDeaths cd 
WHERE location ='Canada'
ORDER BY deathpercentage DESC

--total_deaths vs total_cases in each country

SELECT  
location,
population,
MAX(CAST(total_cases AS INT)) AS total_cases, -- we have to change the type of these columns since it looks like they have some non integer values.
MAX(CAST(total_deaths AS INT)) AS total_deaths,
(total_deaths)*100/total_cases AS PercentDeathsPerCases
FROM  CovidDeaths
WHERE  continent !='' -- Because there are some extra words like some continent'names in location columns which have null value in continent column.
GROUP BY  location
ORDER BY  PercentDeathsPerCases DESC 

DELETE FROM CovidDeaths 
WHERE location='North Korea'-- Since there are clearly uncorrect values for this country which gives us 600 for 'PercentDeathsPerCases' column.


--countries with highest Infection rate compared to population

SELECT  
location,
population,
MAX(CAST(total_cases AS INT)) AS total_cases, -- we have to change the type of these columns since it looks like they have some non integer values.
MAX(CAST(total_cases AS INT))*100/population AS PercentInfected
FROM  CovidDeaths
WHERE  continent !='' -- Because there are some extra words like some continent'names in location columns which have null value in continent column.
GROUP BY  location
ORDER BY PercentInfected  DESC 

 
SELECT  
location,
population,
date,
MAX(CAST(total_cases AS INT)) AS total_cases, -- we have to change the type of these columns since it looks like they have some non integer values.
MAX(CAST(total_cases AS INT))*100/population AS PercentInfected
FROM  CovidDeaths
WHERE  continent !='' -- Because there are some extra words like some continent'names in location columns which have null value in continent column.
GROUP BY  location, population,date
ORDER BY PercentInfected  DESC 


--countries with highest death count per population

SELECT  
location,
population,
MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM  CovidDeaths
WHERE continent!=''
GROUP BY location
ORDER BY HighestDeathCount DESC


--total death count vs continent (two separate queries bleow have the same results)

SELECT  
continent,
location,
MAX(CAST(total_deaths AS INT)),
SUM(MAX(CAST(total_deaths AS INT))) OVER (PARTITION BY continent ORDER BY location) AS RollingDeathPerContinent
FROM  CovidDeaths cd 
WHERE continent!='' AND location!='World'
GROUP BY continent,location
ORDER BY continent 

SELECT 
location,
MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM  CovidDeaths 
WHERE continent=''AND location NOT IN('','World','European Union','High income','Low income','Lower middle income','Upper middle income')
GROUP BY location
ORDER BY total_deaths DESC


--Global Numbers

SELECT  
date,
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(new_deaths)*100/SUM(new_cases) AS DeathPercentage
FROM  CovidDeaths cd 
WHERE continent!=''
GROUP BY date
ORDER BY date

SELECT 
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(new_deaths)*100/SUM(new_cases) AS DeathPercentage
FROM  CovidDeaths cd 
WHERE continent!=''


--------------JOIN ------------
--total population vs vaccination

SELECT 
cd.continent,
cd.location,
cd.date,
cd.population, 
cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT))OVER(PARTITION BY cd.location ORDER BY cd.date ) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovideVaccinations cv
USING (location, date)
WHERE cd.continent !=''


--use CTE( Common Table Expression) for Population vs Vaccination

WITH PopVsVa AS
(
SELECT 
cd.continent,
cd.location,
cd.date,
cd.population, 
cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT))OVER(PARTITION BY cd.location ORDER BY cd.date ) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovideVaccinations cv
USING (location, date)
WHERE cd.continent !='' --AND cd.location='India' 
)

SELECT*,RollingPeopleVaccinated*100/population
FROM PopVsVa


--TEMP(Temporary)table
--we should run each part separately and in order

DROP TABLE IF EXISTS PercentPopVaccinated
CREATE TEMPORARY TABLE PercentPopVaccinated
(
continent varchar(50),
location varchar(50),
date varchar(50),
population integer ,
new_vaccination integer ,
RollingPeopleVaccinated integer
)
INSERT INTO PercentPopVaccinated
SELECT
cd.continent,
cd.location,
cd.date,
cd.population, 
cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT))OVER(PARTITION BY cd.location ORDER BY cd.date ) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovideVaccinations cv
USING (location, date)
WHERE cd.continent !=''

SELECT*,RollingPeopleVaccinated*100/population
FROM PercentPopVaccinated
--WHERE location='Canada'


-- creating views

CREATE VIEW PercentPopVaccinated AS
SELECT
cd.continent,
cd.location,
cd.date,
cd.population, 
cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT))OVER(PARTITION BY cd.location ORDER BY cd.date ) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovideVaccinations cv
USING (location, date)
WHERE cd.continent !=''
