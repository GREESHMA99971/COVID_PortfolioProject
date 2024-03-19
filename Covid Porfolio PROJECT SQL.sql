select cd.location, cd.date, cd.total_cases, cd.new_cases, cd.total_deaths, cd.population
from Portfolio_Projects..CovidDeaths as cd
order by 1,2

--Total cases vs TotalDeaths

select cd.location, cd.date, cd.total_cases, cd.total_deaths, (cast(cd.total_deaths as float)/cast(cd.total_cases as float))*100 as DeathPercentage
from Portfolio_Projects..CovidDeaths as cd
where cd.location = 'India'
order by 1,2

-- total Cases vs Total population

select cd.location, cd.date, cd.total_cases, cd.population, (cast(cd.total_cases as float)/cd.population)*100 as CovidPercentage
from Portfolio_Projects..CovidDeaths as cd
where cd.location = 'India'
order by 1,2

-- Looking into Highest infection count and highest percentage

select cd.location, cd.population, MAX(cd.total_cases) as highestInfectionCount, max((cast(cd.total_cases as float)/cd.population)*100) as CovidPercentage
from Portfolio_Projects..CovidDeaths as cd
group by cd.location, cd.population
order by CovidPercentage desc

-- looking for highest death count vs population.

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Projects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- wehrever continent is null, tht continent is present in location. We dont want continents in location, so we 
-- put restraint.

/* Looking at continent: Now wherever null continent is there, the location has a continent name, so those
 are the correct continents*/

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Projects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- looking for total population vs vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
from Portfolio_Projects..CovidDeaths as dea
join Portfolio_Projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


-- lets now sum up new vaccinations. This becomes total vaccination
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum (convert(BIGINT, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as totalVaccinationPerLocation
from Portfolio_Projects..CovidDeaths as dea
join Portfolio_Projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

-- lets now create a CTE to do the same: because 'totalVa....ion' cannot be used for further calculations.

with poVsVac as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum (convert(BIGINT, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as totalVaccinationPerLocation
from Portfolio_Projects..CovidDeaths as dea
join Portfolio_Projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (totalVaccinationPerLocation/population) * 100 as rate from poVsVac

--lets do the same thing with temp table

Drop table if exists #PopulationVsVaccinated
create table #PopulationVsVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
date DateTime,
Population numeric,
New_Vaccinations numeric,
totalVaccinationPerLocation numeric
)

select * from #PopulationVsVaccinated

Insert into #PopulationVsVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum (convert(BIGINT, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as totalVaccinationPerLocation
from Portfolio_Projects..CovidDeaths as dea
join Portfolio_Projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

--create views

create view PercentPopulateVaccine as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum (convert(BIGINT, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as totalVaccinationPerLocation
from Portfolio_Projects..CovidDeaths as dea
join Portfolio_Projects..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null


