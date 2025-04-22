#1. Identify High-Spending Users for Premium Offers

SELECT 
    Transaction_type, 
    SUM(Transaction_amount) AS total_revenue,
    SUM(Transaction_count) AS total_transactions,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Transaction_type
ORDER BY total_revenue DESC;

#2. Identify Regions with High User Engagement

SELECT 
    State, 
    SUM(RegisteredUsers) AS total_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate
FROM map_user
GROUP BY State
ORDER BY avg_engagement_rate DESC;

#3. Find the Fastest-Growing Customer Segments

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

#4. Identify Payment Preferences for Personalized Offers

SELECT 
    State, 
    COUNT(*) AS transaction_frequency,
    SUM(Transaction_amount) AS total_spent,
    ROUND(SUM(Transaction_amount) / COUNT(*), 2) AS avg_transaction_value
FROM top_trans
GROUP BY State
ORDER BY transaction_frequency DESC;

