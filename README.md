# Inventory Management Data Analytic project using SQL and Looker studio

# Project Overview
This Inventory Management Dashboard was created to provide a complete, data-driven view of stock performance, product turnover, restocking priorities, and financial trends in inventory handling. It is built using SQL for data preparation and Google Looker Studio for interactive visualization.

The dashboard supports real-time decision-making by offering insights into:

- Stock quantity vs reorder thresholds
- Inventory value and cost analysis
- Product-level movement and efficiency
- Estimated runout risks and restocking urgency
- Category and supplier-level performance

The goal is to help businesses reduce stockouts, prevent overstock, and ensure efficient inventory turnover.

# Date source 

# 🏗️ Dataset Overview:
This dataset provides detailed information on various grocery items, including product details, stock levels, reorder data, pricing, and sales performance. The data covers 990 products across various categories such as Grains & Pulses, Beverages, Fruits & Vegetables, and more.
**The dataset has the following key columns:**
Product_ID, Product_Name, Category, Supplier_ID, Supplier_Name, Stock_Quantity, Reorder_Level, Reorder_Quantity, Unit_Price, Received_Date, Last_Order_Date, Sales_Volume, Inventory_Turnover_Rate, Status (Active, Discontinued, Backordered).

# 📁 Tools Used
- SQL (Bigquery) - Data enrichment, transformation and metric derivation.
- Google Sheets - Dataset quick preview.
- Google Looker Studio - Interactive data visualization and dashboard building.
  
# Exploratory Data Analysis (EDA) 
I perform Exploratory Data Analysis (EDA) on the Grocery Inventory and Sales Dataset in BigQuery using SQL, I focused on understanding the dataset’s structure, distributions, patterns, and potential issues to inform your inventory management project.

EDA helped me uncover insights like stock trends, sales patterns, and data quality issues before building metrics like turnover or ABC analysis. 

# EDA Objectives for Inventory Management
- Understand the dataset’s structure (columns, data types, row count).
- Identify missing or inconsistent data.Analyze distributions (e.g., stock levels, sales).
- Detect patterns (e.g., seasonal sales, stockouts).
- Spot outliers or anomalies (e.g., unusually high/low stock).
- Prepare for deeper analysis (e.g., turnover).

  # SQL Queries for EDA.  
**1. Understand Table Structure**
*Purpose: Check column names, data types, and sample data - view table schema and sample rows*
```SELECT *
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
LIMIT 20;

*Count Total Rows*
SELECT COUNT(*) AS total_rows
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;```

**2. Check Data Quality : Missing Values**
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
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;```

[Click to view all EDA queries](

# 🔹 Data Preparation (SQL)

A combined SQL query was written to enrich the raw dataset with additional computed columns for analysis:
```SELECT
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
    -- Note: Assumes Sales_Volume is daily; adjust multiplier (e.g., * 30 for monthly) if needed
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

  -- **Reorder Urgency Ratio: Ratio < 1 suggests urgent need for reorder. It prioritize purchase orders**
    (Stock_Quantity / Reorder_Level )AS Reorder_Urgency_Ratio,

  -- 📅 Received Month: Convert Received Date into Year-Month format. Checks monthly trend
  FORMAT_DATE('%Y-%m', Date_Received ) AS Received_Month,

   **-- Stock Turnover Days: Convert Inventory_Turnover_Rate to days to sell entire stock. Assess inventory efficiency**
    CASE 
        WHEN Inventory_Turnover_Rate > 0 THEN (365 / Inventory_Turnover_Rate)
        ELSE NULL 
    END AS Stock_Turnover_Days,

  ** -- 📈 Turnover Category: How fast is this product moving?**
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

# 📌 Key Metrics & Definitions

**This SQL query generated the backbone for advanced metrics like:**

- **Inventory Value**:	Total value of items in stock (Stock × Unit Price)
- **Reorder Urgency Ratio**:	Stock level as a % of reorder level (for backend logic)
- **Restock Priority**:	Categorizes urgency (High, Medium, Low)
- **Estimated Runout Days**:	How many days stock can last at current sales pace
- **Turnover Category**:	Based on turnover rate: Fast/Moderate/Slow
- **Reorder Gap**:	Shortfall between current stock and reorder level
- **Reorder Cost**:	Estimated cost to restock (Stock Qty × 2 for buffer)

**These calculated fields were then imported into Google Looker Studio via a connected data source.**

# 📊 Data Visualization 
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


# 🧠 Sample Insights (From Visuals)
Fruits & Vegetables show the highest estimated runout days, but sales are low — risk of spoilage due to slow turnover.

