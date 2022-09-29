-- Selecting the data that which we are going to use in this project

select location,
date,
total_cases,
new_cases,
total_deaths,
population
from CovidDeaths$
order by 1,2


-- looking at the Total cases vs Total Deaths by country
--Shows the likelihood of dying if you are infected by Covid-19
select location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases) * 100 as Death_percentage
from CovidDeaths$
where location like '%states%'
order by date desc

--Lookig at the total cases vs population
select location,
date,
population,
total_cases,
(total_cases/population) * 100 as percent_of_infected_population
from CovidDeaths$
--where location like '%states%'
order by 1,2 

-- Countries with highest infection rate compared to population
select 
location,
population,
MAX(total_cases) as Highest_Infection_count,
MAX((total_cases/population)) * 100 as percent_of_infected_population
from CovidDeaths$
where continent is not null
--where location like '%states%'
group by location, population
order by percent_of_infected_population desc



--countries with the highest death count 
select
location,
MAX(cast(total_deaths as int)) as Total_Death_count
from CovidDeaths$
where continent is not null
group by location
order by Total_Death_count desc


-- Group the values by continent with the highest death count
select 
continent,
MAX(cast(total_deaths as int)) as total_death_count
from CovidDeaths$
where continent is not null
group by continent


--Global numbers
select 
--date,
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
( sum(cast(new_deaths as int)) / sum(new_cases) )* 100 as DeathPercentage

--(total_deaths/total_cases) *100 as DeathPercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Total population who are vaccinated

select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) as Rolling_sum_vaccination
from CovidVaccinations$ v
inner join
CovidDeaths$ d
on v.location = d.location and v.date = d.date
where d.continent is not null
order by 1,2,3


-- using CTE
with pop_vs_vac (continent, location, date, population, new_vaccinations, Rolling_sum_vaccination) as
(
select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) as Rolling_sum_vaccination
from CovidVaccinations$ v
inner join
CovidDeaths$ d
on v.location = d.location and v.date = d.date
where d.continent is not null
--order by 1,2,3
)
select *, (Rolling_sum_vaccination/population) *100
from pop_vs_vac


-- Temp Table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccination numeric
)

insert into #percentpopulationvaccinated
select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) as Rolling_sum_vaccination
from CovidVaccinations$ v
inner join
CovidDeaths$ d
on v.location = d.location and v.date = d.date
where d.continent is not null
--order by 1,2,3

select *, (rolling_people_vaccination/population) *100
from #percentpopulationvaccinated


--creating a view

create view percentpopulationvaccinated as 
select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) over(partition by d.location order by d.location,d.date) as Rolling_sum_vaccination
from CovidVaccinations$ v
inner join
CovidDeaths$ d
on v.location = d.location and v.date = d.date
where d.continent is not null
--order by 1,2,3

select * from percentpopulationvaccinated


