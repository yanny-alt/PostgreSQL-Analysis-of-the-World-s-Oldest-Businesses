CREATE TABLE business.categories(
                         category_code VARCHAR,
                      category VARCHAR);
					  
	CREATE TABLE business.countries(country_code VARCHAR,
								   country VARCHAR,
								   continent VARCHAR);
		
		CREATE TABLE business.businesses(business_name VARCHAR,
										year_founded INT,
										category_code VARCHAR,
										country_code VARCHAR);
 
 1. What are the unique business categories in the dataset?
 SELECT DISTINCT category
FROM business.categories;

2. How many businesses are there in each category?
SELECT category, COUNT(*) AS num_businesses
FROM business.businesses
GROUP BY category;
ORDER BY num_businesses DESC;

3. Which category has the highest number of businesses?
SELECT category
FROM business.businesses
GROUP BY category
ORDER BY COUNT(*) DESC
LIMIT 1;

4. How many unique countries are covered in the dataset?
SELECT COUNT(DISTINCT country_code) AS num_countries
FROM business.countries;

5. Which continent has the highest number of businesses?
SELECT continent, COUNT(*) AS num_businesses
FROM business.countries
ORDER BY num_businesses DESC
LIMIT 1;

6. What is the distribution of businesses across continents?
SELECT continent, COUNT(*) AS num_businesses
FROM business.countries
GROUP BY continent
ORDER BY num_businesses DESC;

7. What is the range of founding years for businesses in the dataset?
SELECT MIN(year_founded) AS min_founding_year, MAX(year_founded) AS max_founding_year
FROM business.businesses;

8. How many businesses were founded in each decade?
SELECT
  EXTRACT(DECADE FROM TO_DATE(year_founded::text, 'YYYY')) * 10 AS decade,
  COUNT(*) AS num_businesses
FROM business.businesses
GROUP BY decade
ORDER BY num_businesses DESC;

9. What is the average founding year of businesses?
SELECT AVG(year_founded) AS avg_founding_year
FROM business.businesses;

10. What are the 10 oldest businesses in the dataset, and what are their categories and countries?
SELECT b.business, b.year_founded, c.category, co.country
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
INNER JOIN business.countries AS co ON b.country_code = co.country_code
ORDER BY b.year_founded
LIMIT 10;

11. Which categories have the highest percentage of businesses that have 
survived for over 200 years?
SELECT c.category, 
       ROUND(AVG(EXTRACT(YEAR FROM CURRENT_DATE) - b.year_founded) > 200::numeric, 4) * 100 AS survival_percentage
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY survival_percentage DESC;

12. How has the average age of businesses in each category changed over the past 100 years?
SELECT c.category, 
       AVG(EXTRACT(YEAR FROM CURRENT_DATE) - b.year_founded) AS average_age
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
WHERE EXTRACT(YEAR FROM CURRENT_DATE) - b.year_founded <= 100
GROUP BY c.category
ORDER BY average_age DESC;

13. What are the most common business categories within each country?
SELECT co.country, 
       c.category,
       COUNT(*) AS category_count
FROM business.businesses AS b
INNER JOIN business.countries AS co ON b.country_code = co.country_code
INNER JOIN business.categories AS c ON b.category_code = c.category_code
GROUP BY co.country, c.category
ORDER BY co.country, category_count DESC;

14. Which countries have the most diverse representation of business categories?
SELECT co.country, 
       COUNT(DISTINCT c.category) AS unique_categories
FROM business.businesses AS b
INNER JOIN business.countries AS co ON b.country_code = co.country_code
INNER JOIN business.categories AS c ON b.category_code = c.category_code
GROUP BY co.country
ORDER BY unique_categories DESC;

