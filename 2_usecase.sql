#Device Dominance and User Engagement Analysis

#1.Identify the Most Popular Device Brands

	SELECT 
		Brand, 
		SUM(count) AS total_registered_users,
		ROUND(AVG(Percentage), 2) AS avg_market_share
	FROM aggregated_user
	GROUP BY Brand
	ORDER BY total_registered_users DESC;
    
#--To split each brand's total registered users by year and quarter

SELECT state, Brand, Year, Quater, 
    SUM(count) AS total_registered_users, 
    ROUND(AVG(Percentage), 2) AS avg_market_share
FROM aggregated_user
GROUP BY state, Brand, Year, Quater
ORDER BY Year ASC, Quater ASC;

#--to analyze only Apple (Brand = 'Apple')

SELECT Brand, Year, Quater, 
    SUM(count) AS total_registered_users, 
    ROUND(AVG(Percentage), 2) AS avg_market_share
FROM aggregated_user
WHERE Brand = 'Apple'  -- Filters only Apple users
GROUP BY Brand, Year, Quater
ORDER BY Year ASC, Quater ASC;


#2. Compare App Engagement Across Devices

#--Finds the most popular devices based on user registrations.

SELECT 
    Brand, 
    SUM(Count) AS total_registered_users,
    ROUND(AVG(Percentage), 2) AS avg_market_share
FROM aggregated_user
GROUP BY Brand
ORDER BY total_registered_users DESC;

#--Get Brand Count & Engagement

SELECT 
    a.Brand, 
    COUNT(a.Brand) AS brand_count,  -- Count of occurrences per brand
    SUM(a.Count) AS total_registered_users,
    SUM(m.AppOpens) AS total_app_opens,
    ROUND((SUM(m.AppOpens) / NULLIF(SUM(a.Count), 0)) * 100, 2) AS engagement_rate
FROM aggregated_user a
JOIN map_user m 
    ON a.State = m.State 
    AND a.Year = m.Year 
    AND a.Quater = m.Quarter  -- Ensure this matches actual column in map_user
GROUP BY a.Brand
ORDER BY engagement_rate DESC;


#3.  User Engagement by Region - This helps find states with high/low app engagement.

SELECT 
    State, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate
FROM map_user
GROUP BY State
ORDER BY avg_engagement_rate DESC;

#--Categorizing High & Low App Engagement - State wise

SELECT 
    State, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate,
    CASE 
        WHEN ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) between 80 and 175 THEN 'High Engagement'
        ELSE 'Low Engagement'
    END AS engagement_category
FROM map_user
GROUP BY State
ORDER BY avg_engagement_rate DESC;


#4. Identify Underutilized and Optimally Utilized Devices

SELECT 
    Brand, 
    COUNT(Brand) AS brand_count,
    SUM(count) AS total_registered_users,
    ROUND(AVG(Percentage), 2) AS avg_user_share,
    CASE 
        WHEN ROUND(AVG(Percentage), 2) between 0.0 and 0.09 THEN 'Underutilized'
        ELSE 'Optimally Utilized'
    END AS utilization_status
FROM aggregated_user
GROUP BY Brand
ORDER BY brand_count desc, total_registered_users DESC;


#5.  Analyze Device Adoption Growth Trends

SELECT a.Brand, a.Year, 
    a.total_registered_users AS current_year_users, 
    b.total_registered_users AS previous_year_users,
    ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT Brand, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY Brand, Year) a
LEFT JOIN 
    (SELECT Brand, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY Brand, Year) b
ON a.Brand = b.Brand AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#--remove duplicates in aggregated_user

SELECT DISTINCT Brand, Year
FROM aggregated_user
ORDER BY Brand, Year ASC;

#--Compare Growth with a New Column
SELECT 
    a.Brand, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    b.total_registered_users AS previous_year_users,
    ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) > 0 THEN 'Growth'
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) < 0 THEN 'Decline'
        ELSE 'No Change'
    END AS growth_comparison
FROM 
    (SELECT Brand, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY Brand, Year) a
LEFT JOIN 
    (SELECT Brand, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY Brand, Year) b
ON a.Brand = b.Brand AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;
