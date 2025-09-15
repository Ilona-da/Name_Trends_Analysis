-- ============================
-- OBJECTIVE: Create Views to import to POWER BI
-- ============================

-- Dimension table: dim_name

CREATE OR ALTER VIEW v_dim_name AS 

WITH 
name_gender_stats AS (
   SELECT Name, Gender, SUM(Births) AS births_per_gender
   FROM names
   GROUP BY Name, Gender
),
genders_agg AS (
    SELECT 
        Name,
        COUNT(DISTINCT Gender) AS genders,
        SUM(births_per_gender) AS total_babies,
        MIN(births_per_gender) AS min_gender_births,
        MAX(births_per_gender) AS max_gender_births
    FROM name_gender_stats
    GROUP BY Name
),
first_appearance AS (
	SELECT 
		Name, 
		MIN(Year) AS first_appearance_year
	FROM names
	GROUP BY Name
),
name_trendy_flag AS (
	SELECT 
		Name,
		SUM(CASE WHEN Year >= 2000 THEN Births ELSE 0 END) * 1.0 / SUM(Births) AS pct_after_2000
	FROM names
	GROUP BY Name
)

SELECT	
   ROW_NUMBER() OVER(ORDER BY n.Name, n.Gender) AS name_id,
	n.Name,
	first_appearance_year, 
	LEFT(n.Name, 1) AS first_letter,
	LEN(n.Name) AS name_length,

	CASE 
		WHEN LEN(n.Name) <= 4 THEN 'short'
		WHEN LEN(n.Name) BETWEEN 5 AND 7 THEN 'medium'
		ELSE 'long'
	END AS length_type,

	n.Gender AS gender_code,
	CASE 
		WHEN n.Gender = 'M' THEN 'Male'
		WHEN n.Gender = 'F' THEN 'Female'
		ELSE 'Unknown' 
	END AS gender_label,
	CASE 
		WHEN ga.genders > 1 
		   AND ga.min_gender_births > 500 
		   AND ga.min_gender_births * 1.0 / ga.total_babies >= 0.20
		THEN 1 ELSE 0
	END AS is_androgynous,

	CASE WHEN ntf.pct_after_2000 >= 0.8 THEN 1 ELSE 0 END AS is_trendy,
	CASE WHEN ntf.pct_after_2000 <= 0.2 AND ga.total_babies > 1000 THEN 1 ELSE 0 END AS is_declining,

	CASE 
		WHEN ga.total_babies < 100 THEN 'very rare'
		WHEN ga.total_babies < 1000 THEN 'rare'
		WHEN ga.total_babies < 10000 THEN 'common'
		ELSE 'very common'
	END AS popularity

FROM (SELECT DISTINCT Name, Gender FROM names) n
LEFT JOIN genders_agg ga ON n.Name = ga.Name
LEFT JOIN first_appearance fa ON n.Name = fa.Name
LEFT JOIN name_trendy_flag ntf ON n.Name = ntf.Name;

-- Dimension table: dim_state

CREATE OR ALTER VIEW v_dim_state AS 

WITH clean_regions AS (
	SELECT State, 
		CASE 
			WHEN Region = 'New England' THEN 'New_England' ELSE Region
		END AS clean_region_name
	FROM regions
	UNION
	SELECT 'MI' AS State, 'Midwest' AS clean_region_name
)

SELECT
	ROW_NUMBER() OVER(ORDER BY State) AS state_id,  
	State AS state_code,
	clean_region_name AS region
FROM clean_regions;

-- Dimension table: calendar (to be created in Power BI)

-- Fact table: fact_births

CREATE OR ALTER VIEW v_fact_births AS
	
SELECT 
   dn.name_id,
   ds.state_id, 
	DATEFROMPARTS(n.Year, 1, 1) AS birth_date_year,
	n.Births
FROM names n
LEFT JOIN v_dim_name dn
    ON n.Name = dn.Name
	AND n.Gender = dn.gender_code
LEFT JOIN v_dim_state ds
    ON n.State = ds.state_code;