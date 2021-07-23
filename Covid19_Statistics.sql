
-- World numbers of total deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid_19 Generic Data]..Covid_Death$
-- Where location like '%Sweden%'
where continent is not null 
order by 1,2



-- The number of deaths in each continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid_19 Generic Data]..Covid_Death$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- Percent of infected population in each country ordered by highest to lowest

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid_19 Generic Data]..Covid_Death$
Group by Location, Population
order by PercentPopulationInfected desc



-- Daily Percentage and count of infected population in each country ordered by highest to lowest

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid_19 Generic Data]..Covid_Death$
Group by Location, Population, date
order by PercentPopulationInfected desc



-- Daily number of vaccinated people count in each country 

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From [Covid_19 Generic Data]..Covid_Death$ dea
Join [Covid_19 Generic Data]..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3 desc



-- Creating new temporary table 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Covid_19 Generic Data]..Covid_Death$ dea
Join [Covid_19 Generic Data]..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac



-- Daily count of vaccinated people and new deaths in SWEDEN

Select dea.location, dea.date, dea.population, vac.new_vaccinations, dea.new_deaths
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Covid_19 Generic Data]..Covid_Death$ dea
Join [Covid_19 Generic Data]..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Sweden%'
order by 2 desc