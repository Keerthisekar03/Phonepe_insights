#User Engagement and Growth Strategy

#1. Identify the Most Engaged States

SELECT 
    State, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
FROM map_user
GROUP BY State
ORDER BY engagement_rate DESC;

#2. Identify user growth rate

SELECT 
    a.State, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    b.total_registered_users AS previous_year_users,
    ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#-- growth analysis - Identify which states have high or declining user growth.

SELECT 
    a.State, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    b.total_registered_users AS previous_year_users,
    ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) > 100 THEN 'High Growth'
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) BETWEEN 50 AND 100 THEN 'Moderate Growth'
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) BETWEEN 0 AND 50 THEN 'Low Growth'
        ELSE 'Decline'
    END AS growth_analysis
FROM 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#3. District-Level User Engagement Analysis

SELECT State, District, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
FROM map_user
GROUP BY State, District
ORDER BY engagement_rate DESC;

#4. Analyze app engagement rates along with user growth.

SELECT 
    a.State, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    COALESCE(MAX(b.total_registered_users), 0) AS previous_year_users,  -- Ensure no NULL values
    ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) > 100 THEN 'High Growth'
        WHEN ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) BETWEEN 50 AND 100 THEN 'Moderate Growth'
        WHEN ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) BETWEEN 0 AND 50 THEN 'Low Growth'
        ELSE 'Decline'
    END AS growth_analysis,
    ROUND((SUM(m.AppOpens) / NULLIF(a.total_registered_users, 0)) * 100, 2) AS engagement_rate  -- App Opens per user
FROM 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
LEFT JOIN 
    map_user m  -- Joining to get app engagement data
ON a.State = m.State AND a.Year = m.Year
GROUP BY a.State, a.Year, a.total_registered_users
ORDER BY growth_rate DESC;

#5. Identify Underperforming Regions for Expansion

SELECT 
    State, 
    SUM(count) AS total_registered_users
FROM aggregated_user
GROUP BY State
ORDER BY total_registered_users ASC
LIMIT 10;

#--Identify Underperforming Regions with Growth & Market Share
SELECT 
    a.State, 
    SUM(a.count) AS total_registered_users,
    COALESCE(ROUND(((SUM(a.count) - COALESCE(SUM(b.count), 0)) / NULLIF(SUM(b.count), 0)) * 100, 2), 0) AS growth_rate,
    ROUND((SUM(a.count) / (SELECT SUM(count) FROM aggregated_user)) * 100, 2) AS market_share,
    CASE 
        WHEN ROUND((SUM(a.count) / (SELECT SUM(count) FROM aggregated_user)) * 100, 2) > 3 THEN 'High Adoption'
        WHEN ROUND((SUM(a.count) / (SELECT SUM(count) FROM aggregated_user)) * 100, 2) BETWEEN 1 AND 3 THEN 'Moderate Adoption'
        ELSE 'Low Adoption'
    END AS adoption_category
FROM aggregated_user a
LEFT JOIN aggregated_user b 
    ON a.State = b.State AND a.Year = b.Year + 1
GROUP BY a.State
ORDER BY total_registered_users ASC;

#6. Compare Engagement Trends by Quarter

SELECT State,Year, Quarter, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
FROM map_user
GROUP BY State, Year, Quarter
ORDER BY State, Year, Quarter ASC limit 100;

#--Engagement Analysis to improve marketing

SELECT 
    a.State,
    a.Year, 
    a.Quarter, 
    SUM(a.RegisteredUsers) AS total_registered_users,
    SUM(a.AppOpens) AS total_app_opens,
    ROUND((SUM(a.AppOpens) / NULLIF(SUM(a.RegisteredUsers), 0)) * 100, 2) AS engagement_rate,
    CASE 
        WHEN ROUND((SUM(a.AppOpens) / NULLIF(SUM(a.RegisteredUsers), 0)) * 100, 2) > 20000 THEN 'High Engagement'
        WHEN ROUND((SUM(a.AppOpens) / NULLIF(SUM(a.RegisteredUsers), 0)) * 100, 2) BETWEEN 10000 AND 20000 THEN 'Moderate Engagement'
        ELSE 'Low Engagement'
    END AS engagement_category
FROM map_user a
LEFT JOIN map_user b 
    ON a.State = b.State AND a.Year = b.Year AND a.Quarter = b.Quarter + 1  -- Compare to previous quarter
GROUP BY a.State, a.Year, a.Quarter
ORDER BY engagement_rate desc
LIMIT 100;
