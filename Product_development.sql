#1. Identify the Most Popular Transaction Types for New Features

SELECT 
    Transaction_type, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Transaction_type
ORDER BY total_transactions DESC;

#2.Find Regions with High User Growth for Feature Rollout

SELECT 
    a.State, 
    a.Year, 
    a.count AS current_year_users, 
    b.count AS previous_year_users,
    ROUND(((a.count - b.count) / NULLIF(b.count, 0)) * 100, 2) AS user_growth_rate
FROM 
    (SELECT State, Year, SUM(count) AS count FROM aggregated_user GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS count FROM aggregated_user GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY user_growth_rate DESC;

#3. Identify User Behavior Based on App Usage

SELECT 
    State, 
    Year, 
    SUM(RegisteredUsers) AS total_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate
FROM map_user
GROUP BY State, Year
ORDER BY avg_engagement_rate DESC;

#4. Find Transaction Patterns for New Service Creation

SELECT 
    Transaction_count, 
    SUM(Transaction_amount) AS total_spent,
    COUNT(*) AS transaction_frequency
FROM top_trans
GROUP BY Transaction_count
ORDER BY total_spent DESC, transaction_frequency DESC;
