select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccination
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--total cases vs total deaths
--Shows the likelihood of dying if you contract Covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- total cases vs population
-- what % of population had covid by day
select location, date, population, total_cases,(total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

-- Looking at countries with highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by InfectionRate desc

-- Showing Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking down by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers 
--Shows the likelihood of dying if you contract Covid by day
select date, sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- total death %
select sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Getting rolling count of new vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
              On dea.location = vac.location
              and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Getting % of population vaccinated by day using rolling count of new vaccinations
with PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccination vac
				  On dea.location = vac.location
				  and dea.date = vac.date
	where dea.continent is not null
)
select*,(RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PopvsVac


-- temp table
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
	Contient				nvarchar(255),
	Location				nvarchar(255),
	Date					datetime,
	Population				numeric,
	New_Vaccinations		numeric,
	RollingPeopleVaccinated	numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
	
select*,(RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later Visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated
