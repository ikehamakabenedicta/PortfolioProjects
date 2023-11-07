/*
Covid Data Exploration
Skills used: Joins, CTE's, Temps Table, Window Functions, Aggregrate Functions, Creating Views, Converting Data Types
*/

Select *
from PortfolioProjects..['Covid Vaccinations']
order by 3,4

Select *
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,  (convert(float,total_deaths)/nullif(convert(float,total_cases), 0))  * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases,  (convert(float,total_cases)/nullif(convert(float,population), 0))  * 100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2

-- Looking as countries with the Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighInfectionCount,  MAX(convert(float,total_cases)/nullif(convert(float,Population), 0))  * 100 as 
PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
--and continent is not null
group by location, Population
order by PercentPopulationInfected desc

--Showing the Countries with HighestDeaths Count Per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount  desc

--let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount  desc

--showing the continent with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount  desc

--Global Numbers 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(nullif(new_cases,0) * 100) as
DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--ALTOGETHER THE RESULT OF THE TOTAL CASES OF DEATH

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(nullif(new_cases,0) * 100) as
DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population,
NULLIF(CONVERT(float,vac.new_vaccinations), 0) AS  new_vaccinations, SUM(NULLIF(CONVERT(float,vac.new_vaccinations), 0)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join  PortfolioProjects..['Covid Vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location,dea.date, dea.population,
NULLIF(CONVERT(float,vac.new_vaccinations), 0) AS  new_vaccinations, SUM(NULLIF(CONVERT(float,vac.new_vaccinations), 0)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join  PortfolioProjects..['Covid Vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population,
NULLIF(CONVERT(float,vac.new_vaccinations), 0) AS  new_vaccinations, SUM(NULLIF(CONVERT(float,vac.new_vaccinations), 0)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join  PortfolioProjects..['Covid Vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location,dea.date, dea.population,
NULLIF(CONVERT(float,vac.new_vaccinations), 0) AS  new_vaccinations, SUM(NULLIF(CONVERT(float,vac.new_vaccinations), 0)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join  PortfolioProjects..['Covid Vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated