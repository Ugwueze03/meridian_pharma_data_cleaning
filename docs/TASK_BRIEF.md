# Task Brief — Meridian Pharma Distribution

**MERIDIAN PHARMA DISTRIBUTION**
Data & Analytics Department • 1180 Commerce Parkway, Suite 400 • Columbus, OH 43215

## MEMORANDUM

**To:** New Data Analyst, Regional Operations Team
**From:** Denise Okafor, Director of Data & Analytics
**Date:** July 16, 2026
**Re:** Data quality review — Employee, Customer, and Order records (Q3 onboarding project)

Welcome to the team. Before you're added to any live reporting builds, I want you to get hands-on with our operational data and clean up a set of known issues that have been sitting in our backlog. This is standard onboarding work for every new analyst on this team — it'll teach you our schema faster than any slide deck would, and the output actually matters: several of these issues are currently distorting regional performance reporting that goes to the executive team monthly.

You have three data sources describing the same information, so you can use whichever tool fits the task:

- `Meridian_Pharma_data.xlsx` — all six tables as Excel sheets, for quick spot-checks and pivot tables.
- `meridian_pharma.db` — the same data loaded into SQLite, for set-based queries and joins across tables.
- `schema.sql` — the relational schema (table structure and relationships) if you need to rebuild the database elsewhere (SQL Server, PostgreSQL, etc.).

Once the data is cleaned, I'd like the final output built into a short Power BI dashboard — details in Task 9 below.

---

### Task 1 — Validate store assignments
The employees table has a `store_id` column that is supposed to match a `store_id` in the stores table. It doesn't always. Identify every employee row whose `store_id` has no match in `stores` (including blanks). Do not delete these employee records — flag them in a new column and give me a count by role so I know which teams are affected.

### Task 2 — Identify missing salary data
Some rows in `employees.salary` are genuinely blank. Do not estimate or fill these in — that's a compensation decision above our pay grade. Just produce a clean list (`employee_id`, name, role, `store_id`) of every row with a missing salary and send it to me; I'll route it to HR.

### Task 3 — Standardize the customer region field
The `customers.region` column should only ever contain North, South, East, or West. A subset of records still use an older regional naming convention from before our 2022 system migration. Use the mapping below — this is the officially approved mapping, not a guess:

| Value found in data | Standardize to |
|---|---|
| Northeast | East |
| Southeast | South |
| Midwest | North |

*Add these as new standardized values in a column called `region_clean`, and keep the original `region` value untouched in case we need to audit the change later.*

### Task 4 — Standardize customer phone numbers
`customers.phone` currently has at least five different formats in use (with dashes, dots, spaces, parentheses, a leading +1, or no separators at all). Standardize every value to the format `(XXX) XXX-XXXX`.

### Task 5 — Flag duplicate customer emails
A small number of `customer_id` records share the same email address. This usually means the same contact was entered twice under two different customer accounts. Produce a report of every duplicated email and the `customer_id` records that share it — don't merge or delete anything yourself, just flag it for the Customer Data team to review.

### Task 6 — Standardize order dates
`orders.order_date` is stored as text and most values are in ISO format (`YYYY-MM-DD`), but a subset were entered as long-form dates (e.g. "March 3, 2024") or slash-separated dates that don't specify month vs. day order. Convert every value to a consistent `YYYY-MM-DD` format. Where a slash-separated date is genuinely ambiguous, use the `order_id` sequence (orders are numbered in the order they were placed) to infer the correct chronological date, and note any row where you had to do this.

### Task 7 — Validate product references in order line items
`order_items.product_id` is supposed to match a `product_id` in the products table. A small number don't. Identify these rows, flag them, and report the total dollar value affected (`quantity × unit_price`) so Finance understands the exposure.

### Task 8 — Flag negative quantities
A handful of `order_items.quantity` values are negative. These are data entry errors, not legitimate returns (returns go through a separate credit-memo process you'll learn about later). Flag these rows for correction — do not simply convert them to positive numbers, since we don't yet know whether the sign or the quantity itself was the mistake.

### Task 9 — Build a one-page Power BI summary
Once the above is cleaned, connect Power BI to your cleaned tables and build a single-page dashboard showing: total revenue by region (using `region_clean`), order volume and fulfillment status by distribution center, and top 10 products by revenue. This will be your first deliverable to the regional VPs, so keep it clean and legible.

---

*Target completion: two weeks from today. Send me your working file (not just a summary) as you go — I'd rather course-correct early than review a finished product that went the wrong direction. Welcome aboard.*

— Denise
