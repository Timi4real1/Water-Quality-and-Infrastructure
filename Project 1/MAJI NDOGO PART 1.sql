 SELECT DISTINCT
	type_of_water_source
FROM 
	md_water_services.water_source;


/* The type of water sources includes
 'tap_in_home' 
'tap_in_home_broken'
'well'
'shared_tap'
'river'  */ 

SELECT
*
FROM
	md_water_services.water_source
LIMIT 5;


SELECT
*
FROM
	md_water_services.visits
WHERE time_in_queue >500;

SELECT
*
FROM
	md_water_services.visits;

/*Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min. How
would it feel to queue 8 hours for water?*/

SELECT
*
FROM
	md_water_services.water_source
WHERE 
	source_id 
IN ('AkKi00881224',
	'SoRu37635224',
	'SoRu36096224',
    'AkLu02523224');
    
-- the results from the above query showed that the water source of all the source ID is shared_tap

-- Let's also run the source_id where time_in_queue is also 0

SELECT
	*
FROM 
	md_water_services.water_source
WHERE source_id
IN ('KiRu28935224', 
	'KiRu28520224',
    'AmDa12214224');

-- the results from the above query showed that the water source of 2 of the source id is tap_in_home while one is from the well
    
SELECT
*
FROM
	md_water_services.water_quality
LIMIT 5;



SELECT
*
FROM
	md_water_services.water_quality
WHERE subjective_quality_score = 10
AND visit_count = 2;


SELECT
*
FROM
	md_water_services.well_pollution
WHERE results= 'clean' 
AND biological > 0.01;

-- We need to identify the records that mistakenly have the word Clean in the description
SELECT
*
FROM
	md_water_services.well_pollution
WHERE description LIKE 'clean%'
AND biological > 0.01;

-- Solving 1B. All records that mistakenly have Clean Bacteria: Giardia Lamblia should updated to Bacteria: Giardia Lamblia

CREATE TABLE md_water_services.well_pollution_Copy_2
(
source_id VARCHAR(258),
date DATETIME,
description VARCHAR(255),
pollutant_ppm FLOAT,
biological FLOAT,
results VARCHAR(255)
);

INSERT INTO
	md_water_services.well_pollution_Copy_2 
    (source_id,
date,
description,
pollutant_ppm,
biological,
results)
SELECT 
 *
FROM
	md_water_services.well_pollution
WHERE description LIKE 'clean%'
AND biological > 0.01;

/* In order to avoid error, we created a new table for our well pollution so that we can keep the result of our filtered table in it
, It is titled as well_pollution_copy_2. The next thing we will do now is to update the created table */

SET SQL_SAFE_UPDATES =0;
UPDATE md_water_services.well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE	description = 'Clean Bacteria: Giardia Lamblia';

-- Solving 1A. All records that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli

SET SQL_SAFE_UPDATES =0;
UPDATE md_water_services.well_pollution
SET description = 'Bacteria: E. coli'
WHERE	description = 'Clean Bacteria: E. coli';

-- Solving 2. All records that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli

SET SQL_SAFE_UPDATES =0;
UPDATE md_water_services.well_pollution
SET results = 'Contaminated: Biological'
WHERE results = 'clean'
AND biological > 0.01;








SELECT
*
FROM
	well_pollution
WHERE results = 'clean'
AND	biological >0.01
LIMIT 100;

-- We need to identify the records that mistakenly have the word Clean in the description.
SELECT
*
FROM
	well_pollution
WHERE results = 'Clean'
AND biological >0.01
AND description LIKE 'Clean%';

CREATE TABLE well_pollution_copy
AS (
SELECT 
* 
FROM well_pollution);

SELECT
*
FROM
	well_pollution_copy
WHERE results = 'Clean'
AND biological >0.01
AND description LIKE 'Clean%';

-- Case (1a) update descriptions that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli

SET SQL_SAFE_UPDATES=0;
UPDATE well_pollution_copy
SET description = 'Bacteria; E.coli'
WHERE description = 'Clean Bacteria: E.coli';

-- 1B
SET SQL_SAFE_UPDATES=0;
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

