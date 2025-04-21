# **📊 PhonePe Transaction Insights :**

This project explores and analyzes digital transaction patterns, user behavior, and insurance data from PhonePe Pulse using SQL, Python, and interactive dashboards. The insights empower decision-making in user engagement, regional adoption, and insurance strategy.

------------------
## **🧠 Project Overview**

With India’s rapid shift to digital payments, platforms like PhonePe generate massive transactional and user data. This project aims to:

📍 Understand transaction volumes and value across regions and services

📱 Analyze user behavior by device and geography

🛡️ Discover insurance product adoption trends

📊 Create visual and interactive dashboards for real-time insights

------------
## **❓ Problem Statement**

Despite the massive volume of data, businesses struggle to extract actionable insights. This project addresses:

📌 **Where** digital payments and insurance services are gaining traction

👥 **Who** are the most engaged users

💰 **What** services generate the most value

📉 **How** regions differ in performance and opportunity

----------
## **💼 Business Use Cases**

![image](https://github.com/user-attachments/assets/049f61ee-f28a-4e25-8813-bd2b1b777d77)

👥 **Customer Segmentation:** Identify behavior patterns for personalized strategies

🌍 **Geographical Insights:** Detect regional trends for better targeting

🕵️‍♂️ **Fraud Detection:** Spot anomalies in transaction behavior

🧾 **Insurance Intelligence:** Analyze policy adoption and premium trends

📈 **Performance Benchmarking:** Evaluate service usage and ROI

🛠️ **Product Development:** Drive features based on data-backed demand

🎯 **Marketing Optimization:** Align campaigns with user activity

📊 **Trend Forecasting:** Plan for upcoming demand or slowdown

--------
## **🧰 Tools & Technologies**

🚩 Languages: 🐍Python, 🧮SQL

🚩 Data Visualization: 📊Streamlit, 📈Power BI

🚩 Libraries: 📦Pandas, 🎨Matplotlib, 📉Seaborn

🚩 Database: 🐘MySQL

🚩 Version Control: 💻Git, GitHub

----------
## **📥 Data Source**

Extracted from the official PhonePe Pulse GitHub Repository

Includes:

**💸 Aggregated Transaction & User Data**

**💸 Map-based District-Level Data**

**💸 Insurance Transaction Records**

**💸 Top-performing states, districts, and PINs**

----------
## 📌 **Key Insights**

💸 Peer-to-peer payments lead in both transaction volume and value

🛍️ Merchant payments have the highest frequency

🛡️ Insurance premium collection is highest in states like Karnataka and Maharashtra

🧭 Underpenetrated states present significant growth opportunities

📱 Device engagement varies — some brands show high installs but low app usage

📊 Growth & Market Share Analysis reveals strong regions for retention and weak ones for expansion

---------------
## **📱 Device Dominance and User Engagement Analysis**

  PhonePe aims to enhance user engagement and improve app performance by understanding user preferences across different device brands. The data reveals the number of registered users and app opens, segmented by device brands, regions, and time periods. However, trends in device usage vary significantly across regions, and some devices are disproportionately underutilized despite high registration numbers.

### **📊 Identify the Most Popular Device Brands**

   To analyze the most used devices, we calculate total registered users per brand.

![most popular device brands](https://github.com/user-attachments/assets/9e6dfafb-b45e-42cd-bfd0-6cf3bca67b6b)

----------------
### **📱 Compare App Engagement Across Devices**

To evaluate how actively users are interacting with the app across different device brands, we compare the number of registered users to the number of app opens. This helps us understand user engagement levels and identify devices where the app is either highly utilized or underutilized. 

![eng rate](https://github.com/user-attachments/assets/c72488b9-ab4a-428d-8f3a-964744549728)

### **🔍 Insight Gained:**

🔹 This analysis helps identify:

🔹 Top-performing brands where users are highly engaged.
Underperforming devices where users register but rarely open the app—indicating potential issues with user experience, performance, or compatibility on those devices.

----------------
## **🛡️ Insurance Penetration and Growth Potential Analysis**

**Identify the Top States for Insurance Adoption :**
   
   This step focuses on analyzing insurance performance across different states by examining both the volume of policies sold and the total premium collected. It provides a deeper understanding of how well insurance products are being adopted geographically.

![ins](https://github.com/user-attachments/assets/fb0d3601-cf0d-407d-afca-9d9eabd8d7f0)

**🔍 Insight Gained:**
 
🔹 Identifies top-performing states in terms of insurance adoption and revenue generation.

🔹 Highlights regions with higher-value insurance policies, which could indicate strong market potential or higher-value customers.

🔹 Helps prioritize states for targeted insurance marketing or expansion strategies.

🔹 This analysis enables data-driven decisions to enhance insurance reach and performance across India.

----------------
## ** 🛡️ Insurance Underpenetrated States for Expansion**

  This step helps pinpoint states with low insurance market share, revealing opportunities for strategic expansion and outreach. By comparing the share of policies sold by each state against the national total, we can identify underpenetrated markets. 

![market share insurance](https://github.com/user-attachments/assets/985c698d-8629-4a91-ad1b-fc51190a5e9f)

**🔍 Insight Gained:**
 
🔹 Flags low-performing states where insurance adoption is minimal.

🔹 Helps identify regions with untapped potential for insurance growth.

🔹 Supports data-driven expansion planning, enabling focused efforts to boost awareness, availability, or affordability in these areas.

🔹 This analysis is crucial for companies looking to increase their insurance footprint and capture market share in emerging or underserved states.

--------------

![image](https://github.com/user-attachments/assets/a54fbaf6-7f73-4141-858f-00e9914fc791)

------------------
## **📈 User Engagement and Growth Strategy**

**Identify Underperforming Regions with Growth & Market Share**

![user adoption](https://github.com/user-attachments/assets/98315766-1bfb-47c5-b49e-e96fb005cc6c)

**🔥 High Adoption (> 3% market share)**
 
🔹 Strong presence of registered users.
 
🔹 Indicates robust brand awareness, market penetration, and possibly high user satisfaction.
 
🔹 States in this category are likely already well-established markets.
 ️
**⚖️ Moderate Adoption (1% – 3% market share)**
 
🔹 Balanced performance—states showing good engagement but with room for growth.

🔹 These regions may benefit from targeted marketing or partnership strategies to push into the high adoption bracket.

**🔻 Low Adoption (< 1% market share)**

🔹 Underperforming regions with limited user base.

🔹 Could indicate challenges like low digital literacy, poor network coverage, or limited brand reach.

Presents high potential for growth if addressed with the right regional strategies (e.g., local campaigns, regional language support, awareness drives).

---------------
## **🗺️Transaction Analysis Across States and Districts**

**Analyze the Most Popular Transaction Types :**  This analysis aims to identify which transaction types are the most popular and profitable by examining both volume and value metrics. It helps understand user preferences, revenue drivers, and high-value services offered on the platform. 

![transactiontype](https://github.com/user-attachments/assets/c99f801f-6e71-46be-ac4b-73e56708a8f8)

### **💸 Peer-to-Peer Payments**
 
🔹 Massive total revenue (₹266.5T) and high average value per transaction (~₹3,134).

🔹 While not the most frequent, these transactions are large in value—likely personal or business transfers, rent, or bulk payments.

🔹 High-value, low-frequency pattern.

### **🛍️ Merchant Payments**

🔹 Highest in transaction volume (130B+ transactions) but with a moderate average value (~₹501).

🔹 Shows the dominance of daily, small-to-medium business payments—like groceries, cafes, and retail purchases.

🔹 Critical for everyday usage and merchant ecosystem growth.

### **📱 Recharge & Bill Payments**

🔹 Moderate in volume and revenue, with average value around ₹681.

🔹 Indicates utility-oriented transactions—frequent and essential, though not high in value.

🔹 Great for retention and recurring engagement.

### **🧾 Others** 

🔹 Low in volume but maintains an average transaction value of ₹665.

🔹 Could include miscellaneous services like donations, toll payments, subscriptions.

🔹 Useful to watch for niche service expansion.

### **📈 Financial Services**

🔹 Lowest in transaction count, but with notably high average value (~₹921).

🔹 These likely include loan repayments, insurance, investments—less frequent but financially significant.

🔹 Ideal for targeted financial product campaigns.

---------------
## **🛡️ Insurance Transactions Analysis (2020–2024)**

To identify which states in India contributed the most to insurance transactions in terms of both: **Total policies sold & Total premium collected**

![instrans](https://github.com/user-attachments/assets/b204b9be-3e37-4950-a2c0-658a2c3ff416)

### **🏆 Top performers:**

🔹 Karnataka (~13.7%) and Maharashtra (~11.8%) are the leading contributors, showing strong adoption and higher-value policies.
 
🔹 Uttar Pradesh, Tamil Nadu, Kerala, and Telangana also contribute significantly, each with a 5–9% share.
 
### **⚖️ Mid-range states:**

🔹 States like West Bengal, Rajasthan, and Haryana have a moderate share (3–5%), indicating decent insurance penetration.

### **⚠️ Underperformers:**
 
🔹 Smaller states/UTs like Dadra & Nagar Haveli, Sikkim, Mizoram, and Tripura have very low contributions, suggesting potential markets for future insurance growth and awareness campaigns

----------------
## **💡 Conclusion**

Over the course of this analysis, multiple insights emerged across user behavior, device engagement, insurance adoption, and transaction trends.

**1. App Engagement Across Devices**

🔹 Brands like Samsung and Xiaomi showed high engagement rates, indicating active user bases.

🔹 Certain brands exhibited lower app open-to-user ratios, suggesting underutilization or poor app performance.

**2. Insurance Transactions Analysis**

🔹 Karnataka and Maharashtra emerged as top states for insurance premium collection (13.7% and 11.8% respectively).

🔹 Several smaller states and union territories showed very low participation, highlighting untapped markets.

**3. Insurance Adoption Categorization**

🔹 States were effectively segmented into Strong and Weak Adoption zones.

🔹 This categorization supports strategic planning for region-specific marketing and insurance product design.

**4. Underpenetrated Markets for Expansion**

🔹 States with low market share and policy counts represent opportunities for growth.

🔹 These findings aid in targeting new regions for insurance penetration and user acquisition.

**5. Overall User Growth & Market Share**

🔹 States like Kerala, Telangana, and West Bengal showed a strong mix of growth rate and market share.
 
🔹 A 3-tier adoption model (High, Moderate, Low) gave clarity on regional performance and potential.

**6. Most Popular Transaction Types**

🔹 Peer-to-Peer payments dominated transaction value and volume, while Merchant payments had the highest transaction count.
 
🔹 Financial services and bill payments showed solid average transaction values, suggesting trust in digital platforms for high-value services.

--------------------
## 📈 **Results Achieved**

✅ Mastery in SQL-based data modeling

✅ Creation of insightful Python visualizations (bar/pie charts, heatmaps)

✅ Interactive dashboards via Streamlit and Power BI

✅ Strong business storytelling through data

✅ Clear documentation and presentation-ready visual summaries

------------
## 🚀 **Future Enhancements & Recommendations**

**🧮 Drill-Down Dashboards:** Develop interactive dashboards using Streamlit or Power BI with filters for year, quarter, state, and transaction type. Add heatmaps and trendlines to monitor seasonal shifts and growth hotspots.

**🔮 Predictive Analytics:** Implement models to forecast user growth, insurance demand, or transaction volume based on historical trends.
 
**🧭 Geo-Mapping with Insights:** Enhance visuals by integrating geo-spatial data to show adoption and transaction strength on Indian maps.
 
**👥 User Segmentation:** Combine app usage, transaction patterns, and device type to create customer personas for targeted marketing.
 
**📢 Insurance Awareness Campaigns:** Launch campaigns in low-adoption regions, especially North-Eastern states and UTs, with digital onboarding strategies.

**⚖️ Competitor Benchmarking:** Include comparative analysis with other apps to see how PhonePe stands in terms of market share and adoption.
 
**⏱️ Real-Time Monitoring:** Incorporate live APIs (if available) for real-time monitoring of usage metrics and fraud detection alerts.
