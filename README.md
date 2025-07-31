# Inventory Management Data Analytic project using SQL and Looker studio

# Dataset Overview:
This dataset provides detailed information on various grocery items, including product details, supplier information, stock levels, reorder data, pricing, and sales performance. The data covers 990 products across various categories such as Grains & Pulses, Beverages, Fruits & Vegetables, and more. The dataset is useful for inventory management, sales analysis, and supply chain optimization.

# Columns 
-Product_ID
-Product_Name
-Category
-Supplier_ID
-Supplier_Name
-Stock_Quantity
-Reorder_Level
-Reorder_Quantity
-Unit_Price
-Date_Received
-Last_Order_Date
-Expiration_Date
-Warehouse_Location
-Sales_Volume
-Inventory_Turnover_Rate
-Status: Current status of the product (e.g., Active, Discontinued, Backordered).

# Dataset Usage:
-Inventory Management: Analyze stock levels and reorder strategies to optimize product availability and reduce stockouts or overstock.
-Sales Performance: Track sales volume and inventory turnover rate to understand product demand and profitability.
-Supplier Analysis: Evaluate suppliers based on product availability, pricing, and delivery frequency.
-Product Lifecycle: Identify discontinued or backordered products and analyze expiration dates for perishable goods.

# How to Use:
This dataset can be used for various tasks such as:

Predicting reorder quantities using machine learning.
Analyzing inventory turnover to optimize stock levels.
Conducting sales trend analysis to identify popular or slow-moving items.
Improving supply chain efficiency by analyzing supplier performance.

# Exploratory Data Analysis (EDA) 
I perform Exploratory Data Analysis (EDA) on the Grocery Inventory and Sales Dataset in BigQuery using SQL, I focused on understanding the dataset’s structure, distributions, patterns, and potential issues to inform your inventory management project.

EDA helped me uncover insights like stock trends, sales patterns, and data quality issues before building metrics like turnover or ABC analysis. 

# EDA Objectives for Inventory Management
- Understand the dataset’s structure (columns, data types, row count).
- Identify missing or inconsistent data.Analyze distributions (e.g., stock levels, sales).
- Detect patterns (e.g., seasonal sales, stockouts).
- Spot outliers or anomalies (e.g., unusually high/low stock).
- Prepare for deeper analysis (e.g., turnover, ABC analysis).

  ## SQL Queries for EDA.
# 1. Understand Table Structure
Purpose: Check column names, data types, and sample data - view table schema and sample rows

```SELECT *
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
LIMIT 5;```

**Count Total Rows**

```SELECT COUNT(*) AS total_rows
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;```

# 2. Check Data Quality

Missing Values
```SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS missing_product_name,
    SUM(CASE WHEN Stock_Quantity IS NULL THEN 1 ELSE 0 END) AS missing_stock,
    SUM(CASE WHEN Sales_Volume IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN Reorder_Level IS NULL THEN 1 ELSE 0 END) AS missing_reorder_level,
    SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN Received_Date IS NULL THEN 1 ELSE 0 END) AS missing_received_date
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;```

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

# 5. Detect Outliers and Anomalies

**High/Low Stock Quantity**
```SELECT
    Product_ID,
    Product_Name,
    Stock_Quantity
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Stock_Quantity > (SELECT AVG(Stock_Quantity) + 3 * STDDEV(Stock_Quantity) FROM data-analytics-project-438511.grocery_inventory.inventory_analysis)
   OR Stock_Quantity < (SELECT AVG(Stock_Quantity) - 3 * STDDEV(Stock_Quantity) FROM data-analytics-project-438511.grocery_inventory.inventory_analysis)
ORDER BY Stock_Quantity DESC;```

**High Sales Volume Outliers**
```SELECT 
    Product_ID,
    Product_Name,
    Sales_Volume
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Sales_Volume > (SELECT AVG(Sales_Volume) + 3 * STDDEV(Sales_Volume) FROM data-analytics-project-438511.grocery_inventory.inventory_analysis)
ORDER BY Sales_Volume DESC;```

# 6. Category and Product Insights

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


# Main SQL code
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


insights

✅ Overstock Risk:
Some categories (e.g., Fruits & Vegetables) are far above reorder level — may lead to holding cost.

🔺 Reorder Cost Volatility:
Inventory value and reorder cost trend don’t align in some months — flagging potential supply inefficiency.

