/*
Covid 19 Data Exploration (Recent Data as of 2023-07-12 and is Collected from https://ourworldindata.org/covid-deaths)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Selecting Data that we are going to be starting with

Select continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Death Percentage in my country Nigeria


Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Nigeria' 
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like 'Nigeria'
and continent is not null 
order by 1,2


-- Countries with the Highest number of Infection Rate compared to Population

Select Location, Population, Max(total_cases) as Total_Affected_Count, Max(total_cases/population)*100 as Total_Population_Percent_Affected
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population
order by Total_Population_Percent_Affected desc


-- Countries with Highest number of Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER 
(Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- Using CTE

With PV (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER 
(Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PV


-- Creating View to store data for later visualizations

Create View Data_Overview as
Select continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null 

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER 
(Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 


Create View HigestDeath_Count as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent


