-- ==============================
-- NETFLIX PROJECT – PRODUCTION READY
-- ==============================

-- 0. Drop table if exists and create table
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(208),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(100),
    description VARCHAR(250)
);

-- 1. Check if all data are imported
SELECT COUNT(*) AS total_content FROM netflix;

-- 2. Different types of content
SELECT DISTINCT type AS content_type FROM netflix;

-- ==============================
-- 15 Business Questions
-- ==============================

-- 1. Count the number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;

-- 2. Most common rating for Movies and TV Shows
SELECT type, rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS count_rating,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS ranked_ratings
WHERE ranking = 1;

-- 3. List all movies released in 2020
SELECT *
FROM netflix
WHERE release_year = 2020
  AND type = 'Movie';

-- 4. Top 5 countries with the most content
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY country_name
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT title, duration, director
FROM netflix
WHERE type = 'Movie'
  AND SPLIT_PART(duration, ' ', 1)::INT = (
      SELECT MAX(SPLIT_PART(duration, ' ', 1)::INT)
      FROM netflix
      WHERE type = 'Movie'
  );

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE date_added IS NOT NULL
  AND TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;

-- 10. Average content per year for India – top 5 years
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%india%')::NUMERIC * 100,
        2
    ) AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%india%'
  AND date_added IS NOT NULL
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Movies actor 'Salman Khan' appeared in last 10 years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Top 10 actors who appeared in most movies produced in India
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;

-- 15. Categorize content as Bad or Good based on keywords
WITH categorized_content AS (
    SELECT *,
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad Content'
            ELSE 'Good Content'
        END AS category
    FROM netflix
)
SELECT category,
       COUNT(*) AS total_content
FROM categorized_content
GROUP BY category
ORDER BY total_content DESC;
