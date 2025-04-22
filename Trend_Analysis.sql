#1.Identify Transaction Trends Over Time

SELECT 
    Year, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Year
ORDER BY Year ASC;

#2. Identify the Fastest-Growing Transaction Types

SELECT 
    a.Transaction_type, 
    a.Year, 
    a.total_revenue AS current_year_revenue, 
    b.total_revenue AS previous_year_revenue,
    ROUND(((a.total_revenue - b.total_revenue) / NULLIF(b.total_revenue, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT Transaction_type, Year, SUM(Transaction_amount) AS total_revenue 
     FROM aggregated_trans 
     GROUP BY Transaction_type, Year) a
LEFT JOIN 
    (SELECT Transaction_type, Year, SUM(Transaction_amount) AS total_revenue 
     FROM aggregated_trans 
     GROUP BY Transaction_type, Year) b
ON a.Transaction_type = b.Transaction_type AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#3. Analyze Seasonal Demand Fluctuations

SELECT 
    Year, 
    Quater, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Year, Quater
ORDER BY Year, Quater ASC;

#4. Identify State-Wise Demand Fluctuations

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

