Select *
From PortfolioProject2..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject2..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
Order by location, date

-- Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
--Where location = 'United States'
Order by location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject2..CovidDeaths
-- Where location = 'United States'
Order by location, date

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as 
	PercentPopulationInfected
From PortfolioProject2..CovidDeaths
-- Where location = 'United States'
Group by location, population
Order by PercentPopulationInfected desc


-- Showing Countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths
-- Where location = 'United States'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--LESTS BREAK THINGS DOWN BY CONTINENT



-- Showing continents with highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject2..CovidDeaths
-- Where location = 'United States'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
--Where location = 'United States'
Where continent is not null
Group by date
Order by 1, 2


-- Total Cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
--Where location = 'United States'
Where continent is not null
-- Group by date
Order by 1, 2


-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With  PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store for later vizualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated