use phonepe;

#aggregated
select * from aggregated_insurance;
select * from aggregated_trans;
select * from aggregated_user;
#map
select * from map_insurance;
select * from map_trans;
select * from map_user;
#top
select * from top_insurance;
select * from top_trans;
select * from top_user;

#Business use case 1. Device Dominance and User Engagement Analysis

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

#Business use case 2. Insurance Penetration and Growth Potential Analysis

#1. Identify the Top States for Insurance Adoption

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
GROUP BY State
ORDER BY total_premium_collected DESC;

#2. Identify High-Growth and Low-Growth States

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#--Finds states with the highest and lowest growth in insurance transactions.

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) > 800 THEN 'High Growth'
        WHEN ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) BETWEEN 100 AND 800 THEN 'Moderate Growth'
        WHEN ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) BETWEEN 0 AND 100 THEN 'Low Growth'
        ELSE 'Decline'
    END AS growth_analysis
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;


#3. District-Wise Insurance Analysis

SELECT 
    State, 
    District, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM map_insurance
GROUP BY State, District
ORDER BY total_premium_collected DESC;

#4. Compare Yearly Growth in Insurance Adoption

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#--Compare 2020 premium collections with 2019 - 2019 data not available to compare. so results are null

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM top_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
WHERE a.Year = 2020  -- Filter results for Year = 2020
ORDER BY growth_rate DESC;


#Identify Underpenetrated States for Expansion

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) AS market_share
FROM top_insurance
GROUP BY State
ORDER BY market_share ASC;

#--Categorizing States into Strong vs. Weak Insurance Adoption

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) AS market_share,
    CASE 
        WHEN (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) > 5 THEN 'Strong Adoption'
        ELSE 'Weak Adoption'
    END AS insurance_adoption
FROM top_insurance
GROUP BY State
ORDER BY market_share ASC;

#Business user case 3. User Engagement and Growth Strategy

#1. Identify the Most Engaged States

SELECT 
    State, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
FROM map_user
GROUP BY State
ORDER BY engagement_rate DESC;

#2. Identify user growth rate

SELECT 
    a.State, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    b.total_registered_users AS previous_year_users,
    ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#-- growth analysis - Identify which states have high or declining user growth.

SELECT 
    a.State, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    b.total_registered_users AS previous_year_users,
    ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) > 100 THEN 'High Growth'
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) BETWEEN 50 AND 100 THEN 'Moderate Growth'
        WHEN ROUND(((a.total_registered_users - b.total_registered_users) / NULLIF(b.total_registered_users, 0)) * 100, 2) BETWEEN 0 AND 50 THEN 'Low Growth'
        ELSE 'Decline'
    END AS growth_analysis
FROM 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#3. District-Level User Engagement Analysis

SELECT State, District, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
FROM map_user
GROUP BY State, District
ORDER BY engagement_rate DESC;

#4. Analyze app engagement rates along with user growth.

SELECT 
    a.State, 
    a.Year, 
    a.total_registered_users AS current_year_users, 
    COALESCE(MAX(b.total_registered_users), 0) AS previous_year_users,  -- Ensure no NULL values
    ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) AS growth_rate,
    CASE 
        WHEN ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) > 100 THEN 'High Growth'
        WHEN ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) BETWEEN 50 AND 100 THEN 'Moderate Growth'
        WHEN ROUND(((a.total_registered_users - COALESCE(MAX(b.total_registered_users), 0)) / NULLIF(MAX(b.total_registered_users), 0)) * 100, 2) BETWEEN 0 AND 50 THEN 'Low Growth'
        ELSE 'Decline'
    END AS growth_analysis,
    ROUND((SUM(m.AppOpens) / NULLIF(a.total_registered_users, 0)) * 100, 2) AS engagement_rate  -- App Opens per user
FROM 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(count) AS total_registered_users 
     FROM aggregated_user 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
LEFT JOIN 
    map_user m  -- Joining to get app engagement data
ON a.State = m.State AND a.Year = m.Year
GROUP BY a.State, a.Year, a.total_registered_users
ORDER BY growth_rate DESC;

#5. Identify Underperforming Regions for Expansion

SELECT 
    State, 
    SUM(count) AS total_registered_users
FROM aggregated_user
GROUP BY State
ORDER BY total_registered_users ASC
LIMIT 10;

#--Identify Underperforming Regions with Growth & Market Share
SELECT 
    a.State, 
    SUM(a.count) AS total_registered_users,
    COALESCE(ROUND(((SUM(a.count) - COALESCE(SUM(b.count), 0)) / NULLIF(SUM(b.count), 0)) * 100, 2), 0) AS growth_rate,
    ROUND((SUM(a.count) / (SELECT SUM(count) FROM aggregated_user)) * 100, 2) AS market_share,
    CASE 
        WHEN ROUND((SUM(a.count) / (SELECT SUM(count) FROM aggregated_user)) * 100, 2) > 3 THEN 'High Adoption'
        WHEN ROUND((SUM(a.count) / (SELECT SUM(count) FROM aggregated_user)) * 100, 2) BETWEEN 1 AND 3 THEN 'Moderate Adoption'
        ELSE 'Low Adoption'
    END AS adoption_category
FROM aggregated_user a
LEFT JOIN aggregated_user b 
    ON a.State = b.State AND a.Year = b.Year + 1
GROUP BY a.State
ORDER BY total_registered_users ASC;

#6. Compare Engagement Trends by Quarter

SELECT State,Year, Quarter, 
    SUM(RegisteredUsers) AS total_registered_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
FROM map_user
GROUP BY State, Year, Quarter
ORDER BY State, Year, Quarter ASC limit 100;

#--Engagement Analysis to improve marketing

SELECT 
    a.State,
    a.Year, 
    a.Quarter, 
    SUM(a.RegisteredUsers) AS total_registered_users,
    SUM(a.AppOpens) AS total_app_opens,
    ROUND((SUM(a.AppOpens) / NULLIF(SUM(a.RegisteredUsers), 0)) * 100, 2) AS engagement_rate,
    CASE 
        WHEN ROUND((SUM(a.AppOpens) / NULLIF(SUM(a.RegisteredUsers), 0)) * 100, 2) > 20000 THEN 'High Engagement'
        WHEN ROUND((SUM(a.AppOpens) / NULLIF(SUM(a.RegisteredUsers), 0)) * 100, 2) BETWEEN 10000 AND 20000 THEN 'Moderate Engagement'
        ELSE 'Low Engagement'
    END AS engagement_category
FROM map_user a
LEFT JOIN map_user b 
    ON a.State = b.State AND a.Year = b.Year AND a.Quarter = b.Quarter + 1  -- Compare to previous quarter
GROUP BY a.State, a.Year, a.Quarter
ORDER BY engagement_rate desc
LIMIT 100;

#Business use case 4. Transaction Analysis Across States and Districts

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

#Business use case 5.  Insurance Transactions Analysis

#1. Identify the Top-Performing States for Insurance Transactions

SELECT 
    State, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
WHERE Year between 2020 and 2024   -- Includes data from 2020 to 2024
GROUP BY State, Year, Quater
ORDER BY total_premium_collected DESC;

#2. Identify High-Performing Districts

SELECT 
    State, 
    District, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM map_insurance
WHERE Year between 2020 and 2024 
GROUP BY State, District, Year, Quater
ORDER BY total_premium_collected DESC;

#3.  top 10 districts where insurance transactions are highest.

SELECT 
    State, 
    District, 
    Year, 
    Quarter, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM top_insurance
WHERE Year between 2020 and 2024 
GROUP BY State, District, Year, Quarter
ORDER BY total_premium_collected DESC
LIMIT 10;

#track year-over-year growth by state

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#5. Identify Underpenetrated States for Expansion

SELECT 
    State, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM aggregated_insurance WHERE Year = 2023 AND Quater = 2) * 100) AS market_share
FROM aggregated_insurance
WHERE Year between 2020 and 2024 
GROUP BY State, Year, Quater
ORDER BY market_share ASC
LIMIT 100;

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

#1. Define Customer Segments Based on Spending

SELECT 
    State,
    SUM(Transaction_amount) AS total_spent,
    CASE 
        WHEN SUM(Transaction_amount) > 30000000000000 THEN 'High Spender'
        WHEN SUM(Transaction_amount) BETWEEN 10000000000000 AND 30000000000000 THEN 'Mid Spender'
        ELSE 'Low Spender'
    END AS customer_segment
FROM aggregated_trans
GROUP BY State
ORDER BY total_spent DESC;

#-- only low spender

SELECT 
    State,
    SUM(Transaction_amount) AS total_spent
FROM aggregated_trans
GROUP BY State
HAVING SUM(Transaction_amount) < 10000000000000  -- Condition for Low Spender
ORDER BY total_spent ASC;

#-- only high spender

SELECT 
    State,
    SUM(Transaction_amount) AS total_spent
FROM aggregated_trans
GROUP BY State
HAVING SUM(Transaction_amount) > 30000000000000  -- Condition for High Spender
ORDER BY total_spent DESC;

#-- only mid spender

SELECT 
    State,
    SUM(Transaction_amount) AS total_spent
FROM aggregated_trans
GROUP BY State
HAVING SUM(Transaction_amount) BETWEEN 10000000000000 AND 30000000000000  -- Condition for Mid Spender
ORDER BY total_spent DESC;

#2. Identify Spending Patterns by Transaction Type

SELECT 
    c.customer_segment,
    t.Transaction_type,
    SUM(t.Transaction_amount) AS total_spent
FROM (
    SELECT 
        State,
        SUM(Transaction_amount) AS total_spent,
        CASE 
            WHEN SUM(Transaction_amount) > 30000000000000 THEN 'High Spender'
            WHEN SUM(Transaction_amount) BETWEEN 10000000000000 AND 30000000000000 THEN 'Mid Spender'
            ELSE 'Low Spender'
        END AS customer_segment
    FROM aggregated_trans
    GROUP BY State
) AS c
JOIN aggregated_trans t ON c.State = t.State
GROUP BY c.customer_segment, t.Transaction_type
ORDER BY c.customer_segment, total_spent DESC;

#--to query only transaction_type=others 

