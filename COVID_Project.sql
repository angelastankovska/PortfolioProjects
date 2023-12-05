--Select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1, 2

--Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1, 2

--Total cases vs population
SELECT location, date,  population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location LIKE '%macedonia%'
ORDER BY 1, 2

--Contries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY InfectedPercentage desc

--Countries with highest death count
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths$
--where continent is null
--GROUP BY location
--ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS
--number of new cases an death globally ordered by date
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total population vs vaccinations
--CTE
WITH PopulationVsVaccination (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null

)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopulationVsVaccination

--Creating a view for later vizualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null