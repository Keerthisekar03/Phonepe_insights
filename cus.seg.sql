# Define Customer Segments Based on Spending

SELECT 
    State,
    SUM(Transaction_amount) AS total_spent,
    CASE 
        WHEN SUM(Transaction_amount) < 5000 THEN 'Low Spender'
        WHEN SUM(Transaction_amount) BETWEEN 5000 AND 50000 THEN 'Mid Spender'
        ELSE 'High Spender'
    END AS customer_segment
FROM aggregated_trans
GROUP BY State
ORDER BY total_spent DESC;

#Identify Spending Patterns by Transaction Type

SELECT 
    c.customer_segment,
    t.Transaction_type,
    SUM(t.Transaction_amount) AS total_spent
FROM (
    SELECT 
        State,
        SUM(Transaction_amount) AS total_spent,
        CASE 
            WHEN SUM(Transaction_amount) < 5000 THEN 'Low Spender'
            WHEN SUM(Transaction_amount) BETWEEN 5000 AND 50000 THEN 'Mid Spender'
            ELSE 'High Spender'
        END AS customer_segment
    FROM aggregated_trans
    GROUP BY State
) AS c
JOIN aggregated_trans t ON c.State = t.State
GROUP BY c.customer_segment, t.Transaction_type
ORDER BY c.customer_segment, total_spent DESC;

#Identify High-Value Customers (Frequent + High Spenders)
SELECT 
    State, 
    COUNT(Transaction_count) AS total_transactions, 
    SUM(Transaction_amount) AS total_spent
FROM aggregated_trans
GROUP BY State
HAVING SUM(Transaction_amount) > 50000 AND COUNT(Transaction_count) > 10
ORDER BY total_spent DESC;

#Identify Popular Payment Methods by Customer Segment (e.g., cashback for UPI users).
SELECT 
    c.customer_segment,
    t.Transaction_type,
    COUNT(t.Transaction_type) AS usage_count
FROM (
    SELECT 
        State,
        SUM(Transaction_amount) AS total_spent,
        CASE 
            WHEN SUM(Transaction_amount) < 5000 THEN 'Low Spender'
            WHEN SUM(Transaction_amount) BETWEEN 5000 AND 50000 THEN 'Mid Spender'
            ELSE 'High Spender'
        END AS customer_segment
    FROM aggregated_trans
    GROUP BY State
) AS c
JOIN aggregated_trans t ON c.State = t.State
GROUP BY c.customer_segment, t.Transaction_type
ORDER BY c.customer_segment, usage_count DESC;

#Insurance Analysis for Different Customer Segments
SELECT 
    c.customer_segment,
    SUM(i.Insurance_count) AS total_policies,
    SUM(i.Insurance_amount) AS total_insured_amount
FROM (
    SELECT 
        State,
        SUM(Transaction_amount) AS total_spent,
        CASE 
            WHEN SUM(Transaction_amount) < 5000 THEN 'Low Spender'
            WHEN SUM(Transaction_amount) BETWEEN 5000 AND 50000 THEN 'Mid Spender'
            ELSE 'High Spender'
        END AS customer_segment
    FROM aggregated_trans
    GROUP BY State
) AS c
JOIN aggregated_insurance i ON c.State = i.State
GROUP BY c.customer_segment
ORDER BY total_insured_amount DESC;
