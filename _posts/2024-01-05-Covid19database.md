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
Each table serves a unique role in providing comprehensive data on deaths, confirmed cases, vaccination figures, and other related metrics.

## Data Exploration
The sp_help stored procedure revealed the schema of four tables: CovidDeaths, Covidvaccination, CovidOthers, and CovidConfirmedCases. Each table likely holds information on a different aspect of Covid-19 data.

> - - Continues to select the Covid19World database for operations.  <br/>
> USE Covid19World;  <br/>
> <br/>
> - - Retrieves table structure information <br/>
> EXEC sp_help 'CovidDeaths'; <br/>
> EXEC sp_help 'Covidvaccination';  <br/>
> EXEC sp_help 'CovidOthers';  <br/>
> EXEC sp_help 'CovidConfirmedCases';  <br/>

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



Examining the CovidDeaths table with ORDER BY continent, location provided a preliminary overview of the data organized by continent and location.  <br/>
>SELECT *  <br/>
>FROM CovidDeaths  <br/>
>ORDER BY continent, location;  <br/>
>  <br/>

## Data Cleaning

A key step in data cleaning includes ensuring data consistency by excluding rows with missing values in crucial columns. Therefore, we filtered the CovidDeaths table to exclude rows with missing values in continent and location columns. 
Next, a new column date_updated was added to CovidDeaths and populated with the date formatted as "YYYY-MM-DD". This simplifies working with dates and improves readability and efficiency.

> -- Ensures data integrity by excluding rows where 'continent' or 'location' is null.
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

> <cite>

## Using SQL Queries To Calculate Public Health Indicators

## Cumulative Deaths
The query displaying continent, location, date_updated, and total_deaths ordered by the most recent date provides a snapshot of the latest cumulative deaths reported across different locations.

> -- Orders by the most recent 'date_updated'.
SELECT continent, location, date_updated, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL AND location IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY date_updated DESC;
>

## Case Fatality Rate
To calculate the case fatality rate (total deaths divided by total cases), the data types of total_cases and total_deaths in CovidConfirmedCases and CovidDeaths tables were changed to FLOAT respectively. This allows for numerical calculations.
The subsequent query joins the CovidDeaths and CovidConfirmedCases tables based on location and date. It calculates the case fatality rate as a percentage and displays the results ordered by the latest date and then by the case fatality rate in descending order. This allows us to identify locations with the highest case fatality rates as of the latest update.

> -- Corrects data types for accurate calculations.

ALTER TABLE CovidConfirmedCases
ALTER COLUMN total_cases FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

-- Calculates and orders by case fatality rate.
-- The case fatality rate is a percentage

SELECT d.location, d.date_updated, d.total_deaths, c.total_cases,
       ROUND((d.total_deaths / c.total_cases) * 100, 4) AS case_fatality_rate
FROM CovidDeaths AS d
LEFT JOIN CovidConfirmedCases AS c ON d.location = c.location AND d.date_updated = c.date
WHERE d.location IS NOT NULL AND d.total_deaths IS NOT NULL AND c.total_cases IS NOT NULL
ORDER BY d.date_updated DESC, case_fatality_rate DESC;
>

## Population Infection Rate
The final query calculates the population infection rate (total cases divided by total population) and displays the top 100 locations with the highest infection rates. It joins the CovidConfirmedCases and CovidOthers tables based on location and date. The population data is retrieved from the CovidOthers table. The results are ordered by the latest date and then by the population infection rate in descending order. This helps identify the locations with the most significant spread of the virus relative to their population size.

> -- Calculate the Population Infection rate: Total cases/ Total Population
-- Display TOP 100 highest infection rates, ensuring all necessary columns are non-null.

SELECT c.location, FORMAT(c.date, 'yyyy-MM-dd') AS date_updated, o.population, c.total_cases,
       ROUND((c.total_cases / o.population) * 100, 2) AS population_infection_rate
FROM CovidConfirmedCases AS c
LEFT JOIN CovidOthers AS o ON c.location = o.location AND c.date = o.date
WHERE c.continent IS NOT NULL AND c.location IS NOT NULL AND c.total_cases IS NOT NULL
ORDER BY date_updated DESC, population_infection_rate DESC
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY;
>
