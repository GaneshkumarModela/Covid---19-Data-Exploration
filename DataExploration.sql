/*
Covid 19 Data Exploration Portfolio Project 

Skills used: Joins, CTE's, Temp Tables,  Aggregate Functions, Converting Data Types, views

*/


Select *
From CovidDeaths
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null  
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India' and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population,  total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'India' and continent is not null 
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  max((total_cases / population) * 100) as InfectionRate
From PortfolioProject..CovidDeaths
group by location,population
order by InfectionRate desc


-- Countries with Highest Death Count per Population

Select Location, population, max(cast(total_deaths as int)) as highest_deathCount_recorded
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, population 
order by highest_deathCount_recorded desc;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select location,  max(cast(total_deaths as int)) as highest_deathCount_recorded
From PortfolioProject..CovidDeaths
where continent is null
group by location
order by highest_deathCount_recorded desc;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


select *
from CovidVaccinations
order by 3, 4;


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


---Finding cummulative of new vaccinations  , we 've used CTE here>

with popVSnewVaccinations (continent, location, date, population, newVaccinations, rollingcount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

-- Kept track of percanrage of people got vaccinated>

select *,(rollingcount / population) * 100 as pctOfPplVaccinated
from popVSnewVaccinations
where location = 'India';


--/*Now acheiving the same functionality using temp table */

Drop table if exists #percentageOfPeopleGotVaccinated 
create table #percentageOfPeopleGotVaccinated (
continet varchar(50),
location varchar(50),
date varchar(50),
population numeric,
new_vaccinations numeric,
rollingCount numeric
)

insert into #percentageOfPeopleGotVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *,(rollingCount / population) * 100 as pctOfPplVaccinated
from #percentageOfPeopleGotVaccinated
where location = 'India';



-- Creating View to store data for later visualizations

create view DeathPercentage as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 

select *
from DeathPercentage


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated



