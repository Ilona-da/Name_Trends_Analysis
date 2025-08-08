-- ============================
-- OBJECTIVE: Create View to import to POWER BI
-- ============================

CREATE OR ALTER VIEW v_names_dataset AS 

WITH 
genders_count AS (
	SELECT Name, COUNT(DISTINCT Gender) AS genders, SUM(Births) AS num_babies
	FROM names
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

SELECT n.State, 
		r.Region,
		n.Year, 
		CASE 
			WHEN Year BETWEEN 1980 AND 1989 THEN '80s'
			WHEN Year BETWEEN 1990 AND 1999 THEN '90s'
			WHEN Year BETWEEN 2000 AND 2009 THEN '00s'
			ELSE 'None'
		END AS decade,
		CASE 
			WHEN Year BETWEEN 1980 AND 1989 THEN 1
			WHEN Year BETWEEN 1990 AND 1999 THEN 2
			WHEN Year BETWEEN 2000 AND 2009 THEN 3
		ELSE 0
		END AS decade_order,
		first_appearance_year, 
		n.Name,
		LEFT(n.Name, 1) AS name_first_letter,
		LEN(n.Name) AS name_length,
		CASE 
			WHEN LEN(n.Name) <= 4 THEN 'short'
			WHEN LEN(n.Name) BETWEEN 5 AND 7 THEN 'medium'
			ELSE 'long'
		END AS name_type,
		CASE 
			WHEN n.Gender = 'M' THEN 'Boy'
			WHEN n.Gender = 'F' THEN 'Girl'
		ELSE 'Unknown' END AS gender_flag,
		CASE 
			WHEN gc.genders > 1 THEN 1
			ELSE 0
		END AS is_androgynous,
		CASE 
			WHEN pct_after_2000 >= 0.8 THEN 1
			ELSE 0
		END AS is_trendy,
		CASE 
			WHEN gc.num_babies < 1000 THEN 1
		ELSE 0
		END AS is_rare,
		CASE 
			WHEN pct_after_2000 <= 0.2 THEN 1
		ELSE 0
		END AS is_declining,
		CASE 
			WHEN gc.num_babies < 100 THEN 'very rare'
			WHEN gc.num_babies < 1000 THEN 'rare'
			WHEN gc.num_babies < 10000 THEN 'common'
		ELSE 'very common'
		END AS name_popularity_bin,
		n.Births
FROM names n
LEFT JOIN genders_count gc
ON n.Name = gc.Name
LEFT JOIN first_appearance fa
ON n.Name = fa.Name
LEFT JOIN name_trendy_flag ntf
ON n.Name = ntf.Name
LEFT JOIN regions r ON n.State = r.State;
 