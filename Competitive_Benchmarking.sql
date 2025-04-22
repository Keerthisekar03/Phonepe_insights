#1. Identify Your Best and Worst Performing States

SELECT 
    State, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY State
ORDER BY total_revenue DESC;

#2. Identify High-Growth and Low-Growth States

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

#3. Compare Transaction Types to Find Strong and Weak Areas

SELECT 
    Transaction_type, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_revenue,
    ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Transaction_type
ORDER BY total_revenue DESC;

#4. Identify Districts with the Highest and Lowest Growth

SELECT 
    a.State, 
    a.District, 
    a.Year, 
    a.total_revenue AS current_year_revenue, 
    b.total_revenue AS previous_year_revenue,
    ROUND(((a.total_revenue - b.total_revenue) / NULLIF(b.total_revenue, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, District, Year, SUM(Transacion_amount) AS total_revenue 
     FROM map_trans 
     GROUP BY State, District, Year) a
LEFT JOIN 
    (SELECT State, District, Year, SUM(Transacion_amount) AS total_revenue 
     FROM map_trans 
     GROUP BY State, District, Year) b
ON a.State = b.State AND a.District = b.District AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

