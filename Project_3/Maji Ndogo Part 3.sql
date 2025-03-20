USE md_water_services;
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

SELECT 
* 
FROM md_water_services.auditor_report;

-- Integrating the auditor's report

SELECT
a.location.id AS auditor_location,
a.true_water_source_score,
v.record_id AS Visit_location,
v.record_id
FROM auditor_report AS a
	INNER JOIN
Visits AS v;

 /*Joining water quality table to the results using the record ID that is both present in the Visit table and 
the Water quality table as the connecting key */

SELECT
	A.location_id,
    A.true_water_source_score,
	A.type_of_water_source,
    V.record_id,
    W.subjective_quality_score
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id;
    
-- Renaming our table and also froping one location_ID since it is duplicated 

SELECT
	A.location_id,
    V.record_id,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id;

-- Checking If the auditor's score is equal to the survery score

SELECT
	A.location_id,
    V.record_id,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id
WHERE A.true_water_source_score = W.subjective_quality_score
AND V.Visit_count =1; -- This condition was added to remove duplicate and retun the location which was visited once

-- Checking incorrect records

SELECT
	A.location_id,
    V.record_id,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id;

-- Checking If the auditor's score is equal to the survery score

SELECT
	A.location_id,
    V.record_id,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id
WHERE A.true_water_source_score != W.subjective_quality_score
AND V.Visit_count =1;

-- Checking if the type of water source is the same
SELECT
	A.location_id,
    Ws.type_of_water_source AS Survey_source,
    A.type_of_water_source AS auditor_source,
    V.record_id,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score
   
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id
JOIN
	water_source Ws -- We joined the water source table to this check if the type of water source is the same for the each Source ID even though they are incorrect rows.
ON Ws.source_id = V.source_id 
WHERE A.true_water_source_score != W.subjective_quality_score
AND V.Visit_count =1;

-- We removed the water source table and reverted back since we are done with chcking what we wanted to

SELECT
	A.location_id,
    V.record_id,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id;

-- We want to find out which employees made errors so we added the employee column to our join and also retrieved the employee name

SELECT
	A.location_id,
    V.record_id,
	E.employee_name AS Employee_name,
    A.true_water_source_score AS auditor_score, 
    W.subjective_quality_score AS survey_score,
    A.statements
FROM 
	auditor_report A
JOIN 
	visits V
ON	A.location_id = V.location_id
JOIN
	water_quality W
ON	V.record_id = W.record_id
JOIN
	employee E
ON	E.assigned_employee_id = V.assigned_employee_id
WHERE A.true_water_source_score != W.subjective_quality_score
AND V.Visit_count =1;

-- Since our query is getting long, we want to create a CTE instead so that it wold be easy to recall the CTE for other purposes

WITH Incorrect_records AS(
		SELECT
			A.location_id,
			V.record_id,
			E.employee_name AS Employee_name,
			A.true_water_source_score AS auditor_score, 
			W.subjective_quality_score AS survey_score
		FROM 
			auditor_report A
		JOIN 
			visits V
		ON	A.location_id = V.location_id
		JOIN
			water_quality W
		ON	V.record_id = W.record_id
		JOIN
			employee E
		ON	E.assigned_employee_id = V.assigned_employee_id
		WHERE A.true_water_source_score != W.subjective_quality_score
		AND V.Visit_count =1
        )
	SELECT 
    DISTINCT(Employee_name),
    COUNT(Employee_name) AS Number_of_mistakes
    FROM Incorrect_records
    GROUP BY Employee_name;
    
    -- Gatheriing Evidence


WITH Incorrect_records AS(
		SELECT
			A.location_id,
			V.record_id,
			E.employee_name AS Employee_name,
			A.true_water_source_score AS auditor_score, 
			W.subjective_quality_score AS survey_score,
            A.statements AS statements
		FROM 
			auditor_report A
		JOIN 
			visits V
		ON	A.location_id = V.location_id
		JOIN
			water_quality W
		ON	V.record_id = W.record_id
		JOIN
			employee E
		ON	E.assigned_employee_id = V.assigned_employee_id
		WHERE A.true_water_source_score != W.subjective_quality_score
		AND V.Visit_count =1
        ),
    error_count AS
			(SELECT -- We are trying to count the amount of incorrect records by employee name
					Employee_name,
					COUNT(Employee_name) AS number_of_mistakes
					FROM Incorrect_records
					GROUP BY Employee_name
    ),
    Suspect_list AS ( /*Creating a suspect list: This subquery is to retrieve employee name where number of mistakes is greater than 
						 the Average number of mistake the error count*/
    SELECT 
        employee_name,
        number_of_mistakes
    FROM 
        error_count
    WHERE 
        number_of_mistakes > (
            SELECT AVG(number_of_mistakes) 
            FROM error_count
        )
)
SELECT employee_name, location_id, statements
    FROM incorrect_records
    WHERE employee_name IN (
			SELECT
				Employee_name
				From Suspect_list) 
	AND statements LIKE ('%Cash%');
    
	
    
    
     SELECT 
        DISTINCT(location_id)
    FROM 
      auditor_report;

