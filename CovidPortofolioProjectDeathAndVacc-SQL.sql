SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

--SELECT *
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that e are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths

--Shows likelihood of dying if you contract Covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location = 'Jordan'
ORDER BY 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Jordan'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Jordan'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Jordan'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing the continent wiht the highest death count by population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Jordan'
WHERE continent IS  NOT NULL  
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM( CAST (new_deaths AS INT)) AS total_deaths, SUM( CAST (new_deaths AS INT))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Jordan'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM( CAST (new_deaths AS INT)) AS total_deaths, SUM( CAST (new_deaths AS INT))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location = 'Jordan'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( CAST (vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS 
FROM PopvsVac


--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100  
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths AS dea
JOIN PortofolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT* 
FROM PercentPopulationVaccinated 
