# Inventory Management Data Analytic project using SQL and Looker studio


About Dataset
Grocery Inventory and Sales Dataset
Dataset Overview:
This dataset provides detailed information on various grocery items, including product details, supplier information, stock levels, reorder data, pricing, and sales performance. The data covers 990 products across various categories such as Grains & Pulses, Beverages, Fruits & Vegetables, and more. The dataset is useful for inventory management, sales analysis, and supply chain optimization.

# Columns definations
-Product_ID: Unique identifier for each product.
-Product_Name: Name of the product.
-Category: The product category (e.g., Grains & Pulses, Beverages, Fruits & Vegetables).
-Supplier_ID: Unique identifier for the product supplier.
-Supplier_Name: Name of the supplier.
-Stock_Quantity: The current stock level of the product in the warehouse.
-Reorder_Level: The stock level at which new stock should be ordered.
-Reorder_Quantity: The quantity of product to order when the stock reaches the reorder level.
-Unit_Price: Price per unit of the product.
-Date_Received: The date the product was received into the warehouse.
-Last_Order_Date: The last date the product was ordered.
-Expiration_Date: The expiration date of the product, if applicable.
-Warehouse_Location: The warehouse address where the product is stored.
-Sales_Volume: The total number of units sold.
-Inventory_Turnover_Rate: The rate at which the product sells and is replenished.
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

# Notes:
The expiration dates and last order dates should be considered for time-sensitive or perishable items. In short, track these dates to manage perishable inventory effectively and reduce losses.
Some products have been marked as discontinued or backordered, indicating their current status in the inventory system.

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

Purpose: Identifies expired items (e.g., 11/18/2024 is past July 4, 2025).10. Prepare for Looker StudioEDA

Summary Table:CREATE TABLE data-analytics-project-438511.grocery_inventory.eda_summary AS
SELECT 
    Product_Category,
    COUNT(DISTINCT Product_ID) AS product_count,
    SUM(Sales_Volume) AS total_sales,
    SUM(Sales_Volume * Unit_Price) AS total_revenue,
    AVG(Stock_Quantity) AS avg_stock,
    COUNT(CASE WHEN Stock_Quantity = 0 THEN 1 END) AS stockout_events,
    COUNT(CASE WHEN Stock_Quantity <= Reorder_Level THEN 1 END) AS near_reorder
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_Category;
