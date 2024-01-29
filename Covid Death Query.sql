SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths
-- Probabilty of dying in your country if you are infected
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India' AND total_deaths IS NOT NULL
ORDER BY 5 DESC;

SELECT MAX((total_deaths/total_cases)*100) AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India' 





--Total Cases vs Population
-- Infected Population
SELECT location, date, total_cases,population, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location = 'India' AND total_cases IS NOT NULL
ORDER BY 5 DESC;

SELECT MAX((total_cases/population)*100)
FROM CovidDeaths
WHERE location = 'India'


--Countries with highest infected percentage
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE Total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--Countries with highest death count per population
SELECT location, SUM(total_deaths) AS TotalDeaths,population, MAX((total_deaths/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE Total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC


--Death Count in Continents
SELECT location, SUM(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



-- Global Values
SELECT SUM(total_cases) AS Total_Cases, SUM(total_deaths) AS Total_Deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
                                       




--Vaccination vs Population

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations 
, SUM(CovidVaccinations.new_vaccinations) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS CumulativeVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location 
AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
ORDER BY 2,3


WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
AS
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations 
, SUM(CovidVaccinations.new_vaccinations) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS CumulativeVaccinations
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location 
AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (CumulativeVaccinations/Population)*100 AS VaccinatedPopulation
FROM PopVsVac
WHERE Location = 'India'

--TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativePeaopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS CumulativePeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativePeaopleVaccinated/Population)*100 AS VaccinatedPopulation
FROM #PercentPopulationVaccinated	
WHERE Location = 'India'


--Creating View for Later Visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS CumulativePeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated