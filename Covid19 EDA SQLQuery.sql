--Selecting the data from the two tables for viewing and inspection of datapoints
SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4



-- Selecting data to be used from CovidDeaths Table
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2




-- Changing the data types of relevant columns to enable manipulations
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_deaths DECIMAL
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases DECIMAL






 --Looking at the Total Cases vs Total Deaths
--SELECT location, SUM(total_cases) AS TotalCases, SUM(total_deaths) AS TotalDeaths
--FROM PortfolioProject..CovidDeaths
--GROUP BY location
--ORDER BY location

-- Shows the likelihood of dying if you contract covid
--BY COUNTRY
SELECT location, MAX(total_cases) AS CasesCount ,  MAX(total_deaths) AS DeathsCount, ROUND((MAX(total_deaths)/MAX(total_cases))*100, 3) AS MortalityRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 1
--BY CONTINENT
SELECT continent, MAX(total_cases) AS CasesCount ,  MAX(total_deaths) AS DeathsCount, ROUND((MAX(total_deaths)/MAX(total_cases))*100, 3) AS MortalityRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent







-- Looking at the Total cases vs the Population
-- Shows what percentage of the population has gotten Covid
--BY COUNTRY
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100, 5) AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2





-- Looking at Countries with highest Infection Rates compared to Population
--BY COUNTRY
SELECT location, population, MAX(total_cases) AS InfectionCount, MAX(ROUND((total_cases/population)*100, 5)) AS InfectionCountRates
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionCountRates DESC, InfectionCount DESC
--BY CONTINENT
SELECT continent, MAX(population) AS Population, MAX(total_cases) AS InfectionCount, ROUND((MAX(total_cases)/MAX(population))*100, 5) AS InfectionCountRates
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY InfectionCountRates DESC, InfectionCount DESC





-- Showing Countries with the Highest Death Count Per Population and their DeathRates
-- cast(column as datatype)
--BY COUNTRY
SELECT location, population, MAX(total_deaths) AS DeathCount, MAX(ROUND((total_deaths/population)*100, 5)) AS DeathRates
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathRates DESC, DeathCount DESC
--BY CONTINENT
SELECT continent, MAX(population) AS Population, MAX(total_deaths) AS DeathCount, MAX(ROUND((total_deaths/population)*100, 5)) AS DeathRates
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathRates DESC, DeathCount DESC





-- Showing Countries with the Highest Death Count Per Location
--BY COUNTRY
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
--BY CONTINENT
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC





--Total Cases and Death Rates Per Day Worldwide
--GLOBAL NUMBERS PER DAY
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS MortalityRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) != 0
ORDER BY 1
-- OVERALL STAT
SELECT SUM(new_cases) AS TotalCases, SUM(CONVERT(INT,new_deaths)) AS TotalDeaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 AS MortalityRate--, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 --, total_deaths, ROUND((total_deaths/total_cases)*100, 3) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2






SELECT *
FROM CovidVaccinations


-- Looking at the total Population vs Vaccinations
--BY COUNTRY
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
--BY CONTINENT
SELECT dea.continent, MAX(dea.population) AS Population, MAX(CAST(vac.total_vaccinations AS BIGINT)) AS VaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent
ORDER BY 2,3









--USING CTE
WITH PopVsVac(Continent, Location, Date, Population, NewVaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND dea.location = 'Canada'
--ORDER BY 2,3
)
SELECT *, (RollingVaccinationCount/Population)*100 AS PercentageVacs
FROM PopVsVac





--TEMP TABLES
DROP TABLE IF EXISTS #PercentagPoulationVaccinated
CREATE TABLE #PercentagPoulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentagPoulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND dea.location = 'Canada'
--ORDER BY 2,3

SELECT *, (RollingVaccinationCount/Population)*100 AS PercentageVacs
FROM #PercentagPoulationVaccinated
ORDER BY 2,3


--BY CONTINENT
DROP TABLE IF EXISTS #PercentagPoulationVaccinatedCT
CREATE TABLE #PercentagPoulationVaccinatedCT
(
Continent nvarchar(255),
Population numeric,
NewVaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentagPoulationVaccinatedCT
SELECT dea.continent, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.continent ORDER BY dea.continent) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND dea.location = 'Canada'
--ORDER BY 2,3





--VIEWS
-- Creating Views to store data for later Visualization
-- PERCENTAGE POPULATION VACCINATED
CREATE VIEW PercentagPoulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentagPoulationVaccinated
ORDER BY location, date