Select * 
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--Select Data 

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in United Kingdom
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%United Kingdom%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%United Kingdom%'
and continent is not null
order by 1,2

--Looing at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
--Where location like '%United Kingdom%'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with the highest death count per population

Select location, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--BREAKING DOWN BY CONTINENT
--Showing continents with the highest death count per population

Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

--Death percentage per date
Select date, SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group By date
order by 1,2

--Death percentage total
Select SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2


--Lookking at Total Population vs Vaccination

	--USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
	as

	(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	)

	Select *, (TotalPeopleVaccinated/Population) *100
	From PopvsVac

	--Temp Table
	
	DROP Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	TotalPeopleVaccinated numeric)



	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null

	
	Select *, (TotalPeopleVaccinated/Population) *100
	From #PercentPopulationVaccinated


	--Creating View to store data for visualisation

	Create View PercentPopulationVaccinated as
		Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	