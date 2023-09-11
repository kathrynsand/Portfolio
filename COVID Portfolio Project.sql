--Select*
--From COVIDPortfolioProject..CovidDeaths
--Where continent is not null
--order by 3,4

--Select*
--From COVIDPortfolioProject..CovidVacc$
--order by 3,4


--Select data were are going to be starting with


--Select Location, date, total_cases, new_cases, total_deaths, population
--From COVIDPortfolioProject..CovidDeaths
--order by 1,2



--Looking at Total Cases vs Total Deaths
--Shows likelikehood of dying if you contract covid in your country

--Select Location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
--From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
--order by 1,2


--Looking at Total Cases vs population
--Shows what percentage of population got covid

----Select Location, date, total_cases,population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
--From COVIDPortfolioProject..CovidDeaths
----Where location like '%states%'
--order by 1,2


--Countries with Highest Infection Rate compared to Population

--Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
--From COVIDPortfolioProject..CovidDeaths
----Where location like '%states%'
--Group by Location, population
--order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From COVIDPortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


--BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From COVIDPortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(CONVERT(float, new_deaths)) / NULLIF(SUM(CONVERT(float, new_cases)), 0))*100 as DeathPercentage
From COVIDPortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2



--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..CovidDeaths dea
Join COVIDPortfolioProject..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--order by 2,3