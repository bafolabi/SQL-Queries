-- The SQL script utilizes MySQL Workbench and involves data obtained from 'Our World in Data' regarding COVID-19 deaths and vaccinations. The script aims to perform various operations on the data, including creating a table, inserting data into the table, and calculating the percentage of the population vaccinated etc.


SELECT * FROM coviddeaths;

-- Let's start by looking at total cases versus total deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS percentageDeaths
FROM portfolio.coviddeaths;

-- now, let's look at the total cases and the population
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS CasePerPopulation
FROM portfolio.coviddeaths;

-- Looking at the country's infection rate compared to their population
SELECT location, MAX(total_cases) as HighestInfectiousCount, population, 
MAX(ROUND((total_cases/population)*100, 2)) AS HighestInfectiousRate
FROM portfolio.coviddeaths
Group BY Population, Location
ORDER BY HighestInfectiousRate DESC;

-- Looking at the country's death rate compared to population
SELECT location, MAX(total_deaths) AS TotalDeathCount, population, MAX(ROUND((total_deaths/population)*100, 2)) AS DeathPerPopulation
FROM portfolio.coviddeaths
Group BY Population, Location
ORDER BY DeathPerPopulation DESC;

-- looking at the death count by continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount, MAX(population) AS Population
FROM (
  SELECT continent, CAST(total_deaths AS UNSIGNED) AS total_deaths, population
  FROM portfolio.coviddeaths
) AS subquery
GROUP BY continent
ORDER BY TotalDeath DESC;

-- analyzes the global percentage of deaths based on the total number of COVID-19 cases recorded worldwide
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS Total_Deaths, 
ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) as PercentageDeaths
FROM portfolio.coviddeaths; 

-- Let's look at total population versus vaccination
-- Firstly we need to join the coviddeaths and covidvaccinations tables 

DROP TABLE IF EXISTS percentpopulationvaccinated;

CREATE TABLE percentpopulationvaccinated (
  continent NVARCHAR(255),
  location NVARCHAR(255),
  date DATE,
  population INT,
  new_vaccination INT,
  ROLLINGVaccinatedCount INT
);

INSERT INTO percentpopulationvaccinated
SELECT
  CVD.continent,
  CVD.location,
  STR_TO_DATE(CVD.date, '%d/%m/%Y'),
  CVD.population,
  CVAC.new_vaccinations,
  SUM(CVAC.new_vaccinations) OVER(PARTITION BY CVD.location ORDER BY CVD.location, CVD.date) AS ROLLINGVaccinatedCount
FROM
  coviddeaths CVD
  JOIN covidvaccinations CVAC ON CVD.location = CVAC.location AND CVD.date = CVAC.date
WHERE
  CVD.date IS NOT NULL AND CVD.date != ''
ORDER BY
  CVD.date,
  CVD.location;

SELECT *, (ROLLINGVaccinatedCount/population)*100 AS PercentagePopulationVaccinated
FROM percentpopulationvaccinated;


-- Lastly, let's create a view to store data for later use
CREATE VIEW global_statitics AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS Total_Deaths, 
ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) as PercentageDeaths
FROM portfolio.coviddeaths; 



