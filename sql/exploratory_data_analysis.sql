USE baby_names_db;
SELECT TOP 1000 * FROM names;

-- ============================
-- OBJECTIVE 1: Track changes in name popularity
-- ============================

-- 1) How many different names there are in the dataset?

SELECT COUNT(DISTINCT Name)
FROM names;
-- 22 240

-- 2) What was the overall most popular girl name & boy name?

SELECT TOP 1 Name, SUM(Births) AS num_babies
FROM names WHERE Gender = 'F'
GROUP BY Name
ORDER BY num_babies DESC;
-- Jessica

SELECT TOP 1 Name, SUM(Births) AS num_babies
FROM names
WHERE Gender = 'M'
GROUP BY Name
ORDER BY num_babies DESC;
-- Michael

-- 3) How have they changed in popularity rankings over the years?

WITH girl_names AS (
   SELECT Name, Year, SUM(Births) AS num_babies
   FROM names
   WHERE Gender = 'F'
   GROUP BY Name, Year
),
ranked_names AS (
   SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS popularity_ranking
   FROM girl_names
)

SELECT *
FROM ranked_names
WHERE Name = 'Jessica'
ORDER BY Year;
-- Was the most popular from 1985 to 1997, then popularity began to fade

WITH boy_names AS (
   SELECT Name, Year, SUM(Births) AS num_babies
   FROM names
   WHERE Gender = 'M'
   GROUP BY Name, Year
),
ranked_names AS (
   SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS popularity_ranking
   FROM boy_names
)

SELECT *
FROM ranked_names
WHERE Name = 'Michael'
ORDER BY Year;
-- Popularity of this name is still relevant from 1980 till now (but with slight decline in popularity over last couple of years)

-- 4) What was relative popularity of names in the database (by State and by Year)?
WITH 
babies_by_state AS (
	SELECT State, Name, SUM(Births) AS num_babies
	FROM names
	GROUP BY State, Name
),
babies_by_year AS (
	SELECT Year, Name, SUM(Births) AS num_babies
	FROM names
	GROUP BY Year, Name
)

SELECT 
	n.State, 
	n.Name,
	n.Births,
	bbs.num_babies,
	ROUND(CAST(n.Births AS FLOAT) / bbs.num_babies * 100, 2) as relative_popularity
FROM names n 
LEFT JOIN babies_by_state bbs
ON n.State = bbs.State
ORDER BY relative_popularity DESC;

SELECT 
	n.Year,
	n.Name,
	n.Births,
	bby.num_babies,
	ROUND(CAST(n.Births AS FLOAT) / bby.num_babies * 100, 2) as relative_popularity
FROM names n 
LEFT JOIN babies_by_year bby
ON n.Year = bby.Year
ORDER BY n.Year, n.Name, relative_popularity;

-- 5) What were the names with the biggest jumps in popularity from the first year of the dataset (1980) to the last year (2009)?

WITH all_names AS (
   SELECT Year, Name, SUM(Births) AS num_babies
   FROM names
   GROUP BY Year, Name
),
names_1980 AS (
   SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS popularity
   FROM all_names
   WHERE Year = 1980
),
names_2009 AS (
   SELECT Year, Name, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY num_babies DESC) AS popularity
   FROM all_names
   WHERE Year = 2009
)

SELECT 
   t1.Year AS Year_1980,
   t1.Name,
   t1.popularity AS Popularity_1980,
   t2.Year AS Year_2009,
   t2.popularity AS Popularity_2009,
   t2.popularity - t1.popularity AS popularity_shift
FROM names_1980 t1
INNER JOIN names_2009 t2 ON t1.Name = t2.Name
ORDER BY popularity_shift;
-- Colton, Skylar, Aidan, Kyler, Lilah, Rowan (biggest decrease in popularity since 1980)
-- Cherie, Kerri, Charissa, Cary, Tonia, Quiana (biggest increase in popularity since 1980)

-- ============================
-- OBJECTIVE 2: Compare popularity across decades
-- ============================

-- 1) What were 3 most popular girl names and 3 most popular boy names for each year?

WITH 
all_names_by_year AS (
	SELECT Year, Gender, Name, SUM(Births) AS num_babies
	FROM names
	GROUP BY Year, Gender, Name
),
all_names_ranked AS (
	SELECT Year, Gender, Name, num_babies, 
	DENSE_RANK() OVER(PARTITION BY Year, Gender ORDER BY num_babies DESC) as popularity_ranking
	FROM all_names_by_year
)

SELECT Year, Gender, Name, popularity_ranking
FROM all_names_ranked
WHERE popularity_ranking <= 3
ORDER BY Year, Gender, popularity_ranking ASC;

-- 2) What were 3 most popular girl names and 3 most popular boy names for each decade?

