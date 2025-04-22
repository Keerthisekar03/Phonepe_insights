#Transaction Analysis Across States and Districts
#Identify the Top-Performing States

SELECT 
    State, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY State
ORDER BY total_revenue DESC;

#Identify High-Performing Districts

SELECT 
    State, 
    District, 
    SUM(Transacion_count) AS total_transactions,
    SUM(Transacion_amount) AS total_revenue
FROM map_trans
GROUP BY State, District
ORDER BY total_revenue DESC;

#Identify the Top-Performing Pin Codes

SELECT 
    State, 
    Pincode, 
    SUM(RegisteredUsers) AS total_transactions
FROM top_user
GROUP BY State, Pincode
ORDER BY total_transactions DESC limit 100;

#Compare Yearly Growth in Transactions

SELECT 
    a.State, 
    a.Year, 
    a.total_revenue AS current_year_revenue, 
    b.total_revenue AS previous_year_revenue,
    ROUND(((a.total_revenue - b.total_revenue) / NULLIF(b.total_revenue, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Transaction_amount) AS total_revenue 
     FROM aggregated_trans 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Transaction_amount) AS total_revenue 
     FROM aggregated_trans 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#Analyze the Most Popular Transaction Types

SELECT 
    Transaction_type, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Transaction_type
ORDER BY total_revenue DESC;

#Identify Underperforming Regions for Targeted Marketing

SELECT 
    State, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue
FROM aggregated_trans
GROUP BY State
ORDER BY total_revenue ASC
LIMIT 10;
