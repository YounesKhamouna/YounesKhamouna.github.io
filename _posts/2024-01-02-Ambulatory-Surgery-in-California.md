---
layout: post
title: "Ambulatory Surgery in California"
description:
date: 2024-01-02
feature_image: images/PowerBi.jpg
tags: [PowerBI, Dashboard]
---

This project utilized a comprehensive dataset comprising annual ambulatory surgery summary data in California, USA. I limited the timeframe for the data analysis to a period of five years, from 2017 to 2021.
The dataset offers valuable insights and holds potential for future predictive analysis.

<!--more-->

## THE DATA
There are 2 datasets for this project extracted from the website of the Department of Health Care Access and Information. 
You can access the datasets from the links below: 
-	Ambulatory Surgery - Characteristics by Patient County of Residence:  https://data.chhs.ca.gov/dataset/ambulatory-surgery-characteristics-by-patient-county-of-residence_ 
-	Ambulatory Surgery - Diagnosis, Procedure, and External Cause Codes : https://data.chhs.ca.gov/dataset/ambulatory-surgery-diagnosis-procedure-and-external-cause-codes 
The first dataset specifically focuses on patients' county of residence and encompasses essential information such as discharge disposition, expected payer, sex, and race group. Additionally, the second dataset includes statewide counts for each diagnosis and procedure, with diagnosis codes reported using either ICD-9-CM or ICD-10-CM, while procedure codes are reported using CPT-4. 

## Techniques Used 
1. Data Modelling
2. Filters
3. Slicers
4. Drill-throughs
5. Bookmarks
6. DAX: CALCULATE, SUM, DISTINCTCOUNT, GROUPBY


## QUESTIONS TO ANSWER
1-	What are the top 5 common ambulatory surgery diagnosis performed in Californian hospitals, and how have they changed over the years?
2-	What is the most common outcome after an ambulatory surgery in California?
3-	Which payer(s) are most associated with ambulatory surgeries in California hospitals?
4-	Is there a gender disparity in the utilization of ambulatory surgery services in California?
5-	Is there a racial imbalance in the utilization of ambulatory surgeries?

## The Dashboard
The dashboard comprises four pages with the overarching theme of "Ambulatory Surgery in California." These pages are organized as follows:

## 1. Overview Page: This page provides a high-level summary of the field of ambulatory surgery within California. It provides essential statistics, including the number of patients, encounters, diagnoses, procedures, and payers, offering a panoramic view of the field.

## 2. Diagnosis Page: On this page, you will find a detailed breakdown of ambulatory surgery cases categorized by diagnosis, year, and corresponding ICD10 code. This page allows to shed light on the prevalent medical conditions treated through ambulatory surgery in California.

## 3. Procedures Page: This page focuses on the procedures performed in ambulatory surgery settings, offering a comprehensive breakdown of the types of surgeries conducted in California.

## 4. **Race and Gender Breakdown Page**: Here, you'll discover statistics and data related to ambulatory surgeries categorized by race and by gender, providing insights into the demographic aspects of ambulatory surgical care within the state.

Each of these pages contributes to a holistic understanding of ambulatory surgery in California, offering valuable insights from different angles for a more comprehensive view of this critical healthcare domain.

## DATA ANALYSIS

## 1.	How has the number of ambulatory surgeries changed over the years in different counties of California?
The number of ambulatory surgeries performed in California has shown a consistent increase since 2017, with a significant decline in the initial year of the COVID-19 pandemic. However, starting in 2021, the upward trend resumed, indicating a positive growth trajectory.

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/7cc55597-ea9f-4161-a7be-1c266dbac90c)

## 2-	What is the top diagnosis associated with ambulatory surgery performed in Californian hospitals, and how has it changed over the years?
The top diagnosis associated with ambulatory surgery in California hospitals during the 2017-2021 timeframe is Essential Hypertension.
The ICD-10 code I10, which corresponds to essential hypertension, was utilized in approximately 2.7 million encounters.

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/1c814bba-c93b-45bc-b686-8db957d6ac57)

Starting from 2017, there was a consistent growth in the utilization of this diagnosis until 2020 when the COVID-19 pandemic had a significant impact. Consequently, the use of the I10 code experienced a sharp decline, reaching a low point of nearly 480,000 encounters. 
However, following the initial year of the pandemic, the utilization of essential hypertension as a diagnosis is expected to recover and return to the same level as before the pandemic.

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/b2e07246-8480-4ce7-9e11-864e6351e9e6)

## 2-	What is the most common outcome after ambulatory surgery in California?
The most probable outcome following ambulatory surgery is a discharge to home. Out of the total patients, 1074 individuals unfortunately passed away, while approximately 20 million patients were successfully discharged to their homes. Additionally, the number of patients who died has slightly decreased during this period from 160 in 2012 to 94 in 2021.

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/28cb49ed-2551-4b97-8aab-311f05bcaba2)

These findings suggest that ambulatory surgery performed in California hospitals is generally a safe procedure. Moreover, it may indicate that patients selected for this type of surgery have a lower likelihood of experiencing adverse outcomes and are more likely to have a safe recovery.

## 3-	Which payer(s) are most commonly associated with ambulatory surgeries in California hospitals?
On the financial side, the top payer expected after an ambulatory surgery in California hospitals between 2017-2021 is Medicare Part B. 
A reminder that “Medicare Part B (Medical Insurance) are available to the individuals below:
•	Age 65 or older  
•	Disabled
•	End-Stage Renal Disease (ESRD)” cms.gov

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/81fc3a10-8494-477e-bfd5-b52a42a25f8d)

## 4-	Is there a gender disparity in the utilization of ambulatory surgery services in California? Is there a racial imbalance ?

More female benefited from ambulatory surgery in California hospitals.

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/faf556dc-f9be-4591-9a32-f58bc37c595e)

The same trend was observed in Los Angles, the most populated city in California. The Covid19 pandemic has almost the same impact in both reported sexes. 

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/51e8a5d8-bad4-442a-ad20-f5d9d309fa30)

In terms of absolute numbers, individuals from the white racial group have the highest representation in receiving ambulatory surgeries (4M), followed by the Hispanic group(2M). 
However, despite the equal proportions of these two populations in California(30%), there is an evident disparity in the distribution of benefits from ambulatory surgery among different racial groups. 
The proportion of individuals belonging to the black racial group who undergo ambulatory surgeries is nearly proportional to their representation in the general population.

![image](https://github.com/YounesKhamouna/youneskhamouna.github.io/assets/142261924/16b0da94-3871-497a-a9bf-7341fb134909)