WITH 
all_names_by_decade AS (
	SELECT 
		(CASE 
			WHEN Year BETWEEN 1980 AND 1989 THEN '80s'
			WHEN Year BETWEEN 1990 AND 1999 THEN '90s'
			WHEN Year BETWEEN 2000 AND 2009 THEN '00s'
			ELSE 'None'
		END) AS decade,
	Gender, Name, SUM(Births) AS num_babies
	FROM names
	GROUP BY Year, Gender, Name
),
all_names_ranked AS (
	SELECT decade, Gender, Name, num_babies, 
	DENSE_RANK() OVER(PARTITION BY decade, Gender ORDER BY num_babies DESC) as popularity_ranking
	FROM all_names_by_decade
)

SELECT decade, Gender, Name, popularity_ranking
FROM all_names_ranked
WHERE popularity_ranking <= 3
ORDER BY decade, Gender, popularity_ranking ASC;

-- ============================
-- OBJECTIVE 3: Compare popularity across regions
-- ============================

-- 1) What was the number of babies born in each of the six regions (The state of MI should be in the Midwest region, so small adjustment was needed after States checkup)?

SELECT * FROM regions;

SELECT DISTINCT Region FROM regions;

WITH clean_regions AS (
	SELECT State, 
			CASE 
				WHEN Region = 'New England' THEN 'New_England' ELSE Region
			END AS clean_region_name
	FROM regions
	UNION
	SELECT 'MI' AS State, 'Midwest' AS Region
)
	
SELECT cr.clean_region_name, SUM(n.Births) AS num_babies
FROM names n LEFT JOIN clean_regions cr
ON n.State = cr.State
GROUP BY cr.clean_region_name
ORDER BY num_babies DESC;

-- 2) What were the 3 most popular girl names and 3 most popular boy names within each region?

WITH 
clean_regions AS (
	SELECT State, 
			CASE 
				WHEN Region = 'New England' THEN 'New_England' ELSE Region
			END AS clean_region_name
	FROM regions
	UNION
	SELECT 'MI' AS State, 'Midwest' AS Region
),
all_names_with_regions AS (
	SELECT clean_region_name, Name, Gender, SUM(Births) AS num_babies
	FROM names n LEFT JOIN clean_regions cr
		ON n.State = cr.State
	GROUP BY clean_region_name, Name, Gender
),
all_names_with_regions_ranked AS (
	SELECT *, 
		DENSE_RANK() OVER(PARTITION BY clean_region_name, Gender ORDER BY num_babies DESC) AS popularity_ranking
	FROM all_names_with_regions
)

SELECT *
FROM all_names_with_regions_ranked
WHERE popularity_ranking <= 3
ORDER BY clean_region_name, num_babies DESC;

-- ============================
-- OBJECTIVE 4: Explore unique names in the dataset
-- ============================

-- 1) What were 10 most popular androgynous names in the dataset?

WITH 
genders_count AS (
	SELECT Name, COUNT(DISTINCT Gender) AS genders, SUM(Births) AS num_babies
	FROM names
	GROUP BY Name
)

SELECT TOP 10 Name, num_babies 
FROM genders_count
WHERE genders = 2
ORDER BY num_babies DESC;

-- 2) What was the length of the shortest and longest names, and the most popular short and long names?

SELECT DISTINCT Name, LEN(Name) AS name_length
FROM names
ORDER BY name_length ASC;
-- 2 letters long

SELECT DISTINCT Name, LEN(Name) AS name_length
FROM names
ORDER BY name_length DESC;
-- 15 letters long

WITH extreme_length_names AS (
	SELECT Name, LEN(Name) as name_length, SUM(Births) as num_babies
	FROM names
	WHERE LEN(Name) IN (2, 15)
	GROUP BY Name
)

SELECT Name, num_babies
FROM extreme_length_names
ORDER BY num_babies DESC;
-- Ty, Bo (the shortest)
-- Franciscojavier, Ryanchristopher (the longest)

-- 3) Find the state with the highest percent of my own name out of curiosity

WITH names_by_state AS (
	SELECT State, SUM(Births) as num_babies
	FROM names
	GROUP BY State
),
custom_name_states AS (
	SELECT State, Name, SUM(Births) as custom_name_babies
	FROM names
	WHERE Name = 'Ilona'
	GROUP BY State, Name
)

SELECT nbs.State, ROUND(CAST(cns.custom_name_babies AS FLOAT) / nbs.num_babies * 100, 5) as custom_name_percent
FROM names_by_state nbs 
INNER JOIN custom_name_states cns
ON nbs.State = cns.State
ORDER BY custom_name_percent ASC;

-- ============================
-- 4) OBJECTIVE: Names and popculture
-- ============================

-- 1) Check popularity of certain names (Neo, Forrest, Britney etc.)

SELECT Name, Year, SUM(Births) AS num_babies
FROM names
WHERE Name = 'Neo'
GROUP BY Year, Name
ORDER BY Year;

-- ============================
-- 5) OBJECTIVE: Create View to import to POWER BI
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
 