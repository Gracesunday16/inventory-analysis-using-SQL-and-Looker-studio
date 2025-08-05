# Inventory Management Data Analytic project using SQL and Looker studio


🎯 [Click here to view the full interactive dashboard](https://lookerstudio.google.com/reporting/84bcac4f-6cdf-42eb-bca8-625846fb63c6)

## Table of content
- [Project Overview](#project-overview)
- [Business Problem](#business-problem)
- [Why This Project Matters](#why-this-project-matters)
- [Project Objectives](#project-objectives)
- [Dataset Description](#dataset-description)
- [Tools and Technologies ](#tools-and-technologies)
- [Exploratory Data Analysis](#exploratory-data-analysis )
- [SQL for Data Preparation](#sql-for-data-preparation)
- [Key Metrics & Definitions](#Key-metrics-&-definitions)
- [Data Visualization ](#data-visualization)
- [Insights](#insights)
- [Recommendations](#recommendations)
- [Business Impact](#business-impact)
- [Conclusion](#conclusion)
- [Contact](#contact)
  
## 🧩 Project Overview
This Inventory Management Dashboard was created to provide a complete, data-driven view of stock performance, product turnover, restocking priorities in inventory handling. It is built using SQL for data preparation and Google Looker Studio for interactive visualization.

The dashboard supports real-time decision-making by offering insights into:

- Stock quantity vs reorder thresholds
- Inventory value and reorder cost analysis
- Estimated runout risks and restocking urgency
- Product category  performance

The goal is to help businesses reduce stockouts, prevent overstock, and ensure efficient inventory turnover.

## 🧩 Business Problem
Inventory mismanagement is a critical issue for businesses, often leading to overstocking, stockouts, or dead inventory. Many companies lack real-time visibility into product performance, reorder needs, and stock health, resulting in lost revenue, higher holding costs, and poor customer satisfaction.

## ❗ Why This Project Matters
Effective inventory management directly influences a business’s profitability, operational efficiency, and customer experience. With increasing pressure to optimize supply chains and reduce waste, businesses need dashboards that transform raw inventory data into actionable insights.

This project bridges the gap between data and decision-making by helping stakeholders identify fast- and slow-moving products, prioritize restocking, and monitor turnover efficiency — all from an interactive dashboard.

## 🎯 Project Objective
- Build an interactive, data-driven Inventory Management Dashboard using Looker Studio
- Analyze product performance by:
  - Turnover rate
  - Reorder urgency
  - Stock health
- Identify restocking priorities and high-risk product categories
- Visualize key inventory KPIs and trends to support better performance.

## 🏗️ Dataset Description:
This dataset provides detailed information on various grocery items, including product details, stock levels, reorder data, pricing, and sales performance. The data covers 990 products across various categories such as Grains & Pulses, Beverages, Fruits & Vegetables, and more.

**The dataset has the following key columns:**
Product_ID, Product_Name, Category, Supplier_ID, Supplier_Name, Stock_Quantity, Reorder_Level, Reorder_Quantity, Unit_Price, Received_Date, Last_Order_Date, Sales_Volume, Inventory_Turnover_Rate, Status (Active, Discontinued, Backordered).

## 📁 Tools and Technologies 
- SQL (Bigquery) - Data enrichment, transformation and metric derivation.
- Google Sheets - Dataset quick preview.
- Google Looker Studio - Interactive data visualization and dashboard building.

## Exploratory Data Analysis 
I perform Exploratory Data Analysis (EDA) on the Grocery Inventory and Sales Dataset in BigQuery using SQL, I focused on understanding the dataset’s structure, distributions, patterns, and potential issues to inform your inventory management project. EDA helped me uncover insights like stock trends, sales patterns, and data quality issues before building metrics.

**EDA Objectives for Inventory Management**
- Understand the dataset’s structure (columns, data types, row count).
- Identify missing or inconsistent data.Analyze distributions (e.g., stock levels, sales).
- Detect patterns (e.g., seasonal sales, stockouts).
- Prepare for deeper analysis (e.g., turnover).

**SQL Queries for EDA** 

```sql
-- 1. Understand Table Structure: Check column names, data types, and sample data - view table schema and sample rows

SELECT *
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
LIMIT 20;

-- Count Total Rows
SELECT COUNT(*) AS total_rows
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;

-- 2. Check Data Quality : Missing Values
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS missing_product_name,
    SUM(CASE WHEN Stock_Quantity IS NULL THEN 1 ELSE 0 END) AS missing_stock,
    SUM(CASE WHEN Sales_Volume IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN Reorder_Level IS NULL THEN 1 ELSE 0 END) AS missing_reorder_level,
    SUM(CASE WHEN Catagory IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN Received_Date IS NULL THEN 1 ELSE 0 END) AS missing_received_date
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;
```

[Click to view all EDA queries](

## 🔹  SQL for Data Preparation

A combined SQL query was written to enrich the raw dataset with additional computed columns for analysis:

```sql
SELECT
-- 📌 Original Fields
  *,
-- 💰 Inventory Value = Quantity × Unit Price
  (Stock_quantity * Unit_price) AS Inventory_Value,

-- 🔺 Stock Status: Is quantity below or above reorder level?
CASE 
    WHEN Stock_quantity <= Reorder_level THEN 'Low Stock'
    WHEN Stock_Quantity > (Reorder_Level * 2) THEN 'Overstocked'
    ELSE 'Adequate Stock'
END AS Stock_Status,

-- 🔄 Stock Flag: Is the product in stock or out of stock?
CASE 
    WHEN Stock_quantity = 0 THEN 'Out of Stock'
    ELSE 'In Stock'
END AS Stock_Flag,

-- 🔥 Restock Priority: Do we need to reorder urgently?
 CASE 
    WHEN Stock_quantity <= Reorder_level AND Sales_volume > 0 THEN 'Urgent'
    WHEN Stock_quantity <= Reorder_level THEN 'Needs Review'
    ELSE 'OK'
END AS Restock_Priority,
  
-- Reorder Cost: Calculate cost of placing a reorder (Reorder_Quantity * Unit_Price). Budget for restocking expenses
    (Reorder_Quantity * Unit_Price) AS Reorder_Cost,

-- Estimated Stock Runout Days: Estimate days until stock runs out based on daily Sales_Volume. To plan restocking schedules to avoid stockouts
CASE
   WHEN Sales_Volume > 0 THEN (Stock_Quantity / Sales_Volume)
   ELSE NULL 
END AS Estimated_Runout_Days,

-- Sales-to-Stock Ratio: Measure demand relative to stock. High ratio indicates strong demand; NULL if Stock_Quantity is 0
-- Use Case: Identify high-demand or overstocked products
CASE 
   WHEN Stock_Quantity > 0 THEN (Sales_Volume / Stock_Quantity)
   ELSE NULL 
END AS Sales_to_Stock_Ratio,

-- Reorder Urgency Ratio: Ratio < 1 suggests urgent need for reorder. It prioritize purchase orders
    (Stock_Quantity / Reorder_Level )AS Reorder_Urgency_Ratio,

-- 📅 Received Month: Convert Received Date into Year-Month format. Checks monthly trend
  FORMAT_DATE('%Y-%m', Date_Received ) AS Received_Month,

-- Stock Turnover Days: Convert Inventory_Turnover_Rate to days to sell entire stock. Assess inventory efficiency
CASE 
    WHEN Inventory_Turnover_Rate > 0 THEN (365 / Inventory_Turnover_Rate)
    ELSE NULL 
END AS Stock_Turnover_Days,

-- 📈 Turnover Category: How fast is this product moving?
CASE
    WHEN 365 / Inventory_turnover_rate < 60 THEN 'Fast-moving'
    WHEN 365 / Inventory_turnover_rate BETWEEN 60 AND 120 THEN 'Moderate'
    ELSE 'Slow-moving'
END AS Turnover_Category,

-- 🔢 Reorder Gap: How much quantity should we top up? I used 'greatest than 0' to get only positive numbers
GREATEST(Reorder_quantity - Stock_quantity, 0) AS Reorder_gap

FROM 
     data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE
Catagory is NOT NULL
```

## 📌 Key Metrics & Definitions

**This SQL query generated the backbone for advanced metrics like:**

- **Inventory Value**:	Total value of items in stock (Stock × Unit Price)
- **Reorder Urgency Ratio**:	Stock level as a % of reorder level (for backend logic)
- **Restock Priority**:	Categorizes urgency (High, Medium, Low)
- **Estimated Runout Days**:	How many days stock can last at current sales pace
- **Turnover Category**:	Based on turnover rate: Fast/Moderate/Slow
- **Reorder Gap**:	Shortfall between current stock and reorder level
- **Reorder Cost**:	Estimated cost to restock (Stock Qty × 2 for buffer)

**These calculated fields were then imported into Google Looker Studio via a connected data source.**

## 📊 Data Visualization 
Looker Studio was used to build an interactive dashboard, segmented logically to support user needs from executive summaries to deep-dive product analysis.

**🧱 Final Dashboard Structure**

**✅ Section 1: Executive Summary (Top KPIs)**
- Inventory Value
- Total Stock Quantity
- Total Reorder Cost
- Sales-to-Stock Ratio

**🔁 Section 2: Inventory Health & Urgency**
- Restock Priority Distribution (Bar Chart)
- Inventory Status (Active, Backordered, Discontinued - Donut Chart)
- Turnover Category (Fast, Moderate, Slow - Donut Chart)

**📈 Section 3: Inventory Efficiency**
- Inventory Holding vs Sales Efficiency (Combo: Avg Days vs Sales-to-Stock Ratio)

**💰 Section 4: Financial & Runout Analysis**
- Inventory Value vs Reorder Cost Over Time (Line Chart)
- Estimated Runout Days by Category (Bar Chart)
- Reorder Cost vs Stock Quantity (Bubble Chart)

**📋 Section 5: Product-Level Drilldown*
Product Table with filters for category, supplier, priority, etc.

**💡 Section 6: Insight Panel**
A text-based summary of insights and recommendations generated based on analysis.


## ✅ Insights
1. 
- Fruits & Vegetables category shows high stock quantity significantly exceeding their reorder levels - suggesting overstocking which could increase storage costs or lead to spoilage.
- Beverages, Bakery and Fat and Oil categories are approaching critical thresholds, indicating a need to review replenishment plans.
- Grain and Pulses category has stock levels below reorder thresholds, putting them at high risk of stockouts and potential lost sales.
- Dairy and Seafood categoroes are well aligned- efficient inventory control

2. **Inventory health**
47% of all inventory are currently in low stock condition, indicating a widespread risk of stockouts if not addressed promptly. 28 % of inventory is overstocked, which may lead to excess holding costs and potentialwaste, especially for perishable goods.Only 27% of inventory is at an adequate stock level, suggesting improvement in inventory planning.

3. Fruits & Vegetables have the highest inventory value and longest runout period, indicating potential overstock, holding cost and spoilage as there are perishables
In contrast, Beverages and Bakery show shorter runout days, highlighting urgency for replenishment.

4.🔺 Reorder Cost Volatility:
The line chart reveals that Inventory Value consistently exceeds Reorder Cost, indicating good cost control — except in October, where Reorder Cost slightly exceeds Inventory Value, possibly due to urgent or bulk restocking.
In Febuary 2024 and 2025, both metrics show a gradual decline, possibly signaling: Slower sales or lower demand

5. Inventory Status:
About 47% of products are Active, while 33% are Backordered and 20% are Discontinued. This indicates strong operational health but with one-third of products facing availability or supply chain issues.

6. Turnover Category:
A majority (69.5%) of products are Fast-moving, which is a positive indicator of high product demand and efficient inventory turnover. However, 16.7% Moderate and 13.8% Slow-moving items may tie up capital or underperform in sales — requiring further attention.

7. Avg Days in Stock vs Sales-to-Stock Ratio:
Dairy and Seafood have high sales efficiency (high sales-to-stock ratios) but relatively short average days in stock, creating a risk of frequent stockouts.
Bakery and Beverages have both low stock days and low sales-to-stock ratios, suggesting they may be low performers or over-ordered

## 📌 Recommendation:
1. 🔺 Restock urgent categories: Prioritize restocking categories with low runout days (e.g., Bakery, Beverages), close to or below reorder threshold to avoid stockouts.
2. Reassess reorder points and review demand trends for overstocked categories.
3. Investigate the October cost anomaly and assess whether current declining trends in both inventory and reorder cost reflect planned optimization or signal understocking risks.
4. Review overstocked items like Fruits & Vegetables to reduce
5. ✅ Double down on fast-movers: with 69.5% of products fast-moving, continue investing in demand planning and stock optimization to sustain efficiency.
 excess holding costs or apply targeted promotions.
6. 📦 Reassess slow/moderate movers: Review pricing, promotions, or replacement options for slow-moving items to prevent capital lockup.
7. ⚠️ Stabilize backorders: With 33% of products backordered, consider investigating supplier lead times or introducing buffer stock for critical SKUs.

Monitor sales-to-stock ratios to identify fast-moving items worth prioritizing in inventory and forecast models.

Continuously monitor Sales-to-Stock Ratios to align stock levels with demand patterns.

## 💼 Business Impact

This dashboard enables decision-makers to:

- ✅ Avoid stockouts and lost sales by tracking reorder needs  
- ✅ Reduce excess inventory and holding costs  
- ✅ Focus on high-performing products while reviewing low-turnover items  
 
## 📌 Conclusion
This dashboard allows any business to visualize and act on inventory data, prevent losses due to overstocking or stockouts, and align restocking efforts with sales patterns. It’s designed with both business stakeholders and analysts in mind, balancing high-level clarity with operational detail.

## Contact me
Grace Sunday

[LinkedIn](https://www.linkedin.com/in/grace-sunday-b2b0622a6)

gracesunday16@gmail.com
