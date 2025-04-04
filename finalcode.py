import streamlit as st
import pandas as pd
import plotly.express as px
import requests
import os
from sqlalchemy import create_engine
import matplotlib.pyplot as plt
import seaborn as sns

# ---- SETUP PAGE CONFIG ----
st.set_page_config(page_title="PhonePe Dashboard", layout="wide")


# ---- LOAD TRANSACTION DATA ----
@st.cache_data
def load_transaction_data():
    return pd.read_csv("PhonePe_Transactions_2018_2024.csv")

transaction_data = load_transaction_data()

# ---- LOAD USERS DATA ----
@st.cache_data
def load_user_data():
    return pd.read_csv("C:/Users/rc/Documents/GitHub/pulse/data/phonepe_users.csv")

user_data = load_user_data()

# ---- LOAD INSURANCE DATA ----
@st.cache_data
def load_insurance_data():
    insurance_path = "C:/Users/rc/Documents/GitHub/pulse/data/phonepe_insurance.csv"
    if os.path.exists(insurance_path):
        return pd.read_csv(insurance_path)
    else:
        st.error("❌ Insurance data file not found!")
        return None

insurance_data = load_insurance_data()

# ---- LOAD INDIAN STATES GEOJSON ----
@st.cache_data
def load_geojson():
    geojson_url = "https://gist.githubusercontent.com/jbrobst/56c13bbbf9d97d187fea01ca62ea5112/raw/e388c4cae20aa53cb5090210a42ebb9b765c0a36/india_states.geojson"
    response = requests.get(geojson_url)
    if response.status_code == 200:
        return response.json()
    else:
        st.error("❌ Failed to load GeoJSON data")
        return None

india_geojson = load_geojson()

# ---- SIDEBAR NAVIGATION ----
st.sidebar.title("📌 PhonePe Insights")
page_selection = st.sidebar.radio("Go to:", ["Home Page", "Business Case Study"])

# ---- SELECT DATASET (Transactions / Users / Insurance) ----
st.sidebar.header("📊 Select Data Type")
data_type = st.sidebar.radio("Show Data For:", ["Transactions", "Users", "Insurance"])

# ---- HOME PAGE ----
if page_selection == "Home Page":
    st.title("📊 PhonePe Pulse - Interactive Dashboard")

    # ---- Sidebar Filters ----
    st.sidebar.header("🔍 Filters")
    selected_year = st.sidebar.selectbox("Select Year", sorted(transaction_data["Year"].unique(), reverse=True))
    selected_quarter = st.sidebar.selectbox("Select Quarter", sorted(transaction_data["Quarter"].unique()))

    if data_type == "Transactions":
        # ---- Filter Transaction Data ----
        data_filtered = transaction_data[(transaction_data["Year"] == selected_year) & 
                                         (transaction_data["Quarter"] == int(selected_quarter))]

        # ---- Aggregate Data ----
        data_aggregated = data_filtered.groupby("State")[["Transaction_Count", "Transaction_Amount"]].sum().reset_index()

        # ---- Calculate "Average Transaction Value" ----
        data_aggregated["Average_Transaction"] = (
            data_aggregated["Transaction_Amount"] / data_aggregated["Transaction_Count"]
        )

        # ---- Sidebar: Total Aggregated Values ----
        st.sidebar.header("📊 Total Transactions")
        total_transactions = data_filtered["Transaction_Count"].sum()
        total_value = data_filtered["Transaction_Amount"].sum()
        average_value = total_value / total_transactions if total_transactions != 0 else 0

        st.sidebar.metric("🛒 All Transactions", f"{total_transactions:,.0f}")
        st.sidebar.metric("💰 Total Transaction Value", f"₹{total_value:,.2f}")
        st.sidebar.metric("📉 Average Transaction Value", f"₹{average_value:,.2f}")

        # ---- Create Choropleth Map ----
        if india_geojson:
            fig = px.choropleth(
                data_aggregated,
                geojson=india_geojson,
                featureidkey="properties.ST_NM",
                locations="State",
                color="Transaction_Amount",
                color_continuous_scale="purples",
                title=f"Total Transaction Value - {selected_year} Q{selected_quarter}",
                hover_data=["State", "Transaction_Count", "Transaction_Amount", "Average_Transaction"]
            )
            fig.update_geos(fitbounds="locations", visible=False)
            st.plotly_chart(fig, use_container_width=True)

        # ---- Display Aggregated Data Table ----
        st.subheader(f"📄 Transaction Data for {selected_year} Q{selected_quarter}")
        st.dataframe(data_aggregated)

    elif data_type == "Users":
        # ---- Filter User Data ----
        user_filtered = user_data[(user_data["Year"] == selected_year) & 
                                  (user_data["Quarter"] == int(selected_quarter))]

        # ---- Aggregate User Data ----
        user_aggregated = user_filtered.groupby("State")[["Registered_Users", "App_Opens"]].sum().reset_index()

        # ---- Sidebar: User Insights ----
        st.sidebar.header("📈 User Insights")
        total_users = user_filtered["Registered_Users"].sum()
        total_app_opens = user_filtered["App_Opens"].sum()

        st.sidebar.metric("👥 Total Registered Users", f"{total_users:,.0f}")
        st.sidebar.metric("📲 Total App Opens", f"{total_app_opens:,.0f}")

        # ---- Create Choropleth Map for Users ----
        if india_geojson:
            fig = px.choropleth(
                user_aggregated,
                geojson=india_geojson,
                featureidkey="properties.ST_NM",
                locations="State",
                color="Registered_Users",
                color_continuous_scale="blues",
                title=f"Registered Users - {selected_year} Q{selected_quarter}",
                hover_data=["State", "Registered_Users", "App_Opens"]
            )
            fig.update_geos(fitbounds="locations", visible=False)
            st.plotly_chart(fig, use_container_width=True)

        # ---- Display User Data Table ----
        st.subheader(f"📄 User Data for {selected_year} Q{selected_quarter}")
        st.dataframe(user_aggregated)

    elif data_type == "Insurance":
        if insurance_data is not None:
            # ---- Filter Insurance Data ----
            insurance_filtered = insurance_data[(insurance_data["Year"] == selected_year) & 
                                                (insurance_data["Quarter"] == int(selected_quarter))]

            # ---- Aggregate Insurance Data ----
            insurance_aggregated = insurance_filtered.groupby("State")[["Policies_Issued", "Total_Amount"]].sum().reset_index()

            # ---- Sidebar: Insurance Insights ----
            st.sidebar.header("📜 Insurance Insights")
            total_policies = insurance_filtered["Policies_Issued"].sum()
            total_amount = insurance_filtered["Total_Amount"].sum()

            st.sidebar.metric("📑 Total Policies Issued", f"{total_policies:,.0f}")
            st.sidebar.metric("💵 Total Amount Insured", f"₹{total_amount:,.2f}")

            # ---- Create Choropleth Map for Insurance ----
            if india_geojson:
                fig = px.choropleth(
                    insurance_aggregated,
                    geojson=india_geojson,
                    featureidkey="properties.ST_NM",
                    locations="State",
                    color="Total_Amount",
                    color_continuous_scale="reds",
                    title=f"Total Insurance Amount - {selected_year} Q{selected_quarter}",
                    hover_data=["State", "Policies_Issued", "Total_Amount"]
                )
                fig.update_geos(fitbounds="locations", visible=False)
                st.plotly_chart(fig, use_container_width=True)

            # ---- Display Insurance Data Table ----
            st.subheader(f"📄 Insurance Data for {selected_year} Q{selected_quarter}")
            st.dataframe(insurance_aggregated)
            
# 🔗 MySQL Connection
db_connection_str = "mysql+pymysql://root:Niha_2023@localhost/phonepe"
engine = create_engine(db_connection_str)

