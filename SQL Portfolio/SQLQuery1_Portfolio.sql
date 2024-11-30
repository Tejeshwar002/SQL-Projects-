select * from Portfolio..CovidDeaths$
where continent is not null
order by 3,4

--select data that we will be using
select location,date,total_cases,new_cases,total_deaths,population
from Portfolio..CovidDeaths$ 
where continent is not null
order by 1,2

--looking at total cases vs total deaths

select location,date,total_cases,total_deaths
from Portfolio..CovidDeaths$ 
where continent is not null, location='India'
order by 1,2

--shows likelihood of dying in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from Portfolio..CovidDeaths$ 
where location='India'
order by 1,2

--looking at total_cases vs population
--shows what percent of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from Portfolio..CovidDeaths$ 
--where location like '%states%'
order by 1,2

--seeing countries with highest infection rate compared to with populaion

select location,  population, max(total_cases) as highInfectCount, max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio..CovidDeaths$ 
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--showing countries with highest deathcount - population

select location,  max(cast(total_deaths as int)) as DeathCount
from Portfolio..CovidDeaths$ 
where continent is null
group by location 
order by DeathCount desc

--continentwise deathcount

select continent,  max(cast(total_deaths as int)) as DeathCount
from Portfolio..CovidDeaths$ 
where continent is not null
group by continent
order by DeathCount desc

--global wise

select date,sum(new_cases)--,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from Portfolio..CovidDeaths$ 
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

