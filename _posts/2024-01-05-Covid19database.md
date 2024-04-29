---
layout: post
title: "Exploring the COVID-19 World Database And 
Calculating Three Key Public Health Indicators Using SQL"
description:
date: 2024-01-05
feature_image: images/Covid19.jpg
tags: [SQL, Public Health]
---

Exploring the COVID-19 World Database And Calculating Three Key Public Health Indicators Using SQL


<!--more-->

## Database Overview
The Covid19World database contains several crucial tables for understanding the global impact of Covid-19, including CovidDeaths, CovidConfirmedCases, CovidVaccination, and CovidOthers. 
The SQL queries cover a range of operations, including data exploration, data cleaning, complex queries, view creation, and temporary table manipulation, reflecting the coder's ability to handle extensive and intricate database tasks effectively.

## Data Exploration
The exploration phase utilized the sp_help stored procedure to describe the structure of the tables: CovidDeaths, CovidVaccination, CovidOthers, CovidConfirmedCases, and CovidHospitalICU. 
These tables include key information about COVID-19's impact across different global locations and dates, which were ordered by location and date to organize the data chronologically and geographically.
<pre>
<code>
- - Continues to select the Covid19World database for operations.

USE Covid19World;

- - Retrieves table structure information

EXEC sp_help 'CovidDeaths';
EXEC sp_help 'Covidvaccination';
EXEC sp_help 'CovidOthers';
EXEC sp_help 'CovidConfirmedCases';
</code>
</pre>
Examining the CovidDeaths table with ORDER BY continent, location provided a preliminary overview of the data organized by continent and location.
<pre>
<code>
SELECT *
FROM CovidDeaths
ORDER BY continent, location;
</code>
</pre>
       
## Data Cleaning

A key step in data cleaning includes ensuring data consistency by excluding rows with missing values in crucial columns. Therefore, we filtered the CovidDeaths table to exclude rows with missing values in continent and location columns. 
Next, a new column date_updated was added to CovidDeaths and populated with the date formatted as "YYYY-MM-DD" to facilitate temporal analysis. This simplifies working with dates and improves readability and efficiency.
<pre>
<code> 
-- Ensures data integrity by excluding rows where 'continent' or 'location' is null.

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL AND location IS NOT NULL
ORDER BY continent, location;

-- Adds a new column for storing formatted dates.

ALTER TABLE CovidDeaths
ADD date_updated VARCHAR(10);

-- Formats the 'date' column into 'YYYY-MM-DD'

UPDATE CovidDeaths
SET date_updated = CONVERT(VARCHAR(10), date, 120);
</code>
</pre>
## Analysis and Insights

##Top 20 Countries by Cumulative Death Count
The query identified the top 20 countries with the highest cumulative death count by the most recent date available. This was facilitated by a grouping and ordering operation on the CovidDeaths table, highlighting the severe impact in specific countries.
<pre>
<code> 
SELECT location, Max(date_updated) as Updated, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL AND location IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;
</code>
</pre>
## Cumulative Deaths
The query displaying continent, location, date_updated, and total_deaths ordered by the most recent date provides a snapshot of the latest cumulative deaths reported across different locations.
<pre>
<code>     
-- Orders by the most recent 'date_updated'
       
SELECT continent, location, date_updated, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL AND location IS NOT NULL 
       AND total_deaths IS NOT NULL
ORDER BY date_updated DESC;  
</code>
</pre>
## Case Fatality Rate
To calculate the case fatality rate (total deaths divided by total cases), the data types of total_cases and total_deaths in CovidConfirmedCases and CovidDeaths tables were changed to FLOAT respectively. This allows for numerical calculations.
The subsequent query joins the CovidDeaths and CovidConfirmedCases tables based on location and date. It calculates the case fatality rate as a percentage and displays the results ordered by the latest date and then by the case fatality rate in descending order. This allows us to identify locations with the highest case fatality rates as of the latest update.
<pre>
<code>
-- Corrects data types for accurate calculations.

ALTER TABLE CovidConfirmedCases
ALTER COLUMN total_cases FLOAT;
--
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

-- Calculates and orders by case fatality rate.
-- The case fatality rate is a percentage

SELECT d.location, d.date_updated, d.total_deaths, c.total_cases,
       ROUND((d.total_deaths / c.total_cases) * 100, 4) AS case_fatality_rate
