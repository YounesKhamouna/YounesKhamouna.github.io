USE Covid19World
-- Total_Deaths
-- Case Fatality Rate
-- The Population Infection Rate
-- Vaccination_Rate
-- Chronic Diseases and Canada

---- Data Exploration

-- Describe the table using the sp_help stored procedure.

EXEC sp_help 'CovidDeaths';

EXEC sp_help 'Covidvaccination';

EXEC sp_help 'CovidOthers';

EXEC sp_help 'CovidConfirmedCases';

EXEC sp_help 'CovidHospitalICU';


-- Display the tables and use ORDER BY location and date

SELECT *
FROM CovidDeaths
ORDER BY location,date;

SELECT *
FROM CovidVaccination
ORDER BY location, date desc;

SELECT *
FROM CovidOthers
ORDER BY location, date;

SELECT *
FROM CovidConfirmedCases
ORDER BY location, date DESC;


-- Data cleaning

-- Display the rows where location and continent and total_deaths have not null values 

SELECT *
FROM CovidDeaths
WHERE continent is not null 
		AND location is not null
		AND total_deaths is not null
ORDER BY continent, location, date DESC;

--  Transform the date format "yyyy-mm-dd 00:00:00.000" to "YYYY-MM-DD," 
-- The new date format will be stored in a new column : date_updated

ALTER TABLE CovidDeaths
ADD date_updated VARCHAR(10);

UPDATE CovidDeaths
SET date_updated = CONVERT(VARCHAR(10), date, 120);


-- Top 20 Countries with Highest Cumulative Death Count per Country
-- Display result by the most recent day


Select location,
		Max(date_updated) as Updated, --- Most recent update in our database
		MAX(total_deaths) as TotalDeathCount --- Most recent cumulative death

From CovidDeaths

WHERE continent is not null  --- To have only countries and to exlude continents
	 AND location is not null

Group BY LOCATION

order by TotalDeathCount DESC

OFFSET 0 ROWS
FETCH NEXT 20 ROWS ONLY;

-- CREATE VIEW for later visulaisation of Cumulative Death

CREATE VIEW CumulativeDeath AS 
Select location,
		Max(date_updated) as Updated, --- Most recent update in our database
		MAX(total_deaths) as TotalDeathCount --- Most recent cumulative death

From CovidDeaths

WHERE continent is not null  --- To have only countries and to exlude continents
	 AND location is not null

Group BY LOCATION

order by TotalDeathCount DESC

OFFSET 0 ROWS
FETCH NEXT 20 ROWS ONLY;

---- Calculate the Case fatality rate: Total deaths/ Total Cases

--- Change the data type of total_cases from nvarchar to FLOAT in CovidDeaths table, to be able to do the calculation

USE Covid19World
ALTER TABLE CovidConfirmedCases
ALTER COLUMN TOTAL_CASES FLOAT;

--- Change the data type of total_deaths columns from nvarchar to FLOAT in CovidDeaths table, to be able to do the calculation

USE Covid19World
ALTER TABLE CovidDeaths
ALTER COLUMN TOTAL_Deaths FLOAT;

-- Calculate the Case fatality rate

SELECT  
	    d.location, 
		d.date_updated, 		 
		d.total_deaths, 
		c.total_cases,
		ROUND((d.total_deaths / c.total_cases),4)*100 as case_fatality_rate -- The case fatality rate is a percentage

FROM CovidDeaths as d

LEFT JOIN CovidConfirmedCases as c
ON d.location = c.location
AND d.date_updated = c.date

WHERE   d.location IS NOT NULL
		AND d.total_deaths IS NOT NULL
		AND c.total_cases IS NOT NULL

ORDER BY d.date_updated Desc, case_fatality_rate DESC;


--- CREATE VIEW for later visualisation of Case fatality rate

Create VIEW CaseFatalityRate as

SELECT  
	    d.location, 
		d.date_updated, 		 
		d.total_deaths, 
		c.total_cases,
		ROUND((d.total_deaths / c.total_cases),4)*100 as case_fatality_rate -- The case fatality rate is a percentage

FROM CovidDeaths as d

LEFT JOIN CovidConfirmedCases as c
ON d.location = c.location
AND d.date_updated = c.date

WHERE   d.location IS NOT NULL
		AND d.total_deaths IS NOT NULL
		AND c.total_cases IS NOT NULL

ORDER BY d.date_updated Desc, case_fatality_rate DESC

OFFSET 0 ROWS
FETCH NEXT 20 ROWS ONLY;


-- Calculate the Population Infection rate: Total cases/ Total Population
-- Display TOP 20 highest infection rate.

SELECT TOP 20 c.location, 
		FORMAT(c.date, 'yyyy-MM-dd') as Updated,
		o.population, 
		c.total_cases, 
		ROUND(((c.total_cases/o.population)*100),2) as population_infection_rate

FROM CovidConfirmedCases as c

LEFT JOIN CovidOthers as o
ON c.location = o.location
	AND c.date = o.date

WHERE   c.continent is not null 
		AND c.location is not null
		AND c.total_cases IS NOT NULL

ORDER BY date_updated DESC, population_infection_rate DESC;

--- CREATE VIEW for later visualisation of Population Infection 


Create VIEW PopulationInfectionRate as

SELECT TOP 20 c.location, 
		FORMAT(c.date, 'yyyy-MM-dd') as Updated,
		o.population, 
		c.total_cases, 
		ROUND(((c.total_cases/o.population)*100),2) as population_infection_rate

FROM CovidConfirmedCases as c

LEFT JOIN CovidOthers as o
ON c.location = o.location
	AND c.date = o.date

WHERE   c.continent is not null 
		AND c.location is not null
		AND c.total_cases IS NOT NULL

ORDER BY Updated DESC, population_infection_rate DESC;


-- Breaking Cumulative Deaths By continent and by country


Select 
		DISTINCT location, 
		MAX(Total_deaths) OVER ( PARTITION BY continent, location ORDER BY location) as TotalDeathCount

From CovidDeaths

WHERE continent is not null 
		AND location is not null

GROUP BY continent, 
		location, date, 
		total_deaths

ORDER BY TotalDeathCount DESC

OFFSET 0 ROWS
FETCH NEXT 20 ROWS ONLY;

-- Total Population vs Vaccinations : Vaccination_rate

-- Showing Top 20

SELECT 
		d.location, 
		MAX (date_updated) as Updated, 
		o.population,  
		MAX(v.people_vaccinated_per_hundred) as Total_Vaccinated_per_hundred, 
		ROUND((MAX(v.people_vaccinated)/ o.population),2)*100 as Vaccination_rate ---- Vaccination_rate as a percentage
 
 FROM CovidDeaths as d
 
 LEFT JOIN CovidVaccination as v
 ON d.location = v.location
    and d.date_updated = v.date

LEFT JOIN CovidOthers as o
		ON d.location = o.location
		AND d.date_updated = o.date

 WHERE d.continent is not null 
		 AND d.location is not null 
 
 GROUP BY d.continent, 
		 d.location, 
		 o.population
 
 ORDER BY Vaccination_rate DESC
 
 OFFSET 0 ROWS
 FETCH NEXT 20 ROWS ONLY;

 --- CREATE VIEW for later visualisation of Vaccination_rate
Create VIEW VaccinationRate as

SELECT Max(date_updated) as Updated, 
		d.Location, 
		o.Population,  
		MAX(v.people_vaccinated_per_hundred) as Total_Vaccinated_per_hundred, 
		ROUND((MAX(v.people_vaccinated)/ o.population),2)*100 as Vaccination_rate
 
 FROM CovidDeaths as d
 
 LEFT JOIN CovidVaccination as v
 ON d.location = v.location
    and d.date_updated = v.date

LEFT JOIN CovidOthers as o
		ON d.location = o.location
		AND d.date_updated = o.date

 WHERE d.continent is not null 
		 AND d.location is not null 
 
 GROUP BY d.continent, 
		 d.location, 
		 o.population
 
 ORDER BY Vaccination_rate DESC
 
 OFFSET 0 ROWS
 FETCH NEXT 20 ROWS ONLY;

 -- Showing Cumulative vaccination_rate, in 2021, in Canada compared to: USA, UK, Australia, India, and South Africa
---- Using CTE to perform Calculation on Partition By in previous query: Vaccination_rate

USE Covid19World
ALTER TABLE CovidVaccination
ALTER COLUMN people_vaccinated FLOAT;

WITH Vaccination AS (
    SELECT  
        d.location, 
        o.population,  
        MAX(v.people_fully_vaccinated) AS Total_Fully_Vaccinated, 
        MAX(MAX(v.people_fully_vaccinated) / o.population * 100) OVER (PARTITION BY d.location) AS Vaccination_Rate --- 
    FROM CovidDeaths AS d
    LEFT JOIN CovidVaccination AS v
    ON d.location = v.location 
    AND d.date_updated = v.date
    LEFT JOIN CovidOthers AS o
    ON d.location = o.location
    AND d.date_updated = o.date
    WHERE d.continent IS NOT NULL 
    AND d.location IS NOT NULL 
    GROUP BY d.location, o.population
)

SELECT 
    location, 
    ROUND(Vaccination_Rate,2) AS Vaccination_rate,
    CASE 
        WHEN Vaccination_Rate > 70 THEN 'High'
        WHEN Vaccination_Rate BETWEEN 50 AND 70 THEN 'Average'
        ELSE 'Low'
    END AS Level_of_Vaccination
FROM Vaccination
ORDER BY Vaccination_Rate DESC
OFFSET 0 ROWS
FETCH NEXT 100 ROWS ONLY;


-- Showing Cumulative Total Deaths in Canada compared to different countries in different continents: USA, UK, Australia, India, and South Africa

Select max(date_updated) as date_updated, 
       Location, 
		MAX(Total_deaths) as TotalDeathCount   -- Total_deaths is a rolling total hence the use of the Max() function
From CovidDeaths
WHERE continent is not null 
		AND location is not null
      AND location in ( 'Canada', 'United States', 'United Kingdom', 'Australia', 'INDIA', 'South Africa')
Group by Location
order by TotalDeathCount desc;

-- CREATE VIEW CanadaTotalDeaths

CREATE VIEW CanadaTotalDeaths as

Select max(date_updated) as date_updated, 
       Location, 
		MAX(Total_deaths) as TotalDeathCount   -- Total_deaths is a rolling total hence the use of the Max() function
From CovidDeaths
WHERE continent is not null 
		AND location is not null
      AND location in ( 'Canada', 'United States', 'United Kingdom', 'Australia', 'INDIA', 'South Africa')
Group by Location

ORDER BY TotalDeathCount desc

OFFSET 0 ROWS
FETCH NEXT 20 ROWS ONLY;


-- Using Temp Table to perform Calculation on Partition By in Total_deaths, 
-- diabetes prevalence, cardiovascular death rates (chronic diseases)

DROP TABLE IF EXISTS #CovidAndChronicDiseases;

CREATE TABLE #CovidAndChronicDiseases
(
    Location NVARCHAR(255),
	date DATETIME,
    Total_deaths NUMERIC,
    cardiovasc_death_rate NUMERIC,
    diabetes_prevalence NUMERIC
);

INSERT INTO #CovidAndChronicDiseases
(
    Location,
	date,
    Total_deaths,
    cardiovasc_death_rate,
    diabetes_prevalence
)
SELECT
    d.location,
	FORMAT(d.date, 'yyyy-MM-dd') as date_updated,    
    MAX(d.Total_deaths) OVER (PARTITION BY d.continent, d.date_updated) AS Cumulative_death,
    o.cardiovasc_death_rate,
    o.diabetes_prevalence

FROM CovidDeaths AS d

LEFT JOIN CovidOthers AS o 

ON d.date_updated = o.date
AND d.continent = o.continent 
		AND d.location = o.location

WHERE d.continent IS NOT NULL 
		AND d.location IS NOT NULL
		AND d.total_deaths IS NOT NULL

ORDER BY d.Continent, d.Location
OFFSET 0 ROWS
FETCH NEXT 400000 ROWS ONLY;

------------- Display the Temp Table

SELECT *
FROM #CovidAndChronicDiseases
ORDER BY date DESC, Location Asc;


---- Creating View to store data for later visualizations

CREATE VIEW CovidChronicDiseases as 

SELECT
    d.location,
	FORMAT(d.date, 'yyyy-MM-dd') as date_updated,    
    MAX(d.Total_deaths) OVER (PARTITION BY d.continent, d.date_updated) AS Cumulative_death,
    o.cardiovasc_death_rate,
    o.diabetes_prevalence

FROM CovidDeaths AS d

LEFT JOIN CovidOthers AS o 

ON d.date_updated = o.date
AND d.continent = o.continent 
		AND d.location = o.location

WHERE d.continent IS NOT NULL 
		AND d.location IS NOT NULL
		AND d.total_deaths IS NOT NULL

ORDER BY d.Continent, d.Location

OFFSET 0 ROWS
FETCH NEXT 400000 ROWS ONLY;

-----  
USE Covid19World
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES

------ Average daily cases during 2021 and 2022

WITH Average_2021 as (
Select location,
         Year(date) as Year_2021,
		 AVG(new_cases) as avg_2021
FROM CovidConfirmedCases
WHERE Year(date) = 2021
GROUP BY location, Year(date)
),

Average_2022 as ( 
Select location,
         Year(date) AS Year_2022,
		 AVG(new_cases) as avg_2022
FROM CovidConfirmedCases
where Year(date) = 2022
GROUP BY location, Year(date)
)

SELECT c.location,
       ROUND(y1.avg_2021,2) as Average_2021,
	   ROUND(y2.avg_2022,2) as Average_2022

FROM CovidConfirmedCases as c

LEFT JOIN Average_2021 as y1
on c.location = y1.location

LEFT JOIN Average_2022 as y2
on c.location = y2.location

GROUP BY c.location,
       y1.avg_2021,
	   y2.avg_2022

ORDER BY c.location;


---- Ranking of the Average icu patients to hosp patients per million

USE Covid19World

ALTER TABLE CovidHospitalICU
ALTER COLUMN hosp_patients_per_million FLOAT;

ALTER TABLE CovidHospitalICU
ALTER COLUMN icu_patients_per_million FLOAT;

WITH Average_HospICU AS (
    SELECT
        location,
        Year(date) AS Year_2021,
        ROUND(AVG(NULLIF(icu_patients_per_million, 0) / NULLIF(hosp_patients_per_million, 0)) * 100, 2) AS Rolling_Average_Hosp_to_ICU_2021
    FROM
        CovidHospitalICU
    WHERE
        Year(date) = 2021
        AND icu_patients_per_million IS NOT NULL
        AND hosp_patients_per_million IS NOT NULL
    GROUP BY
        location, Year(date)
)
SELECT
    location,
    year_2021,
    AVG(Rolling_Average_Hosp_to_ICU_2021) AS Annual_Average_Hosp_To_ICU_2021,
    RANK() OVER (ORDER BY AVG(Rolling_Average_Hosp_to_ICU_2021) DESC) AS Ranking
FROM
    Average_HospICU
GROUP BY
    location, year_2021
ORDER BY
    Ranking ASC;

--- Countries with high bed density (hospital beds per thousand) and high excess mortality
--- high hospital beds > 4, STANDARD 2 - 4, LOW <2
--- exccess mortality > average
USE Covid19World
 SELECT *
 FROM CovidExcessmortality

 SELECT *
 FROM CovidVaccination

 SELECT*
 FROM CovidOthers
 -------------

 ALTER TABLE CovidExcessmortality
 ALTER COLUMN excess_mortality_cumulative_per_million FLOAT;

WITH bed_density_level AS ( ------- Countries with high hospital density 
    SELECT
        location,
        ROUND(AVG(hospital_beds_per_thousand), 2) AS bed_density
    FROM
        CovidOthers
    WHERE
        YEAR(date) = 2021
    GROUP BY
        location
    HAVING
        AVG(hospital_beds_per_thousand) IS NOT NULL
),
AVG_excess_mortality AS ( -------- Countries with high excess mortality
    SELECT
        location,
        (SELECT AVG(excess_mortality_cumulative_per_million) AS AVG_world
         FROM CovidExcessmortality
         WHERE YEAR(date) = 2021) AS Avg_World_2021,
        AVG(excess_mortality_cumulative_per_million) OVER (PARTITION BY location) AS AVG_excess_mortality_cumulative_per_million
    FROM
        CovidExcessmortality
    WHERE
        excess_mortality_cumulative_per_million IS NOT NULL
        AND YEAR(date) = 2021
    GROUP BY
        location,
        excess_mortality_cumulative_per_million
)
---- Countries with high hospital density and high excess mortality
SELECT DISTINCT
    bed.location,
    bed.bed_density,
    CASE
        WHEN bed.bed_density < 2 THEN 'Low bed density'
        WHEN bed.bed_density > 4 THEN 'High bed density'
        ELSE 'Standard'
    END AS Level_Bed_density,
    ROUND(excess.AVG_excess_mortality_cumulative_per_million, 2) AS AVG_excess_mortality_cumulative_per_million,
    CASE
        WHEN excess.AVG_excess_mortality_cumulative_per_million > excess.Avg_World_2021 THEN 'High Excess Mortality'
        WHEN excess.AVG_excess_mortality_cumulative_per_million < excess.Avg_World_2021 THEN 'Low Excess Mortality'
        ELSE ''
    END AS Excess_Mortality_Level
FROM
    bed_density_level AS bed
JOIN
    AVG_excess_mortality AS excess
ON
    bed.location = excess.location
WHERE
    bed.bed_density > 4
    AND excess.AVG_excess_mortality_cumulative_per_million > excess.Avg_World_2021
ORDER BY
    bed.bed_density DESC;

