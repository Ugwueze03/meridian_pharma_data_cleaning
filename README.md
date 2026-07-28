# Meridian Pharma Distribution — Data Cleaning & Reporting Project

A self-directed data cleaning project simulating the onboarding task list for a
new data analyst at a fictional pharmaceutical distribution company. Six
relational tables (~29,000 rows) with realistic, common data-entry issues were
cleaned and validated using **Excel, SQL, and Power BI**, following a task
list issued in a manager memo (included in `docs/`).

> **Note:** Meridian Pharma Distribution is a fictional company. All data in
> this repository is synthetically generated for the purpose of practicing
> and demonstrating data-cleaning workflows.

---

## Project Structure

```
meridian-pharma-data-cleaning/
├── data/
│   ├── raw/            # Original tables, issues intentionally present
│   └── cleaned/        # Final cleaned employees/customers/orders tables
├── flags/              # Issue reports — rows needing review, not deleted
├── sql/                # SQL used to detect and validate each issue
├── dashboard/           # Power BI summary dashboard (PDF export)
└── docs/                # Task brief (manager memo) — read this first
```

## Business Context

The `employees`, `customers`, `orders`, `order_items`, `products`, and
`stores` tables described operations for a pharmaceutical distributor across
24 regional distribution centers. A data quality review had been flagged as
overdue — several known issues were silently distorting monthly regional
performance reports.

## Task Brief

The original assignment, written as a manager's onboarding memo with nine
numbered tasks, is included in full:

- **[docs/TASK_BRIEF.md](docs/TASK_BRIEF.md)** — readable directly on GitHub
- [docs/Manager_Memo_Onboarding_Tasks.docx](docs/Manager_Memo_Onboarding_Tasks.docx) — original formatted version

Everything below — the SQL, the flag reports, the dashboard — maps directly
back to one of the nine tasks in that brief.

## Data Quality Issues Identified & Resolved

| # | Issue | Rows Affected | Resolution |
|---|-------|---------------|------------|
| 1 | Employees assigned to a `store_id` not present in the `stores` table | 29 of 800 | Flagged in `flags/employees_invalid_store_id.csv`; records kept, not deleted |
| 2 | Employees with a missing `salary` value | 16 of 800 | Flagged in `flags/employees_missing_salaries.csv`; left as true NULL, not estimated |
| 3 | Customer `region` using legacy labels (Northeast/Southeast/Midwest) instead of the current North/South/East/West standard | 483 of 4,000 | Standardized into a new `region_clean` column; original `region` preserved for audit |
| 4 | Customer `phone` numbers in 5+ inconsistent formats | all 4,000 | Standardized into `phone_clean` as `(XXX) XXX-XXXX` |
| 5 | Duplicate customer email addresses across different `customer_id` records | 41 emails / 82 rows | Flagged in `flags/customers_duplicate_emails.csv` for manual review, not auto-merged |
| 6 | Order dates stored in inconsistent formats (long-form text, ambiguous slash-separated dates) | 228 of 6,000 | Standardized to `YYYY-MM-DD` |
| 7 | Order line items referencing a `product_id` not present in the `products` table | 353 of ~17,939 | Flagged with dollar exposure calculated (`quantity × unit_price`) — **$936,619.71 total affected** |
| 8 | Order line items with a negative `quantity` (data entry errors) | 278 of ~17,939 | Flagged for correction, not silently converted to positive |
| 9 | Consolidated reporting | — | Built into a single-page Power BI dashboard |

## Tools & Approach

- **Excel** — used for initial spot-checks, `COUNTIF`/`VLOOKUP` validation
  against the reference tables, and standardizing the `region_clean` and
  `phone_clean` columns.
- **SQL (SQLite)** — used for set-based validation via `LEFT JOIN` /
  anti-join patterns to catch every broken foreign key at once, and to
  calculate the dollar exposure of invalid product references. See
  `sql/data_quality_queries.sql`.
- **Power BI** — final one-page dashboard summarizing total revenue by
  region, order volume and status by distribution center, and top products
  by revenue.

## Dashboard Summary

See `dashboard/meridian_dashboard.pdf`. Key figures:

- **Total revenue:** $41.85M across all orders
- **Revenue by region (region_clean):** East 26.79% · North 25.35% · South 24.96% · West 22.90%
- **Order volume by distribution center**, broken out by fulfillment status
  (Fulfilled / Pending / Cancelled / Backordered)
- **Top 10 products by revenue**

## Key SQL Pattern Used

The core technique for catching broken foreign keys — used for both the
`employees.store_id` and `order_items.product_id` checks — is a `LEFT JOIN`
anti-join:

```sql
SELECT e.employee_id, e.first_name, e.last_name, e.role, e.store_id
FROM employees AS e
LEFT JOIN stores AS s
    ON e.store_id = s.store_id
WHERE s.store_id IS NULL;
```

This keeps every row from the left table and surfaces only the ones with no
match on the right — more robust than a `NOT IN` subquery, which can behave
unexpectedly if the reference column contains any NULLs.

## What I'd Do Differently

A few real mistakes happened during this project and are left visible on
purpose rather than cleaned out of the history:

- An early cleaned file accidentally filled 16 missing salaries with `$0.00`
  instead of leaving them as true NULLs — caught and corrected before final
  submission.
- Two intermediate exports carried Excel's full blank-row range into the CSV
  (1M+ rows for what was really ~20 rows of data) — caught and trimmed.

Both are common real-world Excel export mistakes, and part of the point of
this project was practicing catching them.
