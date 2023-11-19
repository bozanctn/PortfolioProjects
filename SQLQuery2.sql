Select *
From PortfolioProject.dbo.[CovidDeaths]
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.[CovidVaccinations]
--Where continent is not null
--order by 3,4


-- Select data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population 
--from PortfolioProject.dbo.[CovidDeaths]
--Where continent is not null

--order by 1,2

-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS int)/CAST(total_cases AS int))*100  as DeathPercentage
from PortfolioProject.dbo.[CovidDeaths]
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percanteage of population got Covid

Select Location, date, population, total_cases , (CAST(total_cases AS int)/population)*100  as PercentPopulationInfected
from PortfolioProject.dbo.[CovidDeaths]
Where location like '%states%'
and continent is not null

order by 1,2

--Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((CAST(total_cases AS int)/population))*100  as PercentPopulationInfected
from PortfolioProject.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null

Group by Location, population
order by PercentPopulationInfected desc









--Showing Countries with highest death count per population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LETS BREAK THİNGS DOWN BY CONTINENT

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continent with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' 
where continent is not null
Group By date
order by 1,2


-- Looking at total population vs vaccination

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations_smoothed_per_million)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations_smoothed_per_million, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations_smoothed_per_million)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations_smoothed_per_million)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visulizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations_smoothed_per_million)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated




