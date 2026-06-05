-- ================================================================================
--                                                                                
--                    NETFLIX DATA ANALYSIS - COMPLETE SCRIPT                    
--                         ALL 15 QUESTIONS COVERED                              
--                                                                                
--   Author        : Senior Data Analyst                                         
--   Database      : netflix_database                                            
--   Table         : Netflix_Data                                                 
--   Created Date  : 2024                                                        
--   Description   : End-to-End Netflix Content Analysis covering                
--                   content distribution, trends, directors,                    
--                   countries, ratings, duration and more.                      
--                                                                                
-- ================================================================================


-- ================================================================================
--  SECTION 0 : DATABASE SETUP & INITIALIZATION
-- ================================================================================

-- Step 1 : Create the Database
CREATE DATABASE netflix_database;
GO

-- Step 2 : Switch to the Database
USE netflix_database;
GO

-- Step 3 : Preview Raw Data (Top 10 Rows)
PRINT '========================================';
PRINT ' RAW DATA PREVIEW - TOP 10 ROWS         ';
PRINT '========================================';

SELECT TOP 10 
    *
FROM 
    Netflix_Data;
GO

-- Step 4 : Inspect Table Schema & Metadata
PRINT '========================================';
PRINT ' TABLE SCHEMA & METADATA                ';
PRINT '========================================';

EXEC sp_help 'Netflix_Data';
GO


-- ================================================================================
--  SECTION 1 : CONTENT DISTRIBUTION ANALYSIS
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  Q1 | TOTAL COUNT OF MOVIES vs TV SHOWS ON NETFLIX                            ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : What is the total number of Movies and TV Shows on Netflix?
    OBJECTIVE : Understand the overall content split between Movies and TV Shows
    METHOD    : Simple GROUP BY with COUNT and percentage calculation
    OUTPUT    : Content_Type | Total_Count | Percentage_Share
-------------------------------------------------------------------------------------
*/

SELECT 
    type                                AS Content_Type,
    COUNT(*)                            AS Total_Count,
    CONCAT(
        CAST(
            ROUND(
                COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()
            , 2) AS DECIMAL(5,2)
        ),' %'
    )                                   AS Percentage_Share
FROM 
    Netflix_Data
GROUP BY 
    type
ORDER BY 
    Total_Count DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q2 | TOP 5 COUNTRIES PRODUCING THE MOST CONTENT ON NETFLIX                   ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Which country has produced the most content (Movies + TV Shows)?
                List the top 5 countries.
    OBJECTIVE : Identify the top 5 content-producing countries on Netflix
    METHOD    : STRING_SPLIT handles multi-country comma-separated entries
                CROSS APPLY expands each country into individual rows
    OUTPUT    : Rank_Position | Country_Name | Total_Content
-------------------------------------------------------------------------------------
*/

SELECT TOP 5
    ROW_NUMBER() OVER (
        ORDER BY COUNT(*) DESC
    )                                   AS Rank_Position,
    TRIM(country_split.value)           AS Country_Name,
    COUNT(*)                            AS Total_Content
FROM 
    Netflix_Data
    CROSS APPLY STRING_SPLIT(country, ',') AS country_split
WHERE 
    country IS NOT NULL
    AND TRIM(country_split.value) <> ''
GROUP BY 
    TRIM(country_split.value)
ORDER BY 
    Total_Content DESC;

GO


-- ================================================================================
--  SECTION 2 : CONTENT BY RELEASE YEAR ANALYSIS
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  Q3 | ALL MOVIES AND TV SHOWS RELEASED IN THE YEAR 2020                       ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Retrieve a list of all Movies and TV Shows released in the year 2020
    OBJECTIVE : Filter all Netflix content specifically released in 2020
    METHOD    : Simple WHERE filter on release_year column
    OUTPUT    : Part A - Sample Records (Top 5)
                Part B - Summary Count by Content Type
-------------------------------------------------------------------------------------
*/

-- Part A : Sample Records Preview (Top 5 Rows)
PRINT '-- Part A : Sample Records Released in 2020 (Top 5 Preview) --';

SELECT TOP 5
    show_id                             AS Show_ID,
    type                                AS Content_Type,
    title                               AS Title,
    director                            AS Director,
    release_year                        AS Release_Year
FROM 
    Netflix_Data
WHERE 
    release_year = 2020
ORDER BY 
    title ASC;

GO

-- Part B : Summary Count by Content Type for Year 2020
PRINT '-- Part B : Total Content Count by Type Released in 2020 --';

SELECT 
    type                                AS Content_Type,
    COUNT(*)                            AS Total_Count
FROM 
    Netflix_Data
WHERE 
    release_year = 2020
GROUP BY 
    type
ORDER BY 
    Total_Count DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q8 | TOTAL CONTENT RELEASED EACH YEAR (SORTED BY YEAR DESCENDING)            ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : How many new shows/movies were released each year?
                Sort the results in descending order of the release year.
    OBJECTIVE : Analyze the annual volume of content added to Netflix
    METHOD    : CASE WHEN to split Movies and TV Shows into separate columns
                GROUP BY release_year for yearly aggregation
    OUTPUT    : Release_Year | Total_Movies | Total_TV_Shows | Grand_Total
-------------------------------------------------------------------------------------
*/

SELECT 
    release_year                        AS Release_Year,
    SUM(CASE 
            WHEN type = 'Movie'   
            THEN 1 ELSE 0 
        END)                            AS Total_Movies,
    SUM(CASE 
            WHEN type = 'TV Show' 
            THEN 1 ELSE 0 
        END)                            AS Total_TV_Shows,
    COUNT(*)                            AS Grand_Total
FROM 
    Netflix_Data
WHERE
    release_year IS NOT NULL
GROUP BY 
    release_year
ORDER BY 
    release_year DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q10 | YEAR NETFLIX ADDED THE HIGHEST AMOUNT OF CONTENT TO ITS PLATFORM       ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : In which year did Netflix add the highest amount of content?
    OBJECTIVE : Find the single peak year when Netflix added most content
    METHOD    : YEAR() extracts year from date_added column
                TOP 1 with ORDER BY DESC returns the peak year
    OUTPUT    : Year_Added | Total_Content_Added
-------------------------------------------------------------------------------------
*/

SELECT TOP 1
    YEAR(date_added)                    AS Year_Added,
    COUNT(*)                            AS Total_Content_Added
FROM 
    Netflix_Data
WHERE 
    date_added IS NOT NULL
GROUP BY 
    YEAR(date_added)
ORDER BY 
    Total_Content_Added DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q15 | RELEASE YEARS WHERE MORE THAN 50 INDIAN MOVIES WERE RELEASED           ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Identify the release years in which more than 50 movies 
                from India were released.
    OBJECTIVE : Find high-volume years for Indian movie productions on Netflix
    METHOD    : LIKE '%India%' catches India in multi-country entries
                HAVING COUNT(*) > 50 filters only high-volume years
    OUTPUT    : Release_Year | Indian_Movie_Count
-------------------------------------------------------------------------------------
*/

SELECT 
    release_year                        AS Release_Year,
    COUNT(*)                            AS Indian_Movie_Count
FROM 
    Netflix_Data
WHERE 
    type        = 'Movie'
    AND country  LIKE '%India%'
GROUP BY 
    release_year
HAVING 
    COUNT(*) > 50
ORDER BY 
    Indian_Movie_Count DESC;

GO


-- ================================================================================
--  SECTION 3 : DIRECTORS & CAST ANALYSIS
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  Q4 | ALL MOVIES DIRECTED BY KIRSTEN JOHNSON                                  ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : What are the titles of all movies directed by Kirsten Johnson?
    OBJECTIVE : Retrieve all Netflix movies specifically directed by Kirsten Johnson
    METHOD    : LIKE '%Kirsten Johnson%' handles multi-director entries
                Exact match also included as alternative
    OUTPUT    : Movie_Title
-------------------------------------------------------------------------------------
*/

-- Method 1 : Using LIKE (Handles multi-director entries)
PRINT '-- Method 1 : LIKE Pattern Match (Recommended for multi-director entries) --';

SELECT 
    title                               AS Movie_Title,
    director                            AS Director,
    release_year                        AS Release_Year,
    country                             AS Country
FROM 
    Netflix_Data
WHERE 
    type        = 'Movie'
    AND director LIKE '%Kirsten Johnson%'
ORDER BY 
    release_year DESC;

GO

-- Method 2 : Using Exact Match
PRINT '-- Method 2 : Exact Director Name Match --';

SELECT 
    title                               AS Movie_Title,
    director                            AS Director,
    release_year                        AS Release_Year,
    country                             AS Country
FROM 
    Netflix_Data
WHERE 
    type        = 'Movie'
    AND director = 'Kirsten Johnson'
ORDER BY 
    release_year DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q9 | TOP 5 DIRECTORS WITH HIGHEST NUMBER OF MOVIES DIRECTED ON NETFLIX       ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Who are the top 5 directors with the highest number of 
                directed movies (excluding Not Given)?
    OBJECTIVE : Rank directors by total movies they have directed on Netflix
    METHOD    : STRING_SPLIT handles multi-director comma-separated columns
                CROSS APPLY expands each director into individual rows
                Excludes blank and Not Given entries
    OUTPUT    : Rank_Position | Director_Name | Total_Movies_Directed
-------------------------------------------------------------------------------------
*/

SELECT TOP 5
    ROW_NUMBER() OVER (
        ORDER BY COUNT(*) DESC
    )                                   AS Rank_Position,
    TRIM(director_split.value)          AS Director_Name,
    COUNT(*)                            AS Total_Movies_Directed
FROM 
    Netflix_Data
    CROSS APPLY STRING_SPLIT(director, ',') AS director_split
WHERE 
    type                                = 'Movie'
    AND director                        IS NOT NULL
    AND TRIM(director_split.value)      <> 'Not Given'
    AND TRIM(director_split.value)      <> ''
GROUP BY 
    TRIM(director_split.value)
ORDER BY 
    Total_Movies_Directed DESC;

GO


-- ================================================================================
--  SECTION 4 : RATINGS & DURATION ANALYSIS
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  Q5 | MOST COMMON CONTENT RATINGS ON NETFLIX                                  ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Which content rating is the most common on Netflix?
                Count of titles by rating.
    OBJECTIVE : Rank all Netflix content ratings by frequency of appearance
    METHOD    : GROUP BY rating with COUNT
                Window Function for percentage share calculation
    OUTPUT    : Content_Rating | Total_Titles | Percentage_Share
-------------------------------------------------------------------------------------
*/

SELECT 
    rating                              AS Content_Rating,
    COUNT(*)                            AS Total_Titles,
    CONCAT(
        CAST(
            ROUND(
                COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()
            , 2) AS DECIMAL(5,2)
        ),' %'
    )                                   AS Percentage_Share
FROM 
    Netflix_Data
WHERE 
    rating IS NOT NULL
GROUP BY 
    rating
ORDER BY 
    Total_Titles DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q6 | ALL TV SHOWS WITH 5 OR MORE SEASONS                                     ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Find the list of all TV Shows that have 5 or more seasons.
    OBJECTIVE : Identify long-running TV Shows available on Netflix
    METHOD    : TRY_CAST safely converts extracted text to integer
                LEFT + CHARINDEX extracts numeric part before space
                REPLACE strips Season/Seasons text as alternative method
    OUTPUT    : Show_Title | Duration | Season_Count
-------------------------------------------------------------------------------------
*/

-- Method 1 : Using LEFT + CHARINDEX (Recommended)
PRINT '-- Method 1 : LEFT + CHARINDEX Extraction --';

SELECT 
    title                               AS Show_Title,
    duration                            AS Duration,
    TRY_CAST(
        LEFT(duration, CHARINDEX(' ', duration) - 1) 
    AS INT)                             AS Season_Count
FROM 
    Netflix_Data
WHERE 
    type = 'TV Show'
    AND TRY_CAST(
            LEFT(duration, CHARINDEX(' ', duration) - 1) 
        AS INT) >= 5
ORDER BY 
    Season_Count DESC;

GO

-- Method 2 : Using REPLACE to Strip Text
PRINT '-- Method 2 : REPLACE Text Stripping --';

SELECT 
    title                               AS Show_Title,
    duration                            AS Duration,
    TRY_CAST(
        REPLACE(
            REPLACE(duration, ' Seasons', ''), 
            ' Season', ''
        ) 
    AS INT)                             AS Season_Count
FROM 
    Netflix_Data
WHERE 
    type = 'TV Show'
    AND TRY_CAST(
            REPLACE(
                REPLACE(duration, ' Seasons', ''), 
                ' Season', ''
            ) 
        AS INT) >= 5
ORDER BY 
    Season_Count DESC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q13 | MOVIE WITH THE LONGEST DURATION IN MINUTES ON NETFLIX                  ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Which movie has the longest duration in minutes on Netflix?
    OBJECTIVE : Find the single longest running movie by runtime in minutes
    METHOD    : REPLACE strips min text from duration column
                TRY_CAST safely converts string to integer for comparison
                TOP 1 with ORDER BY DESC returns the longest movie
    OUTPUT    : Movie_Title | Duration | Duration_In_Minutes
