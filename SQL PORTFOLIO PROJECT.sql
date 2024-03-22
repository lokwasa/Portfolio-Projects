--SELECT *
--  FROM [Portfolio Project].[dbo].[CovidVaccinations$]
--SELECT *
--  FROM [Portfolio Project].[dbo].[CovidDeaths$]

  --SELECT *
  --FROM [Portfolio Project].[dbo].[CovidVaccinations$]
  --ORDER BY 3,4

  --SELECT *
  --FROM [Portfolio Project].[dbo].[CovidDeaths$]
  --ORDER BY 3,4

  SELECT Location, date, total_cases, total_deaths, population
  FROM [Portfolio Project].[dbo].[CovidDeaths$]
  ORDER BY 1,2
  -- Total Cases vs Total Deaths
  --Shows likelihood of dying if you contract covid in your country
  SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
  FROM [Portfolio Project].[dbo].[CovidDeaths$]
  WHERE location like '%states%'
  ORDER BY 1,2
  -- Total Cases vs Population
SELECT Location, date,  population, total_cases, (total_cases/population)*100 AS DeathPercentage
  FROM [Portfolio Project].[dbo].[CovidDeaths$]
  WHERE location like '%states%'
  ORDER BY 1,2

   --Countries with Highest Infection Rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths$]
--WHERE location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per population

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths$]
--WHERE location LIKE '%states%'
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths$]
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;
-- GLOBAL NUMBERS

SELECT date, SUM(new_Cases) as total_Cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
  FROM [Portfolio Project].[dbo].[CovidDeaths$]
  --WHERE location like '%states%'
  WHERE continent is not null
  GROUP BY date
  ORDER BY 1,2
  -- Total Population vs vaccinations

 With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
 AS
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location, dea.date) AS RollingPeopleVaccinated
 ---, (RollingPeopleVaccinated/population)*100
 FROM [Portfolio Project].[dbo].[CovidDeaths$] dea
 JOIN [Portfolio Project].[dbo].[CovidVaccinations$] vac
       On dea.location = vac.location
	   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project].[dbo].[CovidDeaths$] dea
JOIN [Portfolio Project].[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

DROP VIEW IF EXISTS PercentPopulationVaccinated;

---creating view to store data for later visualizations

 Create View PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project].[dbo].[CovidDeaths$] dea
JOIN [Portfolio Project].[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3









