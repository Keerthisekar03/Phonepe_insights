#1. Identify States with the Highest User Engagement

SELECT 
    State, 
    Year, 
    SUM(count) AS total_users,
    AVG(Percentage) AS avg_user_growth
FROM aggregated_user
GROUP BY State, Year
ORDER BY total_users DESC;

#2. Analyze District-Level User Engagement Trends

SELECT 
    State, 
    District, 
    Year, 
    SUM(RegisteredUsers) AS total_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate
FROM map_user
GROUP BY State, District, Year
ORDER BY avg_engagement_rate DESC;

#3. Track User Retention Growth Over Time

SELECT a.State, a.Year, a.RegisteredUsers AS current_year_users, b.RegisteredUsers AS previous_year_users,
    ROUND(((a.RegisteredUsers - b.RegisteredUsers) / NULLIF(b.RegisteredUsers, 0)) * 100, 2) AS user_growth_rate
FROM 
    (SELECT State, Year, SUM(RegisteredUsers) AS RegisteredUsers FROM top_user GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(RegisteredUsers) AS RegisteredUsers FROM top_user GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY user_growth_rate DESC;

#4. Identify Most Engaged Brands

SELECT 
    Brand, 
    SUM(count) AS total_users,
    AVG(Percentage) AS avg_user_growth
FROM aggregated_user
GROUP BY Brand
ORDER BY total_users DESC;

