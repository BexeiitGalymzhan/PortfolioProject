select * 
from projectportfolio.dbo.CovidDeaths
where continent is not null
order by 4,6



-- Select data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
from projectportfolio.dbo.CovidDeaths
where continent is not null
order by 1,2


-- Looking at Death Percentage 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from projectportfolio.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Death Percentage(Divide by zero error encounter)
Select Location, date, total_cases, total_deaths,
Case 
when total_cases = 0 then NULL
else (total_deaths/total_cases)*100
end as DeathPercentage 
from projectportfolio.dbo.CovidDeaths
where location = 'Kazakhstan'
and continent is not null
order by 1,2

--Shows the what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from projectportfolio.dbo.CovidDeaths
where location = 'United States'
and continent is not null
order by 1,2

--Looking at Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPopulationInfected
from projectportfolio.dbo.CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population 
Select location, max(cast(Total_deaths as int)) as TotalDeathCount
from projectportfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Showing continents with highest death count per population 
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from projectportfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death,
Case 
when sum(new_cases) = 0 then NULL
else sum(cast(new_deaths as int))/sum(new_cases)*100
end as DeathPercentage 
from projectportfolio..coviddeaths
group by date 
order by 1,2


-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From projectportfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from projectportfolio..coviddeaths dea
join projectportfolio..covidvaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100 
from popvsvac



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from projectportfolio..coviddeaths dea
join projectportfolio..covidvaccination vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100 
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projectportfolio..CovidDeaths dea
Join projectportfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 