-------------------------------------------------------------------------------------
*/

SELECT TOP 1
    title                               AS Movie_Title,
    duration                            AS Duration,
    TRY_CAST(
        REPLACE(duration, ' min', '') 
    AS INT)                             AS Duration_In_Minutes
FROM 
    Netflix_Data
WHERE 
    type        = 'Movie'
    AND duration LIKE '%min%'
ORDER BY 
    Duration_In_Minutes DESC;

GO


-- ================================================================================
--  SECTION 5 : COUNTRY & GENRE ANALYSIS
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  Q7 | ALL INDIAN COMEDY MOVIES AVAILABLE ON NETFLIX                           ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : List all the movies produced in India that belong to 
                the Comedies category.
    OBJECTIVE : Find Indian Comedy Movies available on Netflix
    FILTERS   : Type = Movie | Country includes India | Genre includes Comedies
    METHOD    : Multiple LIKE conditions for flexible multi-value column matching
    OUTPUT    : Movie_Title | Content_Type | Country | Genre | Release_Year
-------------------------------------------------------------------------------------
*/

SELECT 
    title                               AS Movie_Title,
    type                                AS Content_Type,
    country                             AS Country,
    listed_in                           AS Genre,
    release_year                        AS Release_Year
FROM 
    Netflix_Data
WHERE 
    type        = 'Movie'
    AND country  LIKE '%India%'
    AND listed_in LIKE '%Comedies%'
ORDER BY 
    release_year DESC,
    title ASC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q11 | TOP 5 OLDEST INDIAN MOVIES AVAILABLE ON NETFLIX                        ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Which are the 5 oldest movies released in India on Netflix?
    OBJECTIVE : Find the earliest-released Indian Movies currently on Netflix
    METHOD    : Filter by Movie type and India country
                ORDER BY release_year ASC to get oldest first
                TOP 5 limits to 5 results
    OUTPUT    : Movie_Title | Release_Year | Country | Content_Type
-------------------------------------------------------------------------------------
*/

SELECT TOP 5
    title                               AS Movie_Title,
    release_year                        AS Release_Year,
    country                             AS Country,
    type                                AS Content_Type
FROM 
    Netflix_Data
WHERE 
    type    = 'Movie'
    AND country LIKE '%India%'
ORDER BY 
    release_year ASC;

GO

-- --------------------------------------------------------------------------------

PRINT '';
PRINT '================================================================================';
PRINT '  Q12 | DOCUMENTARY MOVIES RELEASED AFTER 2015 ON NETFLIX                      ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : Find the titles of all movies listed as Documentaries 
                that were released after the year 2015.
    OBJECTIVE : Retrieve recent Documentary Movies available on Netflix
    METHOD    : LIKE '%Documentaries%' matches genre in multi-genre listed_in column
                release_year > 2015 filters only post 2015 content
    OUTPUT    : Movie_Title | Release_Year | Genre
-------------------------------------------------------------------------------------
*/

SELECT 
    title                               AS Movie_Title,
    release_year                        AS Release_Year,
    listed_in                           AS Genre
FROM 
    Netflix_Data
WHERE 
    type            = 'Movie'
    AND listed_in   LIKE '%Documentaries%'
    AND release_year > 2015
ORDER BY 
    release_year DESC,
    title ASC;

GO


-- ================================================================================
--  SECTION 6 : ADVANCED WINDOW FUNCTION ANALYSIS
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  Q14 | MOST RECENTLY RELEASED MOVIE FOR EACH COUNTRY ON NETFLIX               ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    QUESTION  : What is the most recently released movie for each country?
    OBJECTIVE : Find the latest movie title and release year per country
    METHOD    : ROW_NUMBER() Window Function partitioned by country
                Ordered by release_year DESC to rank latest movie first
                Outer query filters only Rank = 1 (most recent per country)
    OUTPUT    : Country | Latest_Movie_Title | Release_Year
-------------------------------------------------------------------------------------
*/

SELECT 
    country                             AS Country,
    title                               AS Latest_Movie_Title,
    release_year                        AS Release_Year
FROM (
    SELECT 
        country,
        title,
        release_year,
        ROW_NUMBER() OVER (
            PARTITION BY country 
            ORDER BY release_year DESC
        )                               AS Row_Rank
    FROM 
        Netflix_Data
    WHERE 
        type        = 'Movie'
        AND country IS NOT NULL
        AND TRIM(country) <> ''
) AS Ranked_Movies
WHERE 
    Row_Rank = 1
ORDER BY 
    Release_Year DESC,
    Country ASC;

GO


-- ================================================================================
--  SECTION 7 : EXECUTIVE SUMMARY DASHBOARD - ALL KEY KPIs AT A GLANCE
-- ================================================================================

PRINT '';
PRINT '================================================================================';
PRINT '  EXECUTIVE SUMMARY | NETFLIX KEY PERFORMANCE INDICATORS (KPIs)                ';
PRINT '================================================================================';

/*
-------------------------------------------------------------------------------------
    OBJECTIVE : Single result set showing all key Netflix platform metrics
    METHOD    : UNION ALL combines multiple aggregations into one clean output
    OUTPUT    : KPI_Category | KPI_Metric | KPI_Value
-------------------------------------------------------------------------------------
*/

-- Total Content Overview
SELECT 
    'Content Overview'                  AS KPI_Category,
    'Total Titles on Netflix'           AS KPI_Metric,
    CAST(COUNT(*) AS VARCHAR(50))       AS KPI_Value
FROM Netflix_Data

UNION ALL

SELECT 
    'Content Overview',
    'Total Movies',
    CAST(COUNT(*) AS VARCHAR(50))
FROM Netflix_Data 
WHERE type = 'Movie'

UNION ALL

SELECT 
    'Content Overview',
    'Total TV Shows',
    CAST(COUNT(*) AS VARCHAR(50))
FROM Netflix_Data 
WHERE type = 'TV Show'

UNION ALL

-- Country Metrics
SELECT 
    'Country Metrics',
    'Total Unique Countries',
    CAST(COUNT(DISTINCT TRIM(cs.value)) AS VARCHAR(50))
FROM Netflix_Data
CROSS APPLY STRING_SPLIT(country, ',') AS cs
WHERE country IS NOT NULL
  AND TRIM(cs.value) <> ''

UNION ALL

-- Director Metrics
SELECT 
    'Director Metrics',
    'Total Unique Directors',
    CAST(COUNT(DISTINCT TRIM(ds.value)) AS VARCHAR(50))
FROM Netflix_Data
CROSS APPLY STRING_SPLIT(director, ',') AS ds
WHERE director IS NOT NULL
  AND TRIM(ds.value) <> 'Not Given'
  AND TRIM(ds.value) <> ''

UNION ALL

-- Year Metrics
SELECT 
    'Year Metrics',
    'Earliest Release Year',
    CAST(MIN(release_year) AS VARCHAR(50))
FROM Netflix_Data
WHERE release_year IS NOT NULL

UNION ALL

SELECT 
    'Year Metrics',
    'Latest Release Year',
    CAST(MAX(release_year) AS VARCHAR(50))
FROM Netflix_Data
WHERE release_year IS NOT NULL

UNION ALL

-- Rating Metrics
SELECT 
    'Rating Metrics',
    'Most Common Content Rating',
    rating
FROM (
    SELECT TOP 1 
        rating,
        COUNT(*) AS cnt
    FROM Netflix_Data
    WHERE rating IS NOT NULL
    GROUP BY rating
    ORDER BY cnt DESC
) AS top_rating

UNION ALL

-- Duration Metrics
SELECT 
    'Duration Metrics',
    'Longest Movie Duration (Minutes)',
    CAST(
        MAX(TRY_CAST(REPLACE(duration, ' min', '') AS INT))
    AS VARCHAR(50))
FROM Netflix_Data
WHERE type     = 'Movie'
  AND duration LIKE '%min%'

UNION ALL

-- Season Metrics
SELECT 
    'Season Metrics',
    'Maximum Seasons in a TV Show',
    CAST(
        MAX(TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT))
    AS VARCHAR(50))
FROM Netflix_Data
WHERE type = 'TV Show'
  AND duration LIKE '% Season%'

ORDER BY 
    KPI_Category ASC,
    KPI_Metric ASC;

GO


-- ================================================================================
--                     END OF COMPLETE NETFLIX ANALYSIS SCRIPT                   
--                  All 15 Questions + Executive Summary Covered                 
-- ================================================================================