⛔ Runout Risk:
Some categories have low stock with high sales-to-stock ratios — restock priority needed.

🧮 Healthy Mix:
Your stock status chart shows a good balance — ~47% Adequate Stock is a strong benchmark.

✅ Insight Captions for Each Chart
🟩 1. Bar Chart – “Stock vs Reorder Threshold by Product Category”
Insight:
This chart compares current stock against reorder levels across categories.
📌 Categories like Fruits & Vegetables and Dairy are well above reorder levels, suggesting potential overstock, while Beverages and Bakery are approaching critical thresholds, indicating a need to review replenishment plans.

🟢 2. Donut Chart – “Inventory Health Status Distribution”
Insight:
Inventory is mostly healthy, with 47% of products adequately stocked.
⚠️ However, 26% are low in stock, requiring timely restocking, and 27% are overstocked, which may lead to holding cost or spoilage risk.

📈 3. Line Chart – “Inventory & Reorder Cost Trend by Month”
Insight:
This trend highlights months where reorder costs spike despite stable inventory value — possibly due to supplier delays or uneven purchase planning.
Look into months with sharp reorder cost peaks (e.g., Jan 2024, Apr 2024) for procurement review.

📋 4. Table – “Category-Level Inventory Summary”
Insight:
This table summarizes stock quantity, value, and runout risk.
Fruits & Vegetables have the highest inventory value and longest runout period, indicating potential overstock.
In contrast, Beverages and Bakery show shorter runout days, highlighting urgency for replenishment.

🔵 5. Bubble Chart – “High-Impact Inventory by Cost and Quantity”
Insight:
This bubble chart maps products by reorder cost vs stock quantity, with bubble size representing inventory value.
Bubbles in the top-right corner indicate high-cost, high-stock products that demand financial oversight.
Items in the bottom-left are low-priority but should be monitored for future demand shifts.


📌 Inventory Insights:
47% of products are adequately stocked, reflecting healthy inventory control, but over 50% show stock imbalances — either understocked or overstocked.

Fruits & Vegetables hold the highest stock quantity and inventory value, yet show excessive buffer over reorder levels, pointing to potential overstock and holding costs.

Beverages and Bakery categories are approaching reorder thresholds, with relatively low runout days, suggesting the need for urgent replenishment.

A visible gap between Inventory Value and Reorder Cost in some months highlights procurement timing inefficiencies or variable supplier costs.

High reorder costs are clustered in high-stock products in the bubble chart — these items need stock optimization or demand review.

✅ Recommendations:
Prioritize restocking categories with low runout days (e.g., Bakery, Beverages) to avoid stockouts.

Review overstocked items like Fruits & Vegetables to reduce excess holding costs or apply targeted promotions.

Investigate reorder cost spikes in months where inventory value remained stable — this may reveal opportunities for better supplier negotiation.

Implement reorder urgency alerts based on runout days and restock priority to enhance replenishment decision-making.

Monitor sales-to-stock ratios to identify fast-moving items worth prioritizing in inventory and forecast models.

✨ How to Display It


 Key Insights:
47% of products are adequately stocked, but over 50% fall into either low stock or overstocked categories — indicating opportunities to optimize inventory balance.

Fruits & Vegetables show the highest stock and inventory value, significantly exceeding their reorder levels — suggesting potential overstock and carrying costs.

Bakery and Beverages have relatively low stock quantities and runout days, flagging them as high-priority for replenishment.

The line chart reveals that Inventory Value consistently exceeds Reorder Cost, indicating controlled spending — except in October, where Reorder Cost slightly exceeds Inventory Value, possibly due to urgent or bulk restocking.

In the bubble chart, high reorder cost and inventory value converge in certain categories, which may require inventory budget optimization.

✅ Recommendations:
Replenish critical categories like Bakery and Beverages to prevent stockouts.

Audit overstocked categories, especially Fruits & Vegetables, to minimize waste and holding costs.

Review October’s procurement data to understand the spike in reorder costs and identify improvement areas in supply planning.

Leverage restock priority and runout days metrics to trigger timely reorder actions.

Continuously monitor Sales-to-Stock Ratios to align stock levels with demand patterns.

Would you like a condensed 2–3 sentence version for a manager view or executive report?









Ask ChatGPT


in
