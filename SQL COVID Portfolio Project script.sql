Select *
From PortfoioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfoioProject.dbo.CovidVaccinations
--order by 3,4 

--Select the data which we are going to use


Select location, date, total_cases, new_cases, total_deaths, population
From PortfoioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows a likelihood of dying if you got a COVID in Cyprus
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfoioProject.dbo.CovidDeaths
where location like '%prus'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PopPercentage
From PortfoioProject.dbo.CovidDeaths
where location like '%prus'
order by 1,2

--Countries with highest infection rate compared to Population
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfoioProject.dbo.CovidDeaths
where continent is not null
Group by population, location
order by PercentPopulationInfected desc

--Showing Countries with highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfoioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--By continents
--Showing continents with the highest DeathCount
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfoioProject.dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercentage
From PortfoioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--Total SUM of Cases and Deaths
Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercentage
From PortfoioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as RollingCountPeopleVaccinated
From PortfoioProject.dbo.CovidDeaths death
Join PortfoioProject.dbo.CovidVaccinations vac
ON death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 2,3

--USE CTE)
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingCountPeopleVaccinated)
as 
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as RollingCountPeopleVaccinated
From PortfoioProject.dbo.CovidDeaths death
Join PortfoioProject.dbo.CovidVaccinations vac
ON death.location = vac.location
and death.date = vac.date
where death.continent is not null
)
Select *, (RollingCountPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac

--TEMP Table
Drop TABLE IF EXISTS #PercentPopulationVaccinated
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
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From PortfoioProject.dbo.CovidDeaths death
Join PortfoioProject.dbo.CovidVaccinations vac
ON death.location = vac.location
and death.date = vac.date
where death.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated


--Create view
Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From PortfoioProject.dbo.CovidDeaths death
Join PortfoioProject.dbo.CovidVaccinations vac
ON death.location = vac.location
and death.date = vac.date
where death.continent is not null
