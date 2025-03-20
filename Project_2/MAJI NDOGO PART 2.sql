USE md_water_services;
SELECT
CONCAT(LOWER(REPLACE(employee_name, ' ', ',')), '@ndogowater.gov') AS new_email 
FROM md_water_services.employee;

-- Create an email for employees using @ndogowater.gov

SET SQL_SAFE_UPDATES=0;
UPDATE md_water_services.employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', ',')), '@ndogowater.gov');


USE md_water_services;

SELECT
*
FROM employee;


SELECT
LENGTH(phone_number)
FROM employee;

-- Trim off the trailing whitespaceS in the phone number
SELECT
RTRIM(phone_number) AS Trimmed_number
FROM employee;

-- Updating our phone number
SET SQL_SAFE_UPDATES=0;
UPDATE md_water_services.employee
SET phone_number = RTRIM(phone_number);

-- Let's have a look at where our employees live

SELECT
town_name,
count(employee_name) AS No_of_employees
FROM md_water_services.employee
GROUP BY(town_name);


-- employee_ids and use those to get the names, email and phone numbers of the three field surveyors with the most location visits.





SELECT * FROM md_water_services.visits;

SELECT
assigned_employee_id, 
SUM(visit_count) AS Number_of_visits
FROM Visits
GROUP BY assigned_employee_id
ORDER BY Number_of_visits  DESC
LIMIT 3;

-- Employee ID is 1,30 and 34

-- We are looking for the Employee name, email addresses and phone numbers of the top 3 employees 

SELECT
employee_name,
phone_number,
email,
position
FROM employee
WHERE assigned_employee_id IN (1,30,34);

-- Analysing our location 
-- Create a query that counts the number of records per town
SELECT
town_name,
COUNT(location_id) AS Records_per_town
FROM
location
GROUP BY town_name
ORDER BY Records_per_town DESC;

-- Count the record per province 
SELECT
province_name,
COUNT(location_id) AS Records_per_province
FROM
location
GROUP BY province_name
ORDER BY Records_per_province DESC;


/*Can you find a way to do the following:
1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. Within each province, further sort the towns by their record counts in descending order.*/

USE md_water_services;
SELECT
province_name,
town_name,
COUNT(location_id) AS records_per_town
from location
GROUP BY province_name,town_name
ORDER BY province_name, records_per_town DESC;

SELECT
location_type,
COUNT(location_id) AS records_per_LOCATION_TYPE
from location
GROUP BY location_type 
ORDER BY location_type DESC;

-- Rounding up Maji Ndogo's Waer source in Rural Area

SELECT ROUND(23740 / (15910 + 23740) * 100) AS Percentage_of_maji_Ndogo_water_source;

-- 1. How many people did we survey in total?

SELECT 
SUM(number_of_people_served) AS number_of_people_surveyed
FROM water_source;

-- 2. How many wells, taps and rivers are there?
SELECT 
type_of_water_source,
COUNT(type_of_water_source) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;

-- 3. How many people share particular types of water sources on average?
SELECT
type_of_water_source,
ROUND(AVG(number_of_people_served)) AS AVG_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY AVG_people_per_source DESC;

-- 4. How many people are getting water from each type of source?
SELECT
type_of_water_source,
SUM(number_of_people_served) AS number_of_people_served_by_water_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_people_served_by_water_source DESC;

--  Percentage of number of people served
SELECT
type_of_water_source,
ROUND(SUM(number_of_people_served)/27628140 *100) AS Pct_number_of_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY Pct_number_of_people_served DESC;

-- We ranked the number of people served by population

SELECT
type_of_water_source,
SUM(number_of_people_served),
RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS Rank_by_population
FROM water_source
WHERE type_of_water_source != 'tap_in_home'
GROUP BY type_of_water_source
ORDER BY Rank_by_population ASC;

-- Ranking by source Id and type of water source to know which to tackle first

select
source_id,
type_of_water_source,
number_of_people_served,
RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS Prioty_rank
FROM water_source
WHERE type_of_water_source <> 'tap_in_home';

-- We calculated how long the survey took

SELECT
DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS Total_number_of_days
FROM visits;

-- Getting the average queue time in Maji Ndodo

SELECT
ROUND(AVG(NULLIF(time_in_queue,0))) As AVG_time_in_queue
FROM visits;

-- Getting the averaage time by the day of the week

SELECT
DAYNAME(time_of_record) As Days_of_the_week,
ROUND(AVG(NULLIF(time_in_queue,0))) As AVG_time_in_queue
FROM visits
GROUP BY Days_of_the_week;


-- Getting the hours people queue the most

SELECT
HOUR(time_of_record) As Hour_of_day,
ROUND(AVG(NULLIF(time_in_queue,0))) As AVG_time_in_queue
FROM visits
GROUP BY Hour_of_day
ORDER BY Hour_of_day;

-- Changing the time format
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
ROUND(AVG(NULLIF(time_in_queue,0))) As AVG_time_in_queue
FROM visits
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- Break the time of the day into days of the week and Differrent hors of the day

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END )) AS Sunday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END )) AS Monday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END )) AS Tuesday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END )) AS Wedesday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END )) AS Thursday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END )) AS Friday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END )) AS Saturday
FROM
visits
WHERE time_in_queue != 0 -- this exludes other sources with 0 queue times.
GROUP BY hour_of_day
ORDER BY hour_of_day;
