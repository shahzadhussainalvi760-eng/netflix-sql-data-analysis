CREATE DATABASE netflix_database;
USE netflix_database
SELECT TOP 10 * FROM netflix_data;
EXEC sp_help 'Netflix_Data';
--1. What is the total number of 'Movies' and 'TV Shows' on Netflix?
SELECT 
    type, 
    COUNT(*) AS total_count
FROM Netflix_Data
GROUP BY type;
--2. Which country has produced the most content (Movies + TV Shows) on Netflix? List the top 5 countries
SELECT TOP 5 
    TRIM(value) AS country_name, 
    COUNT(*) AS total_content
FROM Netflix_Data
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;
--3. Retrieve a list of all movies and TV shows released in the year 2020
SELECT TOP 5
    show_id, 
    type, 
    title, 
    director, 
    release_year
FROM Netflix_Data
WHERE release_year = 2020;

SELECT 
    type, 
    COUNT(*) AS total_count
FROM Netflix_Data
WHERE release_year = 2020
GROUP BY type;
--4. What are the titles of all movies directed by 'Kirsten Johnson'?
SELECT 
    title
FROM Netflix_Data
WHERE type = 'Movie' 
  AND director LIKE '%Kirsten Johnson%';

SELECT title
FROM Netflix_Data
WHERE type = 'Movie' AND director = 'Kirsten Johnson';

---5. Which content rating is the most common on Netflix? (Count of titles by rating).
SELECT rating ,
       COUNT(*) AS Total_title
FROM Netflix_Data
GROUP BY rating
ORDER BY Total_title DESC ;
--6. Find the list of all 'TV Shows' that have 5 or more seasons.
SELECT 
    title, 
    duration
FROM Netflix_Data
WHERE type = 'TV Show' 
  AND TRY_CAST(REPLACE(REPLACE(duration, ' Seasons', ''), ' Season', '') AS INT) >= 5
ORDER BY 2 DESC;
---6. Find the list of all 'TV Shows' that have 5 or more seasons.
SELECT 
    title, 
    duration
FROM Netflix_Data
WHERE type = 'TV Show' 
  AND TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) >= 5;
  --7. List all the movies produced in 'India' that belong to the 'Comedies' category.
  SELECT 
    title, 
    type, 
    country, 
    listed_in
FROM Netflix_Data
WHERE type = 'Movie' 
  AND country LIKE '%India%' 
  AND listed_in LIKE '%Comedies%';
  --8. How many new shows/movies were released each year? Sort the results in descending order of the release year

SELECT 
    release_year,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS Movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS TV_Shows,
    COUNT(*) AS Total_Combined
FROM Netflix_Data
GROUP BY release_year
ORDER BY release_year DESC;
  --9. Who are the top 5 directors with the highest number of directed movies (excluding 'Not Given')?
  SELECT TOP 5 
    TRIM(value) AS director_name, 
    COUNT(*) AS total_movies
FROM Netflix_Data
CROSS APPLY STRING_SPLIT(director, ',')
WHERE type = 'Movie' 
  AND TRIM(value) <> 'Not Given' 
  AND director IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_movies DESC;
  --9. Who are the top 5 directors with the highest number of directed movies (excluding 'Not Given')?
  --10. In which year did Netflix add the highest amount of content to its platform?
  SELECT TOP 1 
    YEAR(date_added) AS year_added, 
    COUNT(*) AS total_content
FROM Netflix_Data
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added)
ORDER BY total_content DESC;
  --11. Which are the 5 oldest movies released in India on Netflix?
  SELECT TOP 5 
    title, 
    release_year, 
    country, 
    type
FROM Netflix_Data
WHERE type = 'Movie' 
  AND country LIKE '%India%'
ORDER BY release_year ASC;
  --12. Find the titles of all movies listed as 'Documentaries' that were released after the year 2015.
SELECT 
    title, 
    release_year, 
    listed_in
FROM Netflix_Data
WHERE type = 'Movie' 
  AND listed_in LIKE '%Documentaries%' 
  AND release_year > 2015;

--13. Which movie has the longest duration in minutes on Netflix?
SELECT country, title, release_year
FROM (
    SELECT 
        country, 
        title, 
        release_year,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY release_year DESC) as rank
    FROM Netflix_Data
    WHERE type = 'Movie' AND country IS NOT NULL
) AS sub
WHERE rank = 1;
--14. What is the most recently released movie for each country?
SELECT country, title, release_year
FROM (
    SELECT 
        country, 
        title, 
        release_year,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY release_year DESC) as rank
    FROM Netflix_Data
    WHERE type = 'Movie' AND country IS NOT NULL
) AS sub
WHERE rank = 1;
--15. Identify the release years in which more than 50 movies from India were released.
SELECT 
    release_year, 
    COUNT(*) AS movie_count
FROM Netflix_Data
WHERE type = 'Movie' 
  AND country LIKE '%India%'
GROUP BY release_year
HAVING COUNT(*) > 50
ORDER BY movie_count DESC;