#1 Detect Unusually High-Value Transactions

SELECT 
    State, Year, Quater, Transaction_type,
    Transaction_count, Transaction_amount,
    (SELECT AVG(Transaction_amount) FROM aggregated_trans) AS avg_transaction_amount
FROM aggregated_trans
WHERE Transaction_amount > (SELECT AVG(Transaction_amount) * 3 FROM aggregated_trans)
ORDER BY Transaction_amount DESC;

#2 Detect Multiple Transactions in a Short Time
SELECT 
    State, Year, Quater, Transaction_type, 
    SUM(Transaction_count) AS total_transactions
FROM aggregated_trans
GROUP BY State, Year, Quater, Transaction_type
HAVING total_transactions > 10
ORDER BY total_transactions DESC;

#3  Detect Transactions from Multiple Locations

SELECT 
    Transaction_type, COUNT(DISTINCT State) AS unique_states
FROM aggregated_trans
GROUP BY Transaction_type
HAVING COUNT(DISTINCT State) > 3
ORDER BY unique_states DESC;

#4  Detect Repeated Failed Transactions
#Your fraud detection query isn't returning results, meaning there may be no transactions with a failure rate > 80%.
SELECT 
    State, Year, Quater, Transaction_type,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN Transaction_amount = 0 THEN 1 ELSE 0 END) AS failed_transactions,
    (SUM(CASE WHEN Transaction_amount = 0 THEN 1 ELSE 0 END) / COUNT(*)) AS failure_rate
FROM aggregated_trans
GROUP BY State, Year, Quater, Transaction_type
HAVING failure_rate > 0.8
ORDER BY failure_rate DESC;

SELECT 
    Transaction_type, 
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN Transaction_amount = 0 THEN 1 ELSE 0 END) AS failed_transactions,
    (SUM(CASE WHEN Transaction_amount = 0 THEN 1 ELSE 0 END) / COUNT(*)) AS failure_rate
FROM aggregated_trans
GROUP BY Transaction_type
HAVING failure_rate > 0.5
ORDER BY failure_rate DESC;

#5 Find States with Excessive Transaction Activity
SELECT 
    State, 
    SUM(Transaction_count) AS total_attempts,
    SUM(Transaction_amount) AS total_amount
FROM aggregated_trans
GROUP BY State
HAVING SUM(Transaction_count) > (SELECT AVG(Transaction_count) * 2 FROM aggregated_trans)
ORDER BY total_attempts DESC;

#6 Detect Unusual High-Value Transactions -- Flags transactions significantly higher than the average.
SELECT 
    State, Year, Quater, Transaction_type, 
    SUM(Transaction_count) AS total_transactions,
    SUM(Transaction_amount) AS total_amount,
    (SELECT AVG(Transaction_amount) FROM aggregated_trans) AS avg_transaction_amount
FROM aggregated_trans
WHERE Transaction_amount > (SELECT AVG(Transaction_amount) * 3 FROM aggregated_trans)
GROUP BY State, Year, Quater, Transaction_type
ORDER BY total_amount DESC;

#7. Detect Abnormally High Transaction Counts -- Fraudsters often make many transactions in a short time.

SELECT 
    State, Year, Quater, Transaction_type, 
    SUM(Transaction_count) AS total_transactions
FROM aggregated_trans
GROUP BY State, Year, Quater, Transaction_type
HAVING SUM(Transaction_count) > (SELECT AVG(Transaction_count) * 3 FROM aggregated_trans)
ORDER BY total_transactions DESC;

#8 Detect Suspicious Transaction Types --most common transaction type used in large fraud cases.

SELECT 
    Transaction_type, 
    SUM(Transaction_amount) AS total_amount,
    SUM(Transaction_count) AS total_transactions
FROM aggregated_trans
GROUP BY Transaction_type
ORDER BY total_amount DESC;


#9 Detect Suspicious Locations (State-Wise Analysis) ---states with extreme transaction activity.
SELECT 
    State, 
    SUM(Transaction_amount) AS total_amount,
    SUM(Transaction_count) AS total_transactions
FROM aggregated_trans
GROUP BY State
ORDER BY total_amount DESC;
