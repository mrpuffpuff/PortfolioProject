SELECT *
FROM portfolioproject..coviddeathsport$
order by 3,4

--SELECT *
--FROM portfolioproject..['COVIDvacinations$']
--order by 3,4

--select Data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..coviddeathsport$
ORDER BY 1,2


--looking at Total cases vs Total Deaths
-- shows the likelihood of covid death in Nigeria 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM portfolioproject..coviddeathsport$
WHERE location = 'Nigeria' 
ORDER BY 1,2

--looking at the Total Case vs Population
-- Shows what percentage of population was infected with covid 

SELECT Location, date,population, total_cases,  (total_cases/population)*100 as Infectedpopulationpercentage
FROM portfolioproject..coviddeathsport$
WHERE location = 'Nigeria' 
ORDER BY 1,2
 
 --which country has the Higest Infection rate compared to population
SELECT Location, population, MAX(total_cases) AS  Higestinfectioncount,  MAX((total_cases/population))*100 as Infectedpopulationpercentage
FROM portfolioproject..coviddeathsport$
GROUP BY Location, population
ORDER BY Infectedpopulationpercentage DESC

--Continent with the Higest death count per population 
SELECT Location, MAX(cast(total_deaths as int)) AS  TotalDeathCount
FROM portfolioproject..coviddeathsport$
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Analysing by continents
SELECT continent, MAX(cast(total_deaths as int)) AS  TotalDeathCount
FROM portfolioproject..coviddeathsport$
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Universal Numbers 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM portfolioproject..coviddeathsport$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total number of deaths and cases in the world
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM portfolioproject..coviddeathsport$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total number of people vaccinated in the world
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as rollingpeoplevacinated
FROM portfolioproject..coviddeathsport$ AS dea
JOIN portfolioproject..covidvaccination AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--use CTE
WITH Popvsvac (Continent, location, Date, Population, new_vacinations, Rollingpeoplevacinnated) 
as

(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as rollingpeoplevacinated
FROM portfolioproject..coviddeathsport$ AS dea
JOIN portfolioproject..covidvaccination AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *,(Rollingpeoplevacinnated/population)*100
FROM Popvsvac


--Temp Table

Drop Table if EXISTS #percentPopulationvaccinated

Create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevacinated numeric
)


INSERT INTO #percentPopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Rollingpeoplevacinated
FROM portfolioproject..coviddeathsport$ AS dea
JOIN portfolioproject..covidvaccination AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(Rollingpeoplevacinated/population)*100
FROM #Percentpopulationvaccinated

--CREATE a VIEW  TO  store data for visulisation

 CREATE VIEW percentpopulationvaccinated as 
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Rollingpeoplevacinated
FROM portfolioproject..coviddeathsport$ AS dea
JOIN portfolioproject..covidvaccination AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
from #Percentpopulationvaccinated
