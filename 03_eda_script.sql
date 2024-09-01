-- 1. Find names that have been given to over 5,000 babies of either sex every year for the 101 years from 1920 through 2020.

SELECT first_name, SUM(num) AS total_num
FROM baby_names
WHERE num > 5000
GROUP BY first_name
HAVING COUNT(DISTINCT year) = 101
ORDER BY total_num DESC
;

-- 2. Classify each name's popularity according to the number of years that the name appears in the dataset.

SELECT 
    first_name,
    SUM(num),
    CASE
	WHEN COUNT(DISTINCT year) > 80 THEN 'Classic'
	WHEN COUNT(DISTINCT year) > 50 THEN 'Semi-classic'
	WHEN COUNT(DISTINCT year) > 20 THEN 'Semi-trendy'
	ELSE 'Trendy'
    END AS popularity_type
FROM baby_names
GROUP BY first_name
ORDER BY first_name ASC
;

-- 3. Find the ten highest-ranked American female names in the dataset.

SELECT
    RANK() OVER(ORDER BY SUM(num) DESC) AS name_rank,
    first_name,
    SUM(num)
FROM baby_names
WHERE sex = 'F'
GROUP BY first_name
ORDER BY name_rank ASC
LIMIT 10
;

-- 4. A friend would like help choosing a name for her baby, a girl. She doesn't like any of the top-ranked names we found in the previous task. She's set on a traditionally female name ending in the letter 'a' since she's heard that vowels in baby names are trendy. She's also looking for a name that has been popular in the years since 2015.

SELECT first_name
FROM baby_names
WHERE sex = 'F'
    AND year > 2015
    AND first_name LIKE '%a'
GROUP BY first_name
ORDER BY SUM(num) DESC
;

-- 5. Find the cumulative number of babies named Olivia over the years since the name first appeared in our dataset.

SELECT b1.year, b1.first_name, b1.num, SUM(b2.num) AS cumulative_olivias
FROM baby_names b1
JOIN baby_names b2
    ON b1.year >= b2.year
    AND b1.first_name = 'Olivia'
    AND b2.first_name = 'Olivia'
GROUP BY b1.first_name, b1.year, b1.num
ORDER BY b1.year ASC
;

-- Same query as above using window function

SELECT 
    year, 
    first_name, 
    num, 
    SUM(num) OVER (PARTITION BY first_name ORDER BY year) AS cumulative_olivias
FROM baby_names
WHERE first_name = 'Olivia'
ORDER BY year ASC
;

-- 6. Write a query that selects the year and the maximum num of babies given any male name in that year.

SELECT year, MAX(num) AS max_num
FROM baby_names
WHERE sex = 'M'
GROUP BY year
ORDER BY year ASC
;

-- 7. Using the previous task's code as a subquery, look up the first_name that corresponds to the maximum number of babies given a specific male name in a year.

SELECT b1.year, b1.first_name, b1.num
FROM baby_names b1
JOIN (
    SELECT year, MAX(num) AS max_num
    FROM baby_names
    WHERE sex = 'M'
    GROUP BY year
) AS b2
    ON b1.year = b2.year
    AND b1.num = b2.max_num
ORDER BY year DESC
;

-- 8. Return a list of first names that have been the top male first name in any year along with a count of the number of years that name has been the top name.

WITH cte AS (
    SELECT b1.year, b1.first_name, b1.num
    FROM baby_names b1
    JOIN (
        SELECT year, MAX(num) AS max_num
        FROM baby_names
        WHERE sex = 'M'
        GROUP BY year
    ) AS b2
        ON b1.year = b2.year
        AND b1.num = b2.max_num
    ORDER BY year DESC
)

SELECT first_name, COUNT(year) AS count_top_name
FROM cte
GROUP BY first_name
ORDER BY count_top_name DESC
;

