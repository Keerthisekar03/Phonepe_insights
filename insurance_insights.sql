#1. Identify the Most Popular Insurance Products

SELECT 
    type, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
GROUP BY type
ORDER BY total_policies_sold DESC;

#2.Analyze Insurance Growth Trends Over Time

SELECT 
    a.type, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT type, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY type, Year) a
LEFT JOIN 
    (SELECT type, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY type, Year) b
ON a.type = b.type AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#3. Identify States with the Highest Insurance Adoption

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM aggregated_insurance
GROUP BY State
ORDER BY total_premium_collected DESC;

#4. District-Level Insurance Analysis

SELECT 
    State, 
    District, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM map_insurance
GROUP BY State, District
ORDER BY total_premium_collected DESC;

#5. Identify High-Value Insurance Buyers

SELECT 
    State, 
    SUM(Insurance_amount) AS total_premium_collected,
    SUM(Insurance_count) AS total_policies_sold,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
GROUP BY State
ORDER BY avg_policy_value DESC
LIMIT 10;

#6. Identify Top Growth Markets for High-Value Insurance

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC
LIMIT 10;

