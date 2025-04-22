# Insurance Transactions Analysis
#1. Identify the Top-Performing States for Insurance Transactions

SELECT 
    State, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
WHERE Year between 2020 and 2024   -- Includes data from 2020 to 2024
GROUP BY State, Year, Quater
ORDER BY total_premium_collected DESC;

#2. Identify High-Performing Districts

SELECT 
    State, 
    District, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM map_insurance
WHERE Year between 2020 and 2024 
GROUP BY State, District, Year, Quater
ORDER BY total_premium_collected DESC;

#3.  top 10 districts where insurance transactions are highest.

SELECT 
    State, 
    District, 
    Year, 
    Quarter, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM top_insurance
WHERE Year between 2020 and 2024 
GROUP BY State, District, Year, Quarter
ORDER BY total_premium_collected DESC
LIMIT 10;

#track year-over-year growth by state

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
ORDER BY growth_rate DESC;

#5. Identify Underpenetrated States for Expansion

SELECT 
    State, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM aggregated_insurance WHERE Year = 2023 AND Quater = 2) * 100) AS market_share
FROM aggregated_insurance
WHERE Year between 2020 and 2024 
GROUP BY State, Year, Quater
ORDER BY market_share ASC
LIMIT 100;