# ---- HOME PAGE ----
if page_selection == "Business Case Study":
    st.title("📊 Business Case Study")

    # Create Dropdown Box in Main Screen
    selected_option = st.selectbox("Select a Category", [
        "Device Dominance and User Engagement Analysis",
        "Insurance Penetration and Growth Potential Analysis",
        "User Engagement and Growth Strategy",
        "Transaction Analysis Across States and Districts",
        "Insurance Transactions Analysis"
    ])

    # Display selection
    st.write(f"### {selected_option}")

    # ✅ 1️⃣ Device Dominance and User Engagement Analysis
    if selected_option == "Device Dominance and User Engagement Analysis":
        st.subheader("📊 Most Popular Device Brands")
        
        query = """
            SELECT 
                Brand, 
                SUM(count) AS total_registered_users,
                ROUND(AVG(Percentage), 2) AS avg_market_share
            FROM aggregated_user
            GROUP BY Brand
            ORDER BY total_registered_users DESC;
        """
        df = pd.read_sql(query, engine)

        # 📊 Bar Chart
        fig, ax = plt.subplots(figsize=(10, 6))
        sns.barplot(x="total_registered_users", y="Brand", data=df, palette="viridis", ax=ax)
        ax.set_xlabel("Total Registered Users")
        ax.set_ylabel("Brand")
        ax.set_title("📊 Most Popular Device Brands", fontsize=14)
        ax.grid(axis="x", linestyle="--", alpha=0.7)
        
        st.pyplot(fig)
        st.dataframe(df)

        # ✅ 2️⃣ State-wise App Engagement
        st.subheader("📊 State-wise App Engagement Analysis")

        query = """
            SELECT 
                State, 
                SUM(RegisteredUsers) AS total_registered_users,
                SUM(AppOpens) AS total_app_opens,
                ROUND(SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0), 2) AS avg_engagement_rate
            FROM map_user
            GROUP BY State
            ORDER BY avg_engagement_rate DESC;
        """
        df = pd.read_sql(query, engine)

        fig, ax = plt.subplots(figsize=(10, 6))
        sns.barplot(x=df["avg_engagement_rate"], y=df["State"], palette="coolwarm", ax=ax)
        ax.set_xlabel("Average Engagement Rate")
        ax.set_ylabel("State")
        ax.set_title("📊 Average App Engagement Rate by State", fontsize=14)
        ax.grid(axis="x", linestyle="--", alpha=0.7)

        st.pyplot(fig)
        st.dataframe(df)

        # ✅ 3️⃣ Device Utilization Analysis
        st.subheader("📊 Device Utilization Analysis")

        query = """
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
            ORDER BY brand_count DESC, total_registered_users DESC;
        """
        df = pd.read_sql(query, engine)

        utilization_counts = df["utilization_status"].value_counts()
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.pie(utilization_counts, labels=utilization_counts.index, autopct="%1.1f%%", colors=["red", "green"])
        ax.set_title("📊 Underutilized vs Optimally Utilized Devices", fontsize=14)

        st.pyplot(fig)
        st.dataframe(df)

        # ✅ 4️⃣ Device Growth Trends
        st.subheader("📈 Device Growth Trends")

        query = """
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
        """
        df = pd.read_sql(query, engine)

        fig, ax = plt.subplots(figsize=(10, 6))
        sns.barplot(x="growth_rate", y="Brand", hue="Year", data=df, palette="coolwarm", ax=ax)
        ax.set_xlabel("Growth Rate (%)")
        ax.set_ylabel("Brand")
        ax.set_title("📊 Yearly Growth Rate of Device Brands", fontsize=14)
        ax.legend(title="Year")
        ax.grid(axis="x", linestyle="--", alpha=0.7)

        st.pyplot(fig)
        st.dataframe(df)
    # ✅ Placeholder for other analysis sections
    
    elif selected_option == "Insurance Penetration and Growth Potential Analysis":
        st.subheader("📊 Insurance Penetration and Growth Analysis")

        # 📌 Query 1: Identify the Top States for Insurance Adoption
        st.subheader("🏆 Top States for Insurance Adoption")
        query = """
            SELECT 
                State, 
                SUM(Insurance_count) AS total_policies_sold,
                SUM(Insurance_amount) AS total_premium_collected,
                ROUND(SUM(Insurance_amount) / NULLIF(SUM(Insurance_count), 0), 2) AS avg_policy_value
            FROM aggregated_insurance
            GROUP BY State
            ORDER BY total_premium_collected DESC;
        """
        df = pd.read_sql(query, engine)

        fig, ax = plt.subplots(figsize=(10, 6))
        sns.barplot(x="total_premium_collected", y="State", data=df, palette="Blues_r", ax=ax)
        ax.set_xlabel("Total Premium Collected")
        ax.set_ylabel("State")
        ax.set_title("💰 Total Insurance Premium Collected by State")
        ax.grid(axis="x", linestyle="--", alpha=0.7)

        st.pyplot(fig)
        st.dataframe(df)

        # 📌 Query 2: Growth Analysis by State
        st.subheader("📈 Growth Rate of Insurance Transactions")
        query = """
            SELECT 
        State, 
        SUM(Insurance_count) AS total_policies_sold,
        (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM top_insurance) * 100) AS market_share
    FROM top_insurance
    GROUP BY State
    ORDER BY market_share ASC;
"""

        # --- Fetch Data from SQL ---
        df = pd.read_sql(query, engine)

        # --- Handle Missing Data ---
        df["market_share"] = df["market_share"].fillna(0).astype(float)  # Replace None with 0 and ensure numeric type

        # --- Plot Bar Chart ---
        fig, ax = plt.subplots(figsize=(14, 8))
        sns.barplot(y=df["State"], x=df["market_share"], palette="coolwarm", edgecolor="black", ax=ax)

        # --- Add Data Labels on Bars ---
        for index, value in enumerate(df["market_share"]):
            ax.text(value, index, f"{value:.2f}%", va="center", fontsize=10, fontweight="bold", color="black")

        # --- Customize Chart Appearance ---
        ax.set_ylabel("State", fontsize=12, fontweight="bold")
        ax.set_xlabel("Market Share (%)", fontsize=12, fontweight="bold")
        ax.set_title("📈 Market Share of Insurance Policies Sold", fontsize=16, fontweight="bold", color="#ff4c4c")
        ax.axvline(0, color="black", linewidth=1)  # Add baseline at 0% market share
        ax.grid(axis="x", linestyle="--", alpha=0.6)

        # --- Display in Streamlit ---
        st.pyplot(fig)

        # --- Show Data Table ---
        st.subheader("📋 Market Share Data Table")
        st.dataframe(df.style.background_gradient(cmap="coolwarm"))

        # 📌 Query 3: Categorizing States (Strong vs. Weak Adoption)
        st.subheader("📊 Strong vs. Weak Insurance Adoption")
        query = """
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
        """
        df = pd.read_sql(query, engine)

        adoption_counts = df["insurance_adoption"].value_counts()
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.pie(adoption_counts, labels=adoption_counts.index, autopct="%1.1f%%", colors=["green", "red"])
        ax.set_title("📊 Strong vs. Weak Insurance Adoption")

        st.pyplot(fig)
        st.dataframe(df)
    
    elif selected_option == "User Engagement and Growth Strategy":
        st.subheader("📊 User Engagement and Growth Strategy Overview")
        
        # 📌 Query 1: Identify the Most Engaged States
        st.subheader("🏆 Most Engaged States (App Opens per User)")
        query = """
            SELECT 
                State, 
                SUM(RegisteredUsers) AS total_registered_users,
                SUM(AppOpens) AS total_app_opens,
                ROUND((SUM(AppOpens) / NULLIF(SUM(RegisteredUsers), 0)) * 100, 2) AS engagement_rate
            FROM map_user
            GROUP BY State
            ORDER BY engagement_rate DESC;
        """
        df = pd.read_sql(query, engine)

        fig, ax = plt.subplots(figsize=(12, 7))
        sns.barplot(y=df["State"], x=df["engagement_rate"], palette="coolwarm", edgecolor="black", ax=ax)
        ax.set_xlabel("Engagement Rate (%)")
        ax.set_ylabel("State")
        ax.set_title("📈 Most Engaged States (App Opens per User)")
        ax.grid(axis="x", linestyle="--", alpha=0.6)

        st.pyplot(fig)
        st.dataframe(df.style.background_gradient(cmap="coolwarm"))

        # 📌 Query 2: User Growth Analysis by State
        st.subheader("📈 User Growth Analysis (Yearly Trend)")
        query = """
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
    """
        df = pd.read_sql(query, engine)
        
        # --- 📊 Bar Chart for Growth Analysis ---
        st.subheader("📈 User Growth Analysis by State")

        fig, ax = plt.subplots(figsize=(12, 6))
        sns.barplot(y=df["State"], x=df["growth_rate"], hue=df["growth_analysis"], palette="coolwarm", ax=ax)

        # --- Customize Chart Appearance ---
        ax.set_xlabel("Growth Rate (%)", fontsize=12, fontweight="bold")
        ax.set_ylabel("State", fontsize=12, fontweight="bold")
        ax.set_title("📊 Growth Analysis of States (High vs. Declining Growth)", fontsize=14, fontweight="bold")
        ax.axvline(0, color="black", linewidth=1)  # Add baseline at 0% growth
        ax.grid(axis="x", linestyle="--", alpha=0.6)

        # --- Display in Streamlit ---
        st.pyplot(fig)

        # --- Show Data Table ---
        st.subheader("📋 Growth Analysis Data Table")
        st.dataframe(df.style.background_gradient(cmap="coolwarm"))
        
        # 📌 Query 3: Identify Underperforming Regions
        st.subheader("📉 Underperforming Regions (Growth & Market Share)")
        
        # 🔗 MySQL Connection
        db_connection_str = "mysql+pymysql://root:Niha_2023@localhost/phonepe"
        engine = create_engine(db_connection_str)
        query = """
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
    """

        # --- Fetch Data ---
        @st.cache_data
        def fetch_data():
            return pd.read_sql(query, engine)

        df = fetch_data()

        # --- Count Adoption Categories ---
        adoption_counts = df["adoption_category"].value_counts()

        # --- 📊 Create a Pie Chart ---
        st.subheader("📊 Adoption Category Distribution")

        fig, ax = plt.subplots(figsize=(8, 6))
        colors = ["red", "orange", "green"]  # Colors for Low, Moderate, and High Adoption

        ax.pie(
            adoption_counts, labels=adoption_counts.index, autopct="%1.1f%%", 
            colors=colors, startangle=140, wedgeprops={"edgecolor": "black"}
        )
        ax.set_title("📊 User Adoption Categories", fontsize=14, fontweight="bold")

        # --- Display Pie Chart ---
        st.pyplot(fig)

        # --- Show Data Table ---
        st.subheader("📋 Adoption Data Table")
        st.dataframe(df.style.background_gradient(cmap="coolwarm"))

    elif selected_option == "Transaction Analysis Across States and Districts":
        # 🔗 MySQL Connection
        db_connection_str = "mysql+pymysql://root:Niha_2023@localhost/phonepe"
        engine = create_engine(db_connection_str)
            
        # 📌 Query 1: Analyze the Most Popular Transaction Types
        st.subheader("🏆 Analyze the Most Popular Transaction Types)")
        query = """
        SELECT 
            Transaction_type, 
            SUM(Transaction_count) AS total_transactions,
            SUM(Transaction_amount) AS total_revenue,
            ROUND(SUM(Transaction_amount) / NULLIF(SUM(Transaction_count), 0), 2) AS avg_transaction_value
        FROM aggregated_trans
        GROUP BY Transaction_type
        ORDER BY total_revenue DESC;
    """
        # Fetch data
        df = pd.read_sql(query, engine)

        

        # Pie chart
        st.subheader("📊 Revenue Distribution by Transaction Type")
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.pie(
            df["avg_transaction_value"],
            labels=df["Transaction_type"],
            autopct="%1.1f%%",
            startangle=140,
            colors=sns.color_palette("Set2", len(df)),
            wedgeprops={"edgecolor": "black"}
        )
        ax.set_title("💰 Total Revenue by Transaction Type", fontsize=14)
        st.pyplot(fig)
        # Show table
        st.subheader("📄 Transaction Summary")
        st.dataframe(df)
        
        # 📌 Query 1: Yearly Growth in Transactions
        query = """
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
"""
        # Fetch Data
        df = pd.read_sql(query, engine)
        # Bar Chart
        st.subheader("📊 Yearly Growth Rate in Transactions by State")
        fig, ax = plt.subplots(figsize=(12, 6))
        sns.barplot(y=df["State"], x=df["growth_rate"], palette="coolwarm", ax=ax)

        # Labels and Titles
        ax.set_xlabel("Growth Rate (%)")
        ax.set_ylabel("State")
        ax.set_title("📈 Yearly Growth in Transactions by State", fontsize=14)
        ax.grid(axis="x", linestyle="--", alpha=0.7)
        
        # Show Chart
        st.pyplot(fig)
        # Show Data
        st.subheader("📄 Yearly Transaction Growth Data")
        st.dataframe(df)
            
    elif selected_option == "Insurance Transactions Analysis":
        # 🔗 MySQL Connection
        db_connection_str = "mysql+pymysql://root:Niha_2023@localhost/phonepe"
        engine = create_engine(db_connection_str)
        query = """
    SELECT 
        State, 
        District, 
        Year, 
        Quarter, 
        SUM(Insurance_count) AS total_policies_sold,
        SUM(Insurance_amount) AS total_premium_collected
    FROM top_insurance
    WHERE Year BETWEEN 2020 AND 2024 
    GROUP BY State, District, Year, Quarter
    ORDER BY total_premium_collected DESC
    LIMIT 10;
"""

    # Fetch Data
    df = pd.read_sql(query, engine)

    # Combine State and District for labels
    df["Location"] = df["District"] + ", " + df["State"]

    # Streamlit Section
    st.subheader("🧭 Year-wise Top 10 Districts - Insurance Premium Distribution")

    # Get list of unique years
    years = df["Year"].unique()
    years.sort()

    # Year selector
    selected_year = st.selectbox("Select Year", years)

    # Filter data by selected year
    yearly_data = df[df["Year"] == selected_year]

    st.dataframe(yearly_data)
    # Plot pie chart
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.pie(
        yearly_data["total_premium_collected"],
        labels=yearly_data["Location"],
        autopct="%1.1f%%",
        startangle=140
    )
    ax.set_title(f"Insurance Premium Distribution in Top Districts ({selected_year})")

    st.pyplot(fig)
    query = """
SELECT 
    State, 
    Year, 
    Quater, 
    SUM(Insurance_count) AS total_policies_sold,
    (SUM(Insurance_count) / (SELECT SUM(Insurance_count) FROM aggregated_insurance WHERE Year = 2023 AND Quater = 2) * 100) AS market_share
FROM aggregated_insurance
WHERE Year BETWEEN 2020 AND 2024 
GROUP BY State, Year, Quater
ORDER BY market_share ASC
LIMIT 100;
"""

    # Fetch data
    df = pd.read_sql(query, engine)

    # Combine Year and Quarter into a single label (optional)
    df["Time"] = "Y" + df["Year"].astype(str) + " Q" + df["Quater"].astype(str)

    # Streamlit Header
    st.subheader("🚩 Underpenetrated States for Expansion")
    # Show DataFrame
    st.dataframe(df)
    # Plot bar chart
    fig, ax = plt.subplots(figsize=(12, 7))
    sns.barplot(data=df, x="market_share", y="State", hue="Time", ax=ax, palette="flare")

    ax.set_title("📉 Market Share of Insurance Policies Sold (Lowest 100)", fontsize=16)
    ax.set_xlabel("Market Share (%)")
    ax.set_ylabel("State")
    ax.legend(title="Year & Quarter", bbox_to_anchor=(1.05, 1), loc='upper left')
    ax.grid(axis="x", linestyle="--", alpha=0.5)

    # Show plot
    st.pyplot(fig)

    

    
