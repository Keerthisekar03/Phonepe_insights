#Insurance Penetration and Growth Potential Analysis

#1. Identify the Top States for Insurance Adoption

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
GROUP BY State
ORDER BY total_premium_collected DESC;

#2. Identify High-Growth and Low-Growth States

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

#--Finds states with the highest and lowest growth in insurance transactions.

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) > 800 THEN 'High Growth'
        WHEN ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) BETWEEN 100 AND 800 THEN 'Moderate Growth'
        WHEN ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) BETWEEN 0 AND 100 THEN 'Low Growth'
        ELSE 'Decline'
    END AS growth_analysis
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


#3. District-Wise Insurance Analysis

SELECT 
    State, 
    District, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM map_insurance
GROUP BY State, District
ORDER BY total_premium_collected DESC;

#4. Compare Yearly Growth in Insurance Adoption

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#--Compare 2020 premium collections with 2019 - 2019 data not available to compare. so results are null

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
WHERE a.Year = 2020  -- Filter results for Year = 2020
ORDER BY growth_rate DESC;


#Identify Underpenetrated States for Expansion

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) AS market_share
FROM top_insurance
GROUP BY State
ORDER BY market_share ASC;

#--Categorizing States into Strong vs. Weak Insurance Adoption

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) AS market_share,
    CASE 
        WHEN (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) > 5 THEN 'Strong Adoption'
        ELSE 'Weak Adoption'
    END AS insurance_adoption
FROM top_insurance
GROUP BY State
ORDER BY market_share ASC;

