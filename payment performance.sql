#1.Find the Most Popular Payment Categories
 
SELECT 
    Transaction_type, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount,
    ROUND(SUM(Transaction_amount) / SUM(Transaction_count), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY Transaction_type
ORDER BY total_transactions DESC;

#2. Identify Top States for Each Payment Type

SELECT 
    State, 
    Transaction_type, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount
FROM aggregated_trans
GROUP BY State, Transaction_type
ORDER BY Transaction_type, total_transactions DESC;

#3. Year-over-Year Growth of Payment Categories

SELECT 
    a.Transaction_type, 
    a.Year, 
    a.total_amount AS current_year_amount, 
    b.total_amount AS previous_year_amount,
    ROUND(((a.total_amount - b.total_amount) / b.total_amount) * 100, 2) AS growth_rate
FROM 
    (SELECT Transaction_type, Year, SUM(Transaction_amount) AS total_amount 
     FROM aggregated_trans 
     GROUP BY Transaction_type, Year) a
LEFT JOIN 
    (SELECT Transaction_type, Year, SUM(Transaction_amount) AS total_amount 
     FROM aggregated_trans 
     GROUP BY Transaction_type, Year) b
ON a.Transaction_type = b.Transaction_type AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#4. Identify District-Level Payment Trends

SELECT 
    State, 
    District, 
    SUM(Transacion_count) AS total_transactions,
    SUM(Transacion_amount) AS total_amount,
    ROUND(SUM(Transacion_amount) / NULLIF(SUM(Transacion_count), 0), 2) AS avg_transaction_value
FROM map_trans
GROUP BY State, District
ORDER BY total_amount DESC;

#5. Identify the Fastest-Growing Districts (YoY Growth)

SELECT 
    a.State, a.District, a.Year, a.total_amount AS current_year_amount, b.total_amount AS previous_year_amount,
    ROUND(((a.total_amount - b.total_amount) / NULLIF(b.total_amount, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, District, Year, SUM(Transacion_amount) AS total_amount 
     FROM map_trans 
     GROUP BY State, District, Year) a
LEFT JOIN 
    (SELECT State, District, Year, SUM(Transacion_amount) AS total_amount 
     FROM map_trans 
     GROUP BY State, District, Year) b
ON a.State = b.State AND a.District = b.District AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;
