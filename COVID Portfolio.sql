select *
from CovidDeaths
where continent is not NULL
order by 3,4


--select *
--from CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not NULL
order by 1,2



--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
select 
location, 
date, 
total_cases, 
total_deaths, 
CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 AS DealthPercentage
from CovidDeaths
where location like '%state%' and
continent is not NULL
order by 1,2

-- For Nigeria
select 
location, 
date, 
total_cases, 
total_deaths, 
CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 AS DealthPercentage
from CovidDeaths
where location = 'Nigeria'
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got covid
select 
location, 
date, 
total_cases, 
population, 
CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)*100 AS CasesPercentage
from CovidDeaths
where location = 'Nigeria'
order by 1,2

--Looking at countries with highest infection rate compared to population
select 
location, 
 population,
 MAX(total_cases) as HightinfectionCount, 
 MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))*100 AS percentpopulationinfected
from CovidDeaths
--where location = 'Nigeria'
where continent is not NULL
group by population, location
order by percentpopulationinfected desc



--Let's break things down by continent
select 
continent, 
MAX(cast(total_deaths as int)) as TotalDeathCount 
 from CovidDeaths
--where location = 'Nigeria'
where continent is not NULL
group by continent
order by TotalDeathCount desc



--Showing Countries with Hightest Death Count per Population
select 
location, 
MAX(cast(total_deaths as int)) as TotalDeathCount 
 from CovidDeaths
--where location = 'Nigeria'
where continent is not NULL
group by location
order by TotalDeathCount desc



-- Showing the continent  with the hightest daeth count per population
select 
continent, 
MAX(cast(total_deaths as int)) as TotalDeathCount 
 from CovidDeaths
--where location = 'Nigeria'
where continent is not NULL
group by continent
order by TotalDeathCount desc

--Global Numbers
select  
 sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as float))/ sum(cast(new_cases as float))*100 as DeathPercentage
--total_cases, 
--total_deaths, 
--CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 AS DealthPercentage
from CovidDeaths
--where location = 'Nigeria'
where continent is not null
--group by date
order by 1,2


--For CovidVaccines
SELECT *
FROM CovidDeaths dea
JOIN CovidDeaths vac
ON dea.location = vac.location
AND dea.date = vac.date


--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
FROM CovidDeaths dea
JOIN CovidDeaths vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE
with PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopsVac


--Temp Table
Drop Table if EXISTS aPercentPopulationVaccinated
Create Table aPercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)


INSERT INTO aPercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

select *, (RollingPeopleVaccinated/Population)*100
from aPercentPopulationVaccinated

---Creatiing view
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidDeaths vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3