Many products fall under High Restock Priority, especially in Bakery and Seafood — restock cycles need tightening.

Bakery and Oils & Fats have high average stock days but low sales efficiency — potential overstock.

Inventory value and reorder cost were well aligned over time, except in October, where reorder cost slightly exceeded inventory value — may indicate over-ordering or discount period.

# ✅ Recommendations
Review reorder levels for high-priority items — adjust based on demand trends.

Implement perishable category logic — cap runout days for items with limited shelf life.

Reduce stock holding for slow movers and reallocate space to fast-moving categories.

Automate restock alerts using Restock Priority + Estimated Runout Days filters.

Use Turnover Categories to guide pricing, bundling, and clearance strategies.

# 📌 Conclusion
This dashboard allows any business to visualize and act on inventory data, prevent losses due to overstocking or stockouts, and align restocking efforts with sales patterns. It’s designed with both business stakeholders and analysts in mind, balancing high-level clarity with operational detail.



# Dataset Usage:
-Inventory Management: Analyze stock levels and reorder strategies to optimize product availability and reduce stockouts or overstock.
-Sales Performance: Track sales volume and inventory turnover rate to understand product demand and profitability.

# How to Use:
Analyzing inventory turnover to optimize stock levels.
Conducting sales trend analysis to identify popular or slow-moving items.
Improving supply chain efficiency by analyzing supplier performance.



**Duplicate Records**
``` SELECT 
    Product_ID, 
    Received_Date, 
    COUNT(*) AS record_count
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_ID, Received_Date
HAVING record_count > 1
LIMIT 10;

# 3. Analyze Distributions

**Stock Quantity Distribution**
```SELECT 
    MIN(Stock_Quantity) AS min_stock,
    MAX(Stock_Quantity) AS max_stock,
    AVG(Stock_Quantity) AS avg_stock,
    STDDEV(Stock_Quantity) AS stddev_stock,
    APPROX_QUANTILES(Stock_Quantity, 4) AS stock_quartiles
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;

**Sales Volume Distribution**
```SELECT 
    MIN(Sales_Volume) AS min_sales,
    MAX(Sales_Volume) AS max_sales,
    AVG(Sales_Volume) AS avg_sales,
    STDDEV(Sales_Volume) AS stddev_sales,
    APPROX_QUANTILES(Sales_Volume, 4) AS sales_quartiles
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Sales_Volume IS NOT NULL;```

**Inventory Turnover Rate Distribution**
```SELECT 
    MIN(Inventory_Turnover_Rate) AS min_turnover,
    MAX(Inventory_Turnover_Rate) AS max_turnover,
    AVG(Inventory_Turnover_Rate) AS avg_turnover,
    STDDEV(Inventory_Turnover_Rate) AS stddev_turnover,
    APPROX_QUANTILES(Inventory_Turnover_Rate, 4) AS turnover_quartiles
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Inventory_Turnover_Rate IS NOT NULL;``

**Product and Category Counts**
```SELECT 
    COUNT(DISTINCT Product_ID) AS unique_products,
    COUNT(DISTINCT Category) AS unique_categories,
    COUNT(DISTINCT Supplier_ID) AS unique_suppliers
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;```

# 4. Temporal Patterns
Sales Volume by Month
```SELECT 
    DATE_TRUNC(Received_Date, MONTH) AS month,
    SUM(Sales_Volume) AS total_sales,
    AVG(Stock_Quantity) AS avg_stock
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY month
ORDER BY month;

**Date Range**
```SELECT 
    MIN(Received_Date) AS earliest_date,
    MAX(Received_Date) AS latest_date
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;

# 5. Category and Product Insights

Top Products by Sales Volume:
```SELECT 
    Product_ID,
    Product_Name,
    Product_Category,
    SUM(Sales_Volume) AS total_sales,
    SUM(Sales_Volume * Unit_Price) AS total_revenue
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_ID, Product_Name, Product_Category
ORDER BY total_sales DESC
LIMIT 10;```

**Category Performance**
``SELECT 
    Product_Category,
    COUNT(DISTINCT Product_ID) AS product_count,
    SUM(Sales_Volume) AS total_sales,
    AVG(Stock_Quantity) AS avg_stock
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_Category
ORDER BY total_sales DESC;```

# 7. Stockout and Reorder Patterns
**Stockout Frequency**
```SELECT 
    Product_ID,
    Product_Name,
    Product_Category,
    COUNT(*) AS stockout_events
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Stock_Quantity = 0
GROUP BY Product_ID, Product_Name, Product_Category
ORDER BY stockout_events DESC
LIMIT 10;

**Items Near Reorder Level**
```SELECT 
    Product_ID,
    Product_Name,
    Stock_Quantity,
    Reorder_Level
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Stock_Quantity <= Reorder_Level
ORDER BY Stock_Quantity ASC;

