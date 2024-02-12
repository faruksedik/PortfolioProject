select * 
from PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Actual data to be used
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 1,2

-- Total cases vs Total deaths
-- Likelihood of dying in one contracts Covid-19 in Africa
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Africa' and continent is NOT NULL
order by 1,2

-- Total cases vs Population
select Location, date, population, total_cases, (total_cases/population)*100 as percentage_of_population_infecdted
from PortfolioProject..CovidDeaths
where location like 'Africa' and continent is NOT NULL
order by 1,2

-- Looking at countries with highest Total cases to Population ratio
select Location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as percentage_population_infected
from PortfolioProject..CovidDeaths
-- where location like 'Africa'
where continent is NOT NULL
group by location, population
order by 4 desc

-- Looking at countries with highest death count to Population ratio
select Location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
-- where location like 'Africa'
where continent is NOT NULL
group by location
order by 2 desc

-- Looking at countries with highest death count to Population ratio
-- Deep dive in each continent ***
select location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
-- where location like 'Africa'
where continent is NULL
group by location
order by 2 desc

-- showing the continents with the highest death count per population
-- create view
select continent, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
-- where location like 'Africa'
where continent is not NULL
group by continent
order by 2 desc

--GLOBAL NUMBERS

select -- create view
	SUM(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths,
	(sum(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
-- where location like 'Africa'
where continent is not null
--group by date
order by 1

-- Join the deaths and vaccination table
select * 
from PortfolioProject..CovidDeaths as death_table
Join PortfolioProject..CovidVaccinations as vaccine_table
on death_table.location = vaccine_table.location
and death_table.date = vaccine_table.date
order by 3,4

-- Looking at total Population vs Vaccination
select
	death_table.continent, death_table.location, 
	death_table.date, death_table.population, vaccine_table.new_vaccinations,
	sum(cast(vaccine_table.new_vaccinations as int)) over (partition by death_table.location
	order by death_table.location, death_table.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths as death_table
Join PortfolioProject..CovidVaccinations as vaccine_table
on death_table.location = vaccine_table.location
and death_table.date = vaccine_table.date
where death_table.continent is not null
order by 2,3


--USE CTE
With pop_vs_vacc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select
	death_table.continent, death_table.location, 
	death_table.date, death_table.population, vaccine_table.new_vaccinations,
	sum(cast(vaccine_table.new_vaccinations as int)) over (partition by death_table.location
	order by death_table.location, death_table.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths as death_table
Join PortfolioProject..CovidVaccinations as vaccine_table
on death_table.location = vaccine_table.location
and death_table.date = vaccine_table.date
where death_table.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from pop_vs_vacc

-- TEMP TABLE
drop table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)

insert into #percent_population_vaccinated
select
	death_table.continent, death_table.location, 
	death_table.date, death_table.population, vaccine_table.new_vaccinations,
	sum(cast(vaccine_table.new_vaccinations as int)) over (partition by death_table.location
	order by death_table.location, death_table.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths as death_table
Join PortfolioProject..CovidVaccinations as vaccine_table
on death_table.location = vaccine_table.location
and death_table.date = vaccine_table.date
-- where death_table.continent is not null

select *, (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated


-- Creating View to store data for later visualizations
Create View percent_population_vaccinated as
select
	death_table.continent, death_table.location, 
	death_table.date, death_table.population, vaccine_table.new_vaccinations,
	sum(cast(vaccine_table.new_vaccinations as int)) over (partition by death_table.location
	order by death_table.location, death_table.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths as death_table
Join PortfolioProject..CovidVaccinations as vaccine_table
	on death_table.location = vaccine_table.location
	and death_table.date = vaccine_table.date
where death_table.continent is not null

use PortfolioProject

create view death_percentage as 
select -- create view
	SUM(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths,
	(sum(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
-- where location like 'Africa'
where continent is not null
--group by date
--order by 1


select * from percent_population_vaccinated