select  Transaction_type, sum(transaction_amount) as total_spend
from aggregated_trans
where transaction_type = "others"
group by state;


#3. Identify High-Value Customers (Frequent + High Spenders)

SELECT 
    State, 
    COUNT(Transaction_count) AS total_transactions, 
    SUM(Transaction_amount) AS total_spent
FROM aggregated_trans
GROUP BY State
HAVING SUM(Transaction_amount) > 27000000000000   
ORDER BY total_spent DESC;

#4. Identify Popular Payment Methods by Customer Segment (e.g., cashback for UPI users).
SELECT 
    c.customer_segment,
    t.Transaction_type,
    COUNT(t.Transaction_type) AS usage_count
FROM (
    SELECT 
        State,
        SUM(Transaction_amount) AS total_spent,
        CASE 
            WHEN SUM(Transaction_amount) > 30000000000000 THEN 'High Spender'
            WHEN SUM(Transaction_amount) BETWEEN 10000000000000 AND 30000000000000 THEN 'Mid Spender'
            ELSE 'Low Spender'
        END AS customer_segment
    FROM aggregated_trans
    GROUP BY State
) AS c
JOIN aggregated_trans t ON c.State = t.State
GROUP BY c.customer_segment, t.Transaction_type
ORDER BY usage_count DESC;

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
            WHEN SUM(Transaction_amount) > 30000000000000 THEN 'High Spender'
            WHEN SUM(Transaction_amount) BETWEEN 10000000000000 AND 30000000000000 THEN 'Mid Spender'
            ELSE 'Low Spender'
        END AS customer_segment
    FROM aggregated_trans
    GROUP BY State
) AS c
JOIN aggregated_insurance i ON c.State = i.State
GROUP BY c.customer_segment
ORDER BY total_insured_amount DESC;

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

#5 #1. Identify the Most Popular Insurance Products

SELECT 
    type, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
GROUP BY type
ORDER BY total_policies_sold DESC;

#2.Analyze Insurance Growth Trends Over Time

SELECT 
    a.type, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT type, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY type, Year) a
LEFT JOIN 
    (SELECT type, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY type, Year) b
ON a.type = b.type AND a.Year = b.Year + 1
ORDER BY growth_rate DESC;

#3. Identify States with the Highest Insurance Adoption

SELECT 
    State, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM aggregated_insurance
GROUP BY State
ORDER BY total_premium_collected DESC;

#4. District-Level Insurance Analysis

SELECT 
    State, 
    District, 
    SUM(Insurance_count) AS total_policies_sold,
    SUM(Insurance_amount) AS total_premium_collected
FROM map_insurance
GROUP BY State, District
ORDER BY total_premium_collected DESC;

#5. Identify High-Value Insurance Buyers

SELECT 
    State, 
    SUM(Insurance_amount) AS total_premium_collected,
    SUM(Insurance_count) AS total_policies_sold,
    ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
FROM aggregated_insurance
GROUP BY State
ORDER BY avg_policy_value DESC
LIMIT 10;

#6. Identify Top Growth Markets for High-Value Insurance

SELECT 
    a.State, 
    a.Year, 
    a.total_premium_collected AS current_year_premium, 
    b.total_premium_collected AS previous_year_premium,
    ROUND(((a.total_premium_collected - b.total_premium_collected) / NULLIF(b.total_premium_collected, 0)) * 100, 2) AS growth_rate
FROM 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(Insurance_amount) AS total_premium_collected 
     FROM aggregated_insurance 
     GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY growth_rate DESC
LIMIT 10;

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

#1. Identify States with the Highest User Engagement

SELECT 
    State, 
    Year, 
    SUM(count) AS total_users,
    AVG(Percentage) AS avg_user_growth
FROM aggregated_user
GROUP BY State, Year
ORDER BY total_users DESC;

#2. Analyze District-Level User Engagement Trends

SELECT 
    State, 
    District, 
    Year, 
    SUM(RegisteredUsers) AS total_users,
    SUM(AppOpens) AS total_app_opens,
    ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate
FROM map_user
GROUP BY State, District, Year
ORDER BY avg_engagement_rate DESC;

#3. Track User Retention Growth Over Time

SELECT a.State, a.Year, a.RegisteredUsers AS current_year_users, b.RegisteredUsers AS previous_year_users,
    ROUND(((a.RegisteredUsers - b.RegisteredUsers) / NULLIF(b.RegisteredUsers, 0)) * 100, 2) AS user_growth_rate
FROM 
    (SELECT State, Year, SUM(RegisteredUsers) AS RegisteredUsers FROM top_user GROUP BY State, Year) a
LEFT JOIN 
    (SELECT State, Year, SUM(RegisteredUsers) AS RegisteredUsers FROM top_user GROUP BY State, Year) b
ON a.State = b.State AND a.Year = b.Year + 1
ORDER BY user_growth_rate DESC;

#4. Identify Most Engaged Brands

SELECT 
    Brand, 
    SUM(count) AS total_users,
    AVG(Percentage) AS avg_user_growth
FROM aggregated_user
GROUP BY Brand
ORDER BY total_users DESC;