# 8. Status Analysis
**Status Distribution**

``SELECT 
    Status,
    COUNT(*) AS count_status,
    AVG(Stock_Quantity) AS avg_stock,
    AVG(Sales_Volume) AS avg_sales
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Status;

# 9. Expired Stock Check (Considering Today’s Date: July 4, 2025)Items Past Expiration:SELECT 
    Product_ID,
    Product_Name,
    Expiration_Date,
    Stock_Quantity
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Expiration_Date < CURRENT_DATE()
ORDER BY Expiration_Date ASC;



insights

✅ Overstock Risk:
Some categories (e.g., Fruits & Vegetables) are far above reorder level — may lead to holding cost.

🔺 Reorder Cost Volatility:
Inventory value and reorder cost trend don’t align in some months — flagging potential supply inefficiency.

⛔ Runout Risk:
Some categories have low stock with high sales-to-stock ratios — restock priority needed.

🧮 Healthy Mix:
Your stock status chart shows a good balance — ~47% Adequate Stock is a strong benchmark.

# ✅ Insights

- Fruits & Vegetables category shows high stock quantity significantly exceeding their reorder levels - suggesting overstocking which could increase storage costs or lead to spoilage.
- Beverages, Bakery and Fat and Oil categories are approaching critical thresholds, indicating a need to review replenishment plans.
- Grain and Pulses category has stock levels below reorder thresholds, putting them at high risk of stockouts and potential lost sales.
- Dairy and Seafood categoroes are well aligned- efficient inventory control

📌 Recommendation:
Reassess reorder points and review demand trends for overstocked categories. For understocked groups, trigger timely replenishment to maintain service levels.


2. **Inventory health**
47% of all inventory are currently in low stock condition, indicating a widespread risk of stockouts if not addressed promptly. 28 % of inventory is overstocked, which may lead to excess holding costs and potentialwaste, especially for perishable goods.Only 27% of inventory is at an adequate stock level, suggesting improvement in inventory planning.

for dashboard
Nearly half of inventory is understocked (47%). Urgent restocking is needed, while 28% is overstocked - consider reduction or redistribution. Only 27% of products is on target

3. 
This trend highlights months where reorder costs spike despite stable inventory value — possibly due to supplier delays or uneven purchase planning.
Look into months with sharp reorder cost peaks (e.g., Jan 2024, Apr 2024) for procurement review.

4. Fruits & Vegetables have the highest inventory value and longest runout period, indicating potential overstock, holding cost and spoilage as there are perishables
In contrast, Beverages and Bakery show shorter runout days, highlighting urgency for replenishment.

5. The line chart reveals that Inventory Value consistently exceeds Reorder Cost, indicating good cost control — except in October, where Reorder Cost slightly exceeds Inventory Value, possibly due to urgent or bulk restocking.

In Febuary 2024 and 2025, both metrics show a gradual decline, possibly signaling: Slower sales or lower demand

📌 Recommendation:
Investigate the October cost anomaly and assess whether current declining trends in both inventory and reorder cost reflect planned optimization or signal understocking risks.




✅ Recommendations:
Prioritize restocking categories with low runout days (e.g., Bakery, Beverages) to avoid stockouts.

Review overstocked items like Fruits & Vegetables to reduce excess holding costs or apply targeted promotions.

Investigate reorder cost spikes in months where inventory value remained stable — this may reveal opportunities for better supplier negotiation.

Implement reorder urgency alerts based on runout days and restock priority to enhance replenishment decision-making.

Monitor sales-to-stock ratios to identify fast-moving items worth prioritizing in inventory and forecast models.

✅ Recommendations:
Replenish critical categories like Bakery and Beverages to prevent stockouts.

Audit overstocked categories, especially Fruits & Vegetables, to minimize waste and holding costs.

Review October’s procurement data to understand the spike in reorder costs and identify improvement areas in supply planning.

Leverage restock priority and runout days metrics to trigger timely reorder actions.

Continuously monitor Sales-to-Stock Ratios to align stock levels with demand patterns.

Would you like a condensed 2–3 sentence version for a manager view or executive report?



 Insights:
Inventory Status:
About 47% of products are Active, while 33% are Backordered and 20% are Discontinued. This indicates strong operational health but with one-third of products facing availability or supply chain issues.

