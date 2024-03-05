select
cvd.location
, cvd.date
, cvd.total_cases
, cvd.new_cases
, cvd.total_deaths
, cvd.population
from
PortfolioProjects..CovidDeaths cvd
order by 
1, 2


-- cases vs deaths
-- shows likelihood of dying if contract covid

select
cvd.location
, cvd.date
, cvd.total_cases
, cvd.total_deaths
, (cvd.total_deaths/cvd.total_cases)*100 DeathPercentage
from
PortfolioProjects..CovidDeaths cvd
where
cvd.location like '%States%'
order by 
1, 2

-- cases vs pop

select
cvd.location
, cvd.date
, cvd.population
, cvd.total_cases
, (cvd.total_cases/cvd.population)*100 PercentPopInfected
from
PortfolioProjects..CovidDeaths cvd
where
cvd.location like '%States%'
order by 
1, 2

-- highest infection rates?

select
cvd.location
, cvd.population
, max(cvd.total_cases) HighestInfectionCount
, max((cvd.total_cases/cvd.population)*100) PercentPopInfected
from
PortfolioProjects..CovidDeaths cvd
group by
cvd.location
, cvd.population
order by 
PercentPopInfected desc

-- countries with highest death count per pop

select
cvd.location
, max(cast(cvd.total_deaths as int)) HighestDeathCount
from
PortfolioProjects..CovidDeaths cvd
where
cvd.continent is not null
group by
cvd.location
order by 
HighestDeathCount desc

-- show continents with highest death count

select
cvd.location
, max(cast(cvd.total_deaths as int)) HighestDeathCount
from
PortfolioProjects..CovidDeaths cvd
where
cvd.continent is null
group by
cvd.location
order by 
HighestDeathCount desc

-- global numbers

select
cvd.date
, sum(cvd.new_cases) TotalCases
, sum(cast(cvd.new_deaths as int)) TotalDeaths
, (sum(cast(cvd.new_deaths as int))/sum(cvd.new_cases))*100 DeathPercentage
from
PortfolioProjects..CovidDeaths cvd
where
cvd.continent is not null
group by cvd.date
order by 
1, 2


-- total pop vs vacc

select
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from
PortfolioProjects..CovidDeaths as dea
join PortfolioProjects..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where
dea.continent is not null
order by
2, 3

-- use CTE

with PopVsVac  (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from
PortfolioProjects..CovidDeaths as dea
join PortfolioProjects..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where
dea.continent is not null
)
select
*
, (RollingPeopleVaccinated/Population)*100
from
PopVsVac
order by
2, 3

-- use temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255)
, Location nvarchar(255)
, Date datetime
, Population numeric
, NewVaccinations numeric
, RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from
PortfolioProjects..CovidDeaths as dea
join PortfolioProjects..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where
dea.continent is not null

select
*
, (RollingPeopleVaccinated/Population)*100
from
#PercentPopulationVaccinated
order by
2, 3

-- make a view to store data for later visualizations

create view PercentPopulationVaccinated as
select
dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from
PortfolioProjects..CovidDeaths as dea
join PortfolioProjects..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where
dea.continent is not null

select
*
from
PercentPopulationVaccinated