FROM CovidDeaths AS d
LEFT JOIN CovidConfirmedCases AS c ON d.location = c.location 
                                   AND d.date_updated = c.date
WHERE d.location IS NOT NULL 
    AND d.total_deaths IS NOT NULL 
    AND c.total_cases IS NOT NULL
ORDER BY d.date_updated DESC, case_fatality_rate DESC;
</code>
</pre>
## Population Infection Rate
The final query calculates the population infection rate (total cases divided by total population) and displays the top 100 locations with the highest infection rates. It joins the CovidConfirmedCases and CovidOthers tables based on location and date. The population data is retrieved from the CovidOthers table. The results are ordered by the latest date and then by the population infection rate in descending order. This helps identify the locations with the most significant spread of the virus relative to their population size.
<pre>
<code>
-- Calculate the Population Infection rate: Total cases/ Total Population
-- Display TOP 100 highest infection rates, ensuring all necessary columns are non-null.

SELECT c.location, FORMAT(c.date, 'yyyy-MM-dd') AS date_updated, 
       o.population, c.total_cases,
       ROUND((c.total_cases / o.population) * 100, 2) AS population_infection_rate
FROM CovidConfirmedCases AS c
LEFT JOIN CovidOthers AS o ON c.location = o.location AND c.date = o.date
WHERE c.continent IS NOT NULL 
       AND c.location IS NOT NULL AND c.total_cases IS NOT NULL
ORDER BY date_updated DESC, population_infection_rate DESC
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY;
</code>
</pre>
## Vaccination Analysis
The vaccination rate was calculated as the percentage of the population that has been vaccinated, identifying the top 20 locations with the highest rates. 
<pre>
<code>
SELECT d.location, MAX (date_updated) as Updated, o.population,  
       MAX(v.people_vaccinated_per_hundred) as Total_Vaccinated_per_hundred, 
       ROUND((MAX(v.people_vaccinated)/ o.population),2)*100 as Vaccination_rate
FROM CovidDeaths AS d
LEFT JOIN CovidVaccination AS v ON d.location = v.location AND d.date_updated = v.date
LEFT JOIN CovidOthers AS o ON d.location = o.location AND d.date_updated = o.date
WHERE d.continent IS NOT NULL AND d.location IS NOT NULL 
GROUP BY d.continent, d.location, o.population
ORDER BY Vaccination_rate DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;
</code>
</pre>
## Comparative Analysis: 
## 1-Chronic Diseases and COVID-19
A temporary table, #CovidAndChronicDiseases, was created to explore the correlation between COVID-19 deaths and chronic diseases like cardiovascular issues and diabetes.
<pre>
<code>
DROP TABLE IF EXISTS #CovidAndChronicDiseases;
CREATE TABLE #CovidAndChronicDiseases (
    Location NVARCHAR(255),
    date DATETIME,
    Total_deaths NUMERIC,
    cardiovasc_death_rate NUMERIC,
    diabetes_prevalence NUMERIC
);

INSERT INTO #CovidAndChronicDiseases (
    Location, date, Total_deaths, cardiovasc_death_rate, diabetes_prevalence
)
SELECT d.location, FORMAT(d.date, 'yyyy-MM-dd') as date_updated,    
       MAX(d.Total_deaths) OVER (PARTITION BY d.continent, d.date_updated) AS Cumulative_death,
       o.cardiovasc_death_rate, o.diabetes_prevalence
FROM CovidDeaths AS d
LEFT JOIN CovidOthers AS o ON d.date_updated = o.date AND d.continent = o.continent AND d.location = o.location
WHERE d.continent IS NOT NULL AND d.location IS NOT NULL AND d.total_deaths IS NOT NULL
ORDER BY d.Continent, d.Location;
</code>
</pre>
## 2-International Comparisons
The queries facilitated international comparisons, such as assessing vaccination rates and cumulative deaths in Canada relative to other nations like the USA, UK, and India. This comparative approach provides a broader context for evaluating Canada's pandemic response.

##. Reporting and Visualization
The script emphasizes the creation of views for later visualization, aiding in reporting:
<pre>
<code>
CREATE VIEW CaseFatalityRate AS 
SELECT location, date_updated, total_deaths, total_cases,
ROUND((total_deaths / total_cases) * 100, 4) as case_fatality_rate
FROM ...;
</code>
</pre>

## Conclusion
This project SQL highlights the critical insights that can be derived from well-structured SQL queries in understanding public health crises.