Turnover Category:
A majority (69.5%) of products are Fast-moving, which is a positive indicator of high product demand and efficient inventory turnover. However, 16.7% Moderate and 13.8% Slow-moving items may tie up capital or underperform in sales — requiring further attention.

Reorder Urgency Ratio vs Estimated Runout Days:
Categories like Fruits & Vegetables and Dairy show both high urgency and shorter runout days, which means they are selling fast and may soon run out — prioritizing restocking here is critical.

Restock Priority vs Runout Days:
There’s a clear correlation between restock priority and stock depletion risk — Seafood, Grains & Pulses, and Fruits require immediate reorder actions based on their high turnover and short shelf life.

Avg Days in Stock vs Sales-to-Stock Ratio:
Dairy and Seafood have high sales efficiency (high sales-to-stock ratios) but relatively short average days in stock, creating a risk of frequent stockouts.
Bakery and Beverages have both low stock days and low sales-to-stock ratios, suggesting they may be low performers or over-ordered.

✅ Refined Recommendations:
✅ Double down on fast-movers: Your inventory is working well — with 69.5% of products fast-moving, continue investing in demand planning and stock optimization to sustain efficiency.

🔺 Restock urgent categories: Focus on high-turnover, low-stock categories like Fruits & Vegetables, Dairy, and Seafood — especially those with high reorder urgency ratios.

📦 Reassess slow/moderate movers: Review pricing, promotions, or replacement options for slow-moving items to prevent capital lockup.

⚠️ Stabilize backorders: With 33% of products backordered, consider investigating supplier lead times or introducing buffer stock for critical SKUs.

📊 Balance runout vs reorder cost: Align restocking cycles with runout predictions to avoid emergency purchases or over-ordering.

✍️ Optional Insight Box Title:
“Performance Summary & Restocking Strategy”
(or “Inventory Movement and Actionable Insights”)

Would you like a 2-line executive version or caption text for each individual chart too?









Ask ChatGPT
You said:
fruit and vegetable has highest reorder urgency and highest estimated days of runout


ChatGPT said:
Great observation, Grace — thank you for that! Since Fruits & Vegetables have the highest reorder urgency ratio and the longest estimated runout days, that changes the interpretation significantly. It means they're not at immediate risk of stockout, but the system is flagging them due to how their stock compares to reorder levels.

Let me revise that insight to reflect this more accurately.

✅ Updated Key Insight (Fruits & Vegetables Context)
Fruits & Vegetables have the highest reorder urgency ratio (stock is low relative to reorder level), but also the longest runout days — indicating they are selling very slowly despite being close to the reorder threshold.
🔍 This points to overstocking of a slow-selling item, and reorder thresholds may need to be recalibrated for this category.

🔁 Replace This Part in the Insight Text:
"Categories like Fruits & Vegetables and Dairy show both high urgency and shorter runout days..."

Replace with:

“Fruits & Vegetables show the highest reorder urgency but also have a long estimated runout period — a sign of slow sales combined with high reorder sensitivity. This may reflect excess stock flagged unnecessarily for replenishment, and suggests a need to review reorder level settings.”

Would you like me to update the full Insight Corner text with this adjustment included?


How do I present a meaningful insight and recommendation based on this 


ChatGPT said:
Great, Grace — now that you understand why Fruits & Vegetables show high estimated runout days, let's turn that into a clear, professional insight and recommendation that will impress in a dashboard or portfolio.

✅ Ready-to-Use Insight & Recommendation (Fruits & Vegetables Case)
🧠 Insight:
Although Fruits & Vegetables display the highest estimated runout days (300+ days), this is due to low sales volume and high stock levels, not actual shelf-life. As a result, the system suggests the stock will last a long time, but in reality, these are perishable goods that will expire long before that period.
This indicates overstocking of slow-moving perishable items, which poses a significant spoilage and cost risk.

✅ Recommendation:
Introduce category-specific logic for perishable products by:

Setting a maximum shelf-life cap on runout days (e.g., 14–30 days).

Creating an overstock flag when estimated runout exceeds the realistic shelf life.

Reassessing reorder levels for Fruits & Vegetables to align with actual sales patterns and perishability.

Consider running promotions or markdowns to accelerate sales and reduce waste.

✍️ Bonus (Short Version for Insight Corner):
Fruits & Vegetables appear overstocked with a runout period of 300+ days, but as perishables, they’ll expire long before. This mismatch signals a need for shelf-life-aware inventory controls and better demand alignment

Fruits & Vegetables appear overstocked with a runout period of 300+ days, but as perishables, they’ll expire long before. This mismatch signals a need for shelf-life-aware inventory controls and better demand alignment




