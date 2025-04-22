#1. Identify State-Level Payment Trends

SELECT 
    State, 
    Year, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount,
    ROUND(SUM(Transaction_amount) / SUM(Transaction_count), 2) AS avg_transaction_value
FROM aggregated_trans
GROUP BY State, Year
ORDER BY total_amount DESC;

#2. SELECT 
    State, 
    District, 
    Year, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount,
    ROUND(SUM(Transaction_amount) / SUM(Transaction_count), 2) AS avg_transaction_value
FROM map_trans
GROUP BY State, District, Year
ORDER BY total_amount DESC;

#3 Find the Most Popular Transaction Type in Each State

SELECT 
    State, 
    Transaction_type,
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount
FROM aggregated_trans
GROUP BY State, Transaction_type
ORDER BY State, total_amount DESC;


#4. Find Fast-Growing States for Digital Payments

SELECT 
    a.State, 
    a.Year,
    a.total_amount AS current_year_amount,
    b.total_amount AS previous_year_amount,
    ROUND(((a.total_amount - b.total_amount) / b.total_amount) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Transaction_amount) AS total_amount 
     FROM aggregated_trans 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Transaction_amount) AS total_amount 
     FROM aggregated_trans 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#5 