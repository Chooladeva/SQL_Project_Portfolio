
-- Inspecting the Datasets
-- 1. Retrieving All Records from the CovidDeaths Table

select * 
from [Covid Portfolio Project].. CovidDeaths
Where continent is not null 
order by 3,4


-- 2. Retrieving All Records from the CovidVaccinations Table

select * 
from [Covid Portfolio Project].. CovidVaccinations
order by 3,4


-- Analyzing the CovidDeaths Dataset
-- 3. Extracting Essential Data from the CovidDeaths Table

Select Location, date, total_cases, new_cases, total_deaths, population
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null 
order by 1,2


-- 4. Calculating Death Percentage (Total Cases vs. Total Deaths)

select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null 
order by 1,2


-- 5. Calculating Cases Percentage (Total Cases vs. Population)

select continent, location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null 
order by 1,2


-- Finding the Highest Impacted Countries
-- 6. Countries with the Highest Cases (Compared to Population)

select continent, location, MAX(total_cases) as HighestCasesCount, population, MAX(total_cases/population)*100 as HighestCasesPercentage
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null 
Group by continent, Location, Population
order by HighestCasesPercentage desc


-- 7. Countries with the Highest Death Percentage (Compared to Population)

select continent, location, MAX(cast(total_deaths as int)) as HighestdeathsCount, population, MAX(total_deaths/population)*100 as HighestDeathsPercentage
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null 
Group by continent, Location, Population
order by HighestDeathsPercentage desc


-- 8. Countries with the Highest Number of Total Deaths

select continent, location, MAX(cast(total_deaths as int)) as TotaldeathsCountCountry
From [Covid Portfolio Project]..CovidDeaths
where continent is not null 
Group by continent, location
order by TotaldeathsCountCountry desc


-- Finding the Highest Impacted Continents
-- 9. Highest Cases and Deaths by Continent

select location, MAX(total_cases) as HighestCasesCount, MAX(TRY_CAST (total_deaths as int)) as TotaldeathsCountContinent
From [Covid Portfolio Project]..CovidDeaths
where continent is null 
and location not in ('World', 'International', 'European Union') 
Group by location
order by TotaldeathsCountContinent desc


-- Global Statistics
-- 10. Global Death Percentage

select sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentageGlobal
From [Covid Portfolio Project]..CovidDeaths
-- where location like '%Sri Lanka%'
Where continent is not null 
order by 1,2


--Analyzing Vaccinations
-- 11. Percentage of Population Vaccinated

With PopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, CummulativeVaccineCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CummulativeVaccineCount
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (CummulativeVaccineCount/Population)*100 as PercentPeopleVaccinated
from PopulationVaccinated