-- Covid Deaths

SELECT *
FROM PortafolioProject..CovidDeaths
ORDER BY 3,4 DESC
;

-- Country: Peru

SELECT *
FROM PortafolioProject..CovidDeaths
WHERE location = 'Peru' 
ORDER BY 4 DESC
;

-- Covid Vaccinations

SELECT *
FROM PortafolioProject..CovidVaccinations
ORDER BY 3,4
;

--Selecting Data that we are going to use from CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
ORDER BY 1,2
;

--Total Cases vs Total Deaths
--Probability of dying if you get covid in Peru 

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,3) as DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE location = 'Peru'
ORDER BY 1,2
;

--Total Cases vs Population
--Percentage of population got Covid

SELECT location, date, Population, total_cases, ROUND((total_cases/population)*100,5) as PercentagePopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location = 'Peru'
ORDER BY 1,2 DESC


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location = 'Peru'
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

-- Faeroe Islands has the highest percentage of population infected currently

--Looking at Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortafolioProject..CovidDeaths
--WHERE location = 'Peru'
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS PER DATE

SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentege
FROM PortafolioProject..CovidDeaths
--WHERE location = 'Peru'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- GLOBAL NUMBERS PER CONTINENT

SELECT continent,SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS INT)) as total_deaths,SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentege
FROM PortafolioProject..CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentege
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1

-- DATA IN PERU PER DATE
SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentege
FROM PortafolioProject..CovidDeaths
WHERE location = 'Peru' and new_cases > 0
GROUP BY date
ORDER BY 1

-- Looking at Total Population vs Vaccinations

SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location,d.date) as TotalPeopleVaccinated
FROM PortafolioProject..CovidDeaths d
JOIN PortafolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

--Using CTE
With PopvsVac (continent,location,date,Population,new_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (Partition by d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths d
JOIN PortafolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location 
ORDER BY d.location,d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortafolioProject..CovidDeaths d
JOIN PortafolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location 
ORDER BY d.location,d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortafolioProject..CovidDeaths d
JOIN PortafolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated





-- Para elaborar tablas




SELECT location,Population,date,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location = 'Peru'
GROUP BY location,population,date
ORDER BY PercentagePopulationInfected DESC


