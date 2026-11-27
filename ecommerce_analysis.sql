
-- =====================================================
-- PROJECT: E-COMMERCE SALES & PROFITABILITY ANALYSIS
-- DATABASE: E-COMMERCE ANALYSIS
-- TOOL: POSTGRESQL
-- =====================================================

-- PROJECT OBJECTIVE:
-- Analyze sales, revenue, profitability, products
-- and customer purchasing behaviour.


-- =====================================================
-- 1. DATA QUALITY CHECKS
-- =====================================================

-- 1.1 Check duplicate customers
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 1.2 Check missing customer emails
SELECT *
FROM customers
WHERE email IS NULL
   OR TRIM(email) = '';


-- 1.3 Check zero or negative quantities
SELECT *
FROM order_items
WHERE quantity <= 0;


-- 1.4 Check invalid discounts
SELECT *
FROM order_items
WHERE discount_pct < 0
   OR discount_pct > 1;


-- 1.5 Check missing order dates
SELECT *
FROM orders
WHERE order_date IS NULL;


-- 1.6 Check duplicate orders
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- =====================================================
-- 2. TOTAL REVENUE AND UNITS SOLD
-- =====================================================

CREATE OR REPLACE VIEW revenue_analysis AS
SELECT
    ROUND(
        SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct))::numeric, 2
    ) AS total_revenue,
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0;

SELECT *
FROM revenue_analysis;


-- =====================================================
-- 3. CATEGORY-WISE REVENUE
-- =====================================================

CREATE OR REPLACE VIEW category_revenue AS
SELECT
    p.category,
    ROUND(
        SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct))::numeric, 2
    ) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY p.category;

SELECT *
FROM category_revenue
ORDER BY total_revenue DESC;


-- =====================================================
-- 4. CATEGORY-WISE PROFIT
-- =====================================================

CREATE OR REPLACE VIEW category_profit AS
SELECT
    p.category,
    ROUND(
        SUM(
            oi.quantity *
            (p.unit_price * (1 - oi.discount_pct)
            - p.unit_cost)
        )::numeric, 2
    ) AS total_profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY p.category;

SELECT *
FROM category_profit
ORDER BY total_profit DESC;


-- =====================================================
-- 5. MONTHLY SALES ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW monthly_sales AS
SELECT
    DATE_TRUNC('month', o.order_date)::date AS sales_month,
    ROUND(
        SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct))::numeric, 2
    ) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY DATE_TRUNC('month', o.order_date);

SELECT *
FROM monthly_sales
ORDER BY sales_month;


-- =====================================================
-- 6. TOP 10 PRODUCTS ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW top_products AS
SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(
        SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct))::numeric, 2
    ) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY p.product_name;

SELECT *
FROM top_products
ORDER BY total_revenue DESC
LIMIT 10;


-- =====================================================
-- 7. CUSTOMER ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW customer_analysis AS
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct))::numeric, 2
    ) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY c.customer_id, c.customer_name;

-- Top 10 customers by spending
SELECT *
FROM customer_analysis
ORDER BY total_spent DESC
LIMIT 10;


-- =====================================================
-- 8. BUSINESS ANALYSIS: SALES BY REGION
-- =====================================================

SELECT
    o.sales_channel,
    ROUND(
        SUM(oi.quantity * p.unit_price *
        (1 - oi.discount_pct))::numeric, 2
    ) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY o.sales_channel
ORDER BY total_revenue DESC;


-- =====================================================
-- END OF PROJECT
-- =====================================================-- 
