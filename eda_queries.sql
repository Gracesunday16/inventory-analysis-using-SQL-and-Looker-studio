-- 1. DUPLICATE RECORDS
SELECT
    Product_ID, 
    Received_Date, 
COUNT(*) AS record_count
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_ID, Received_Date
HAVING record_count > 1
LIMIT 10;

-- 2. Analyze Distributions

-- Stock Quantity Distribution*
SELECT 
    MIN(Stock_Quantity) AS min_stock,
    MAX(Stock_Quantity) AS max_stock,
    AVG(Stock_Quantity) AS avg_stock,
    STDDEV(Stock_Quantity) AS stddev_stock,
    APPROX_QUANTILES(Stock_Quantity, 4) AS stock_quartiles
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;

-- Sales Volume Distribution
SELECT 
    MIN(Sales_Volume) AS min_sales,
    MAX(Sales_Volume) AS max_sales,
    AVG(Sales_Volume) AS avg_sales,
    STDDEV(Sales_Volume) AS stddev_sales,
    APPROX_QUANTILES(Sales_Volume, 4) AS sales_quartiles
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Sales_Volume IS NOT NULL;

-- Inventory Turnover Rate Distribution
SELECT 
    MIN(Inventory_Turnover_Rate) AS min_turnover,
    MAX(Inventory_Turnover_Rate) AS max_turnover,
    AVG(Inventory_Turnover_Rate) AS avg_turnover,
    STDDEV(Inventory_Turnover_Rate) AS stddev_turnover,
    APPROX_QUANTILES(Inventory_Turnover_Rate, 4) AS turnover_quartiles
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Inventory_Turnover_Rate IS NOT NULL;

-- 3. Product & Category Counts
SELECT 
    COUNT(DISTINCT Product_ID) AS unique_products,
    COUNT(DISTINCT Category) AS unique_categories,
    COUNT(DISTINCT Supplier_ID) AS unique_suppliers
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;

-- 4. Temporal Patterns

-- Sales Volume by Month
SELECT 
    DATE_TRUNC(Received_Date, MONTH) AS month,
    SUM(Sales_Volume) AS total_sales,
    AVG(Stock_Quantity) AS avg_stock
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY month
ORDER BY month;

-- 5. Date Range
SELECT 
    MIN(Received_Date) AS earliest_date,
    MAX(Received_Date) AS latest_date
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis;

-- 6. Category & Product Insights

-- Top Products by Sales Volume:
SELECT 
    Product_ID,
    Product_Name,
    Product_Category,
    SUM(Sales_Volume) AS total_sales,
    SUM(Sales_Volume * Unit_Price) AS total_revenue
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_ID, Product_Name, Product_Category
ORDER BY total_sales DESC
LIMIT 10;

-- Category Performance
SELECT 
    Product_Category,
    COUNT(DISTINCT Product_ID) AS product_count,
    SUM(Sales_Volume) AS total_sales,
    AVG(Stock_Quantity) AS avg_stock
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Product_Category
ORDER BY total_sales DESC;

-- 7. Stockout and Reorder Patterns
  
-- Stockout Frequency
SELECT 
    Product_ID,
    Product_Name,
    Product_Category,
    COUNT(*) AS stockout_events
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Stock_Quantity = 0
GROUP BY Product_ID, Product_Name, Product_Category
ORDER BY stockout_events DESC
LIMIT 10;

-- Items Near Reorder Level
SELECT 
    Product_ID,
    Product_Name,
    Stock_Quantity,
    Reorder_Level
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
WHERE Stock_Quantity <= Reorder_Level
ORDER BY Stock_Quantity ASC;

-- 8. Status Analysis

--Status Distribution
SELECT 
    Status,
    COUNT(*) AS count_status,
    AVG(Stock_Quantity) AS avg_stock,
    AVG(Sales_Volume) AS avg_sales
FROM data-analytics-project-438511.grocery_inventory.inventory_analysis
GROUP BY Status;

