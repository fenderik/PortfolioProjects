Select *
From CovidProject..CovidDeaths$
order by 3,4

--Select *
--From CovidProject..CovidVaccinations$
--order by 3,4

-- Select Data that will be used for this project. 

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from covid given your current location.
Select Location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From CovidProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows total percentage of population that got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
From CovidProject..CovidDeaths$
--Where location like '%states%'
order by 1,2

-- Looking at Countries with higest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage 
From CovidProject..CovidDeaths$
--Where location like '%states%'
Group by location, population
Order by InfectedPercentage desc


-- Shows countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by location, population
Order by TotalDeathCount desc

-- BREAKING DOWN BY CONTINENT

-- Shows countries with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage 
From CovidProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
order by 1,2

-- Looking at total Population vs Vaccinations
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3
)

Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
-- Temp Table
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-- Create View to store data for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1,2,3