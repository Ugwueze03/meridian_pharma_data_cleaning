-- ============================================================
-- Meridian Pharma Distribution — Data Quality SQL
-- Run against meridian_pharma.db (SQLite)
-- ============================================================

-- ------------------------------------------------------------
-- Task 1: Employees assigned to a store_id that doesn't exist
-- in the stores table (invalid, blank, or typo'd store IDs)
-- ------------------------------------------------------------
SELECT
    e.employee_id,
    (e.first_name || ' ' || e.last_name) AS full_name,
    e.role,
    e.store_id
FROM employees AS e
LEFT JOIN stores AS s
    ON e.store_id = s.store_id
WHERE s.store_id IS NULL;


-- ------------------------------------------------------------
-- Task 2: Employees with a missing (NULL) salary
-- ------------------------------------------------------------
SELECT
    employee_id,
    (first_name || ' ' || last_name) AS full_name,
    role,
    store_id
FROM employees
WHERE salary IS NULL;


-- ------------------------------------------------------------
-- Task 5: Customers who share the same email address across
-- two or more different customer_id records
-- ------------------------------------------------------------
SELECT
    email,
    customer_id
FROM customers
WHERE email IN (
    SELECT email
    FROM customers
    GROUP BY email
    HAVING COUNT(email) > 1
)
ORDER BY email;


-- ------------------------------------------------------------
-- Task 7: Order line items referencing a product_id that
-- doesn't exist in the products table, plus the dollar
-- exposure (quantity * unit_price) for each affected line
-- ------------------------------------------------------------
SELECT
    o.order_item_id,
    o.product_id,
    o.quantity,
    o.unit_price,
    ROUND((o.quantity * o.unit_price), 2) AS value_affected
FROM order_items AS o
LEFT JOIN products AS p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Total dollar exposure across all invalid-product line items:
SELECT
    ROUND(SUM(o.quantity * o.unit_price), 2) AS total_affected_value
FROM order_items AS o
LEFT JOIN products AS p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ------------------------------------------------------------
-- Task 8: Order line items with a negative quantity
-- (data entry errors — flagged, not auto-corrected, since the
-- sign vs. the magnitude may be the actual mistake)
-- ------------------------------------------------------------
SELECT
    order_item_id,
    order_id,
    quantity
FROM order_items
WHERE quantity < 0;


-- ------------------------------------------------------------
-- Bonus: Revenue by customer region (region_clean), used to
-- build the Power BI dashboard's regional revenue chart
-- ------------------------------------------------------------
-- region_clean mapping applied upstream in Excel per the
-- manager memo: Northeast -> East, Southeast -> South, Midwest -> North
SELECT
    c.region_clean,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.region_clean
ORDER BY total_revenue DESC;
