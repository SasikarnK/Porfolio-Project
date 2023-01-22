
Select *
From PortfolioProject_SK..CovidDeath
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject_SK..CovidVaccination
--order by 3,4

-- Select Data that we are going to using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_SK..CovidDeath
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Percentage of Death from COVID in Thailand

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject_SK..CovidDeath
Where location = 'Thailand'
order by location, date DESC


-- Looking at Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject_SK..CovidDeath
Where location = 'Thailand'
order by location, date DESC



-- Looking at Countries with Highest Infectionrate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount , Max(total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject_SK..CovidDeath
-- Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Looking at Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject_SK..CovidDeath
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Looking at continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject_SK..CovidDeath
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From PortfolioProject_SK..CovidDeath
-- Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2




-- Looking at Total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population0*100
From PortfolioProject_SK..CovidDeath dea
Join PortfolioProject_SK..CovidVaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE to Calculate Percentage of Vaccinated population per country

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_SK..CovidDeath dea
Join PortfolioProject_SK..CovidVaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac




-- Create Temp Table

Drop table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_SK..CovidDeath dea
Join PortfolioProject_SK..CovidVaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVacinated





-- Create view to store data for visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_SK..CovidDeath dea
Join PortfolioProject_SK..CovidVaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