15. Identify any countries where a single category dominates the oldest businesses.
WITH OldestBusinesses AS (
  SELECT co.country, c.category, b.year_founded
  FROM business.businesses AS b
  INNER JOIN business.countries AS co ON b.country_code = co.country_code
  INNER JOIN business.categories AS c ON b.category_code = c.category_code
  ORDER BY b.year_founded
  LIMIT 1
)
SELECT country, category, COUNT(*) AS dominance_count
FROM OldestBusinesses
GROUP BY country, category
ORDER BY dominance_count DESC;

16. Have any business categories consistently produced 
    long-lasting businesses across multiple countries?
WITH LongLastingCategories AS (
  SELECT c.category
  FROM business.businesses AS b
  INNER JOIN business.categories AS c ON b.category_code = c.category_code
  WHERE EXTRACT(YEAR FROM CURRENT_DATE) - b.year_founded > 100
  GROUP BY c.category
  HAVING COUNT(DISTINCT b.country_code) > 1
)
SELECT *
FROM LongLastingCategories;

17.  Which categories have the most significant variation 
in business longevity across different countries?
SELECT c.category,
       STDDEV(EXTRACT(YEAR FROM CURRENT_DATE) - year_founded) AS longevity_variation
FROM business.businesses AS b
INNER JOIN business.categories AS c
USING (category_code)
GROUP BY category
ORDER BY longevity_variation DESC;

18. Which countries have the most businesses represented in the dataset?
SELECT co.country, COUNT(*) AS num_businesses
FROM business.businesses
INNER JOIN business.countries AS co
USING(country_code)
GROUP BY country
ORDER BY num_businesses DESC;

19. What are the top 5 countries with the most diverse range of business categories?
SELECT co.country, COUNT(DISTINCT c.category) AS num_unique_categories
FROM business.businesses AS b
INNER JOIN business.countries  AS co
USING (country_code)
INNER JOIN business.categories AS c
USING (category_code)
GROUP BY country
ORDER BY num_unique_categories DESC
LIMIT 5;

20. Identify any categories that have seen a 
significant increase or decrease in representation over time.
SELECT c.category,
       EXTRACT(DECADE FROM TO_DATE(year_founded::text, 'YYYY')) * 10 AS decade,
       COUNT(*) AS num_businesses
FROM business.businesses
INNER JOIN business.categories AS c USING (category_code)
GROUP BY category, decade
ORDER BY category, num_businesses DESC;

21. Analyze the distribution of businesses within each category by continent.
SELECT c.category, co.continent, COUNT(*) AS num_businesses
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
INNER JOIN business.countries AS co ON b.country_code = co.country_code
GROUP BY c.category, co.continent
ORDER BY c.category, co.continent;

22. Explore the relationship between business age and category size.
SELECT c.category, ROUND(AVG(EXTRACT(YEAR FROM CURRENT_DATE) - b.year_founded),0) AS average_age,
       COUNT(*) AS num_businesses
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY average_age DESC;

23. Identify any trends in the founding dates of businesses within each country.
SELECT co.country, b.year_founded, COUNT(*) AS num_businesses
FROM business.businesses AS b
INNER JOIN business.countries AS co USING (country_code) 
GROUP BY co.country, b.year_founded
ORDER BY co.country, b.year_founded;

24.  Investigate the evolution of dominant business categories across different country groupings.
SELECT c.category, co.continent, EXTRACT(DECADE FROM TO_DATE(b.year_founded::text, 'YYYY')) 
* 10 AS decade,
       COUNT(*) AS num_businesses
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
INNER JOIN business.countries AS co ON b.country_code = co.country_code
GROUP BY c.category, co.continent, decade
ORDER BY co.continent, decade, num_businesses DESC;

25. Use window functions to calculate the "rolling age" of each business category
within each country.
SELECT c.category, b.country_code, b.year_founded,
       AVG(EXTRACT(YEAR FROM CURRENT_DATE) - b.year_founded) OVER (PARTITION BY c.category,
			b.country_code ORDER BY b.year_founded) AS rolling_age
FROM business.businesses AS b
INNER JOIN business.categories AS c ON b.category_code = c.category_code
ORDER BY c.category, b.country_code, b.year_founded;


