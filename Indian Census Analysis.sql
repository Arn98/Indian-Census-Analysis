create database census;
use census;

# 1. How many total rows do we have in our dataset?

select count(*) from data_1;
select count(*) from data_2;

# 2. Can I get all records for Maharashtra and West Bengal?

SELECT 
    *
FROM
    data_1
WHERE
    state IN ('Maharashtra' , 'West Bengal');

# 3. What is the total population of India?

SELECT 
    SUM(population) AS Population
FROM
    data_2;

# 4. What id the average growth rate of each state (in percentage)?

SELECT 
    state, AVG(growth) * 100 avg_growth
FROM
    data_1
GROUP BY state;

# 5. What’s the average sex ratio for each state?

SELECT 
    state, ROUND(AVG(sex_ratio), 0) avg_sex_ratio
FROM
    data_1
GROUP BY state
ORDER BY avg_sex_ratio DESC;

# 6. Which states have an average literacy rate greater than 90%?
 
SELECT 
    state, ROUND(AVG(literacy), 0) avg_literacy_ratio
FROM
    data_1
GROUP BY state
HAVING ROUND(AVG(literacy), 0) > 90
ORDER BY avg_literacy_ratio DESC;

# 7. What are the top three states with the highest growth rate?o


SELECT 
    state, AVG(growth) * 100 avg_growth
FROM
    data_1
GROUP BY state
ORDER BY avg_growth DESC
LIMIT 3;

# 8. Which three states have the lowest sex ratio?

SELECT 
    state, ROUND(AVG(sex_ratio), 0) avg_sex_ratio
FROM
    data_1
GROUP BY state
ORDER BY avg_sex_ratio ASC
LIMIT 3;

# 9. What are the top 3 and bottom 3 states based on literacy rate?

(SELECT state, literacy FROM data_1 ORDER BY literacy DESC LIMIT 3)
UNION ALL
(SELECT state, literacy FROM data_1 ORDER BY literacy ASC LIMIT 3);

# 10. Which states start with 'A' or 'B'?

select distinct state 
from data_1
where lower(state) like 'a%' or lower(state) like 'b%';

select distinct state 
from data_1
where lower(state) like 'a%' and lower(state) like '%m';


# 11. What are the total number of males and females in each state?

SELECT 
    d.state,
    SUM(d.males) total_males,
    SUM(d.females) total_females
FROM
    (SELECT 
        c.district,
            c.state state,
            ROUND(c.population / (c.sex_ratio + 1), 0) males,
            ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) females
    FROM
        (SELECT 
        a.district,
            a.state,
            a.sex_ratio / 1000 sex_ratio,
            b.population
    FROM
        data_1 a
    INNER JOIN data_2 b ON a.district = b.district) c) d
GROUP BY d.state;

# 12. What is the total literate and illiterate population in each state?

SELECT 
    c.state,
    SUM(literate_people) total_literate_pop,
    SUM(illiterate_people) total_lliterate_pop
FROM
    (SELECT 
        d.district,
            d.state,
            ROUND(d.literacy_ratio * d.population, 0) literate_people,
            ROUND((1 - d.literacy_ratio) * d.population, 0) illiterate_people
    FROM
        (SELECT 
        a.district,
            a.state,
            a.literacy / 100 literacy_ratio,
            b.population
    FROM
        data_1 a
    INNER JOIN data_2 b ON a.district = b.district) d) c
GROUP BY c.state;

# 13. What is the difference between the previous census population and the current one?


SELECT 
    SUM(m.previous_census_population) previous_census_population,
    SUM(m.current_census_population) current_census_population
FROM
    (SELECT 
        e.state,
            SUM(e.previous_census_population) previous_census_population,
            SUM(e.current_census_population) current_census_population
    FROM
        (SELECT 
        d.district,
            d.state,
            ROUND(d.population / (1 + d.growth), 0) previous_census_population,
            d.population current_census_population
    FROM
        (SELECT 
        a.district, a.state, a.growth growth, b.population
    FROM
        data_1 a
    INNER JOIN data_2 b ON a.district = b.district) d) e
    GROUP BY e.state) m;
  
  # 14. What is the difference in population density between the previous and current census?
  
SELECT 
    (g.total_area / g.previous_census_population) AS previous_census_population_vs_area,
    (g.total_area / g.current_census_population) AS current_census_population_vs_area
FROM (
    SELECT 
        q.*, 
        r.total_area 
    FROM (
        SELECT 
            1 AS keyy, 
            n.* 
        FROM (
            SELECT 
                SUM(m.previous_census_population) AS previous_census_population,
                SUM(m.current_census_population) AS current_census_population
            FROM (
                SELECT 
                    e.state,
                    SUM(e.previous_census_population) AS previous_census_population,
                    SUM(e.current_census_population) AS current_census_population
                FROM (
                    SELECT 
                        d.district,
                        d.state,
                        ROUND(d.population / (1 + d.growth), 0) AS previous_census_population,
                        d.population AS current_census_population
                    FROM (
                        SELECT 
                            a.district,
                            a.state,
                            a.growth,
                            b.population 
                        FROM data_1 a 
                        INNER JOIN data_2 b ON a.district = b.district
                    ) d
                ) e
                GROUP BY e.state
            ) m
        ) n
    ) q 
    INNER JOIN (
        SELECT 
            1 AS keyy, 
            z.* 
        FROM (
            SELECT 
                SUM(area_km2) AS total_area 
            FROM data_2
        ) z
    ) r ON q.keyy = r.keyy
) g;

    
#  15. What are  the top 3 districts with the highest literacy rate from each state?
SELECT a.* FROM  
(SELECT district, state, literacy, RANK() OVER (PARTITION BY state ORDER BY literacy DESC) AS rnk  
FROM data_1) a  
WHERE a.rnk IN (1,2,3)  
ORDER BY state;



