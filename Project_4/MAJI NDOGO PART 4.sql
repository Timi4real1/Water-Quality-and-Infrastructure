
USE md_water_services;
SELECT
	Lo.province_name,
    Lo.location_type,
    Lo.town_name,
    Ws.type_of_water_source,
    Ws.number_of_people_served,
    V.time_in_queue,
    Wp.results
FROM visits V
JOIN location Lo
ON V.location_id = Lo.location_id
JOIN water_source Ws
ON Ws.source_id = V.source_id
LEFT JOIN well_pollution Wp
ON Wp.Source_id = V.source_id
WHERE V.visit_count = 1;

-- We are trying make a view so it will be easier for us to call the query

CREATE VIEW combined_analysis_table AS 
SELECT
	Lo.province_name,
    Lo.location_type,
    Lo.town_name,
    Ws.type_of_water_source,
    Ws.number_of_people_served,
    V.time_in_queue,
    Wp.results
FROM visits V
JOIN location Lo
ON V.location_id = Lo.location_id
JOIN water_source Ws
ON Ws.source_id = V.source_id
LEFT JOIN well_pollution Wp
ON Wp.Source_id = V.source_id
WHERE V.visit_count = 1;

-- We are trying to classify the type of water source and also sum it and convert it into percentages.

WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;

-- This query below is replaced with the above to get the total number of people served
SELECT
*
FROM
province_totals;

-- Since there are duplicates town name, we have to order by towns to be able to show distince tonws in distinct provinces.

WITH town_totals AS (/* This CTE calculates the population of each town
−− Since there are two Harare towns, we have to group by province_name and town_name */
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table AS ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name

GROUP BY -- −− We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.province_name DESC;

/* We want to make our results a temporary table 

Temporary tables in SQL are a nice way to store the results of a complex query. We run the query once, and the results are stored as a table. The
catch? If you close the database connection, it deletes the table, so you have to run it again each time you start working in MySQL. The benefit is
that we can use the table to do more calculations, without running the whole query each time. */

SELECT
*
FROM
province_totals;

-- Since there are duplicates town name, we have to order by towns to be able to show distince tonws in distinct provinces.

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (/* This CTE calculates the population of each town
−− Since there are two Harare towns, we have to group by province_name and town_name */
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table AS ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- −− We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

-- which town has the highest ratio of people who have taps, but have no running water?

WITH town_totals AS (/* This CTE calculates the population of each town
−− Since there are two Harare towns, we have to group by province_name and town_name */
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access;

-- Create a table where our teams have the information they need to fix, upgrade and repair water sources

CREATE TABLE md_water_services.Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same
source more than once in the future.
*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,
and should refer to the source table. This ensures data integrity. */ 

Address VARCHAR(50), -- Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);

-- We are trying to create a query for our project progress table. First things first, let's filter the data to only contain sources we want to improve by thinking through the logic first.
/* 1. Only records with visit_count = 1 are allowed.
2. Any of the following rows can be included:
a. Where shared taps have queue times over 30 min.
b. Only wells that are contaminated are allowed -- So we exclude wells that are Clean
c. Include any river and tap_in_home_broken sources.*/


USE md_water_services;
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
AND (results <> 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source  = 'shared_tap' AND time_in_queue >=30));

-- We are setting up the action to be taken for each water source and typw according to their needs 

USE md_water_services;
SELECT
location.address AS Address,
location.town_name AS Town,
location.province_name AS Province,
water_source.source_id,
water_source.type_of_water_source AS Source_type,
CASE 
WHEN (type_of_water_source = 'well'
AND well_pollution.results = 'Contaminated: Biological') 
THEN 'Install UV and RO filter' -- We added a an improvemnent to Install UV filter if results of the well is Contaminated Biological
WHEN (type_of_water_source = 'well'
AND well_pollution.results = 'Contaminated: Chemical') THEN 'Install RO filter' -- We added a an improvemnent to Install UV filter if results of the well is Contaminated chemical
WHEN (type_of_water_source = 'river') THEN 'Drill Well'
WHEN (type_of_water_source = 'shared_tap' 
AND time_in_queue >= 30) THEN CONCAT("Install ", FLOOR(time_in_queue/30), " taps nearby")
WHEN (type_of_water_source = 'tap_in_home_broken') THEN 'Diagnose_local_infrastructure'
ELSE NULL
END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
AND (results <> 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source  = 'shared_tap' AND time_in_queue >=30));

-- Inserting the query results into the Project Progress table

INSERT INTO md_water_services.project_progress
(Address, Town, Province, source_id, Source_type, Improvement)
SELECT
location.address AS Address,
location.town_name AS Town,
location.province_name AS Province,
water_source.source_id,
water_source.type_of_water_source AS Source_type,
CASE 
WHEN (type_of_water_source = 'well'
AND well_pollution.results = 'Contaminated: Biological') 
THEN 'Install UV and RO filter' -- We added a an improvemnent to Install UV filter if results of the well is Contaminated Biological
WHEN (type_of_water_source = 'well'
AND well_pollution.results = 'Contaminated: Chemical') THEN 'Install RO filter' -- We added a an improvemnent to Install UV filter if results of the well is Contaminated chemical
WHEN (type_of_water_source = 'river') THEN 'Drill Well'
WHEN (type_of_water_source = 'shared_tap' 
AND time_in_queue >= 30) THEN CONCAT("Install ", FLOOR(time_in_queue/30), " taps nearby")
WHEN (type_of_water_source = 'tap_in_home_broken') THEN 'Diagnose_local_infrastructure'
ELSE NULL
END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
AND (results <> 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source  = 'shared_tap' AND time_in_queue >=30));

SELECT
project_progress.Project_id, 
project_progress.Town, 
project_progress.Province, 
project_progress.Source_type, 
project_progress.Improvement,
Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served) AS RANK
FROM  project_progress 
JOIN water_source 
ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served
