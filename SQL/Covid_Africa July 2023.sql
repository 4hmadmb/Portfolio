/*
Covid 19 Data Exploration (Recent Data as of 2023-07-12 and is Collected from https://ourworldindata.org/covid-deaths)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



-- Select Data that we are going to be starting with

Select *
From PortfolioProject..CovidDeaths
where continent is not null 
order by 3

Select *
From PortfolioProject..CovidVaccinations
where continent is not null 
order by 3


-- Whole of Africa

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100, 2) as DeathPercnt
From PortfolioProject..CovidDeaths
where continent is not null and continent like 'Africa'
order by 1,2


-- Total Cases vs Total Deaths in African Countries

Select Location, MAX(cast(total_cases as int)) as TotalCases, MAX(cast(Total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
Where continent is not null and continent like 'Africa'
Group by location
order by 1,2

-- Death Percentage in my country Nigeria

Select Location, MAX(cast(total_cases as int)) as TotalCases, MAX(cast(Total_deaths as int)) as TotalDeaths,
round((max(total_deaths)/max(total_cases))*100, 2) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Nigeria'  
group by Location



-- Total Cases vs Population in Africa
-- Shows what percentage of population infected with Covid


Select Location, Population, max(total_cases) as TotalCases, round(((max(total_cases)/population)*100),2) as Percnt_polation_Infd  
From PortfolioProject..CovidDeaths
Where continent is not null and continent like 'Africa'
Group by location, population
order by 1


-- Countries with the Highest number of Infection Rate compared to Population in Africa

Select Location, Population, max(total_cases) as TotalCases, round(((max(total_cases)/population)*100),2) as Percnt_polation_Infd  
From PortfolioProject..CovidDeaths
Where continent is not null and continent like 'Africa'
Group by location, population
order by Percnt_polation_Infd desc



-- Countries with Highest number of Death Count per Population in Africa

Select Location, Population, MAX(total_deaths) as TotalDeaths
From PortfolioProject..CovidDeaths
Where continent is not null and continent like 'Africa'
Group by Location, Population
order by TotalDeaths desc



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(cv.new_vaccinations as bigint)) OVER 
(Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null and cd.continent like 'Africa'
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
where cd.continent is not null and cd.continent like 'Africa'

)
Select *, round((RollingPeopleVaccinated/Population)*100,5) as Percnt_vaccinated
From PV


-- Creating View to store data for later visualizations

 --AFRICA FOR VIZ IN TABLEAU

create view VizData_Africa as
Select cd.continent,cd.location, cd.date, cd.new_cases, cd.total_cases, cd.new_deaths, cd.total_deaths,
cd.population,cv.gdp_per_capita, cv.extreme_poverty, cv.people_vaccinated, cv.people_vaccinated_per_hundred, 
cv.people_fully_vaccinated, cv.people_fully_vaccinated_per_hundred
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null and cd.continent like 'Africa'
--order by 1,2

-----------------------------------------------------