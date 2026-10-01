# Superstore_data_analysis_python_SQL_PowerBI
Data Analytics Portfolio — Python, SQL &amp; Power BI projects featuring data cleaning, analysis, and interactive dashboards including Superstore Sales Dashboard ($2.3M sales analysis).


# 🏬 Superstore Sales & Profitability Analysis

**End-to-end analytics project using Python, MySQL, and Power BI**

> **Business question:** *Where is the store making and losing money, and how do discounts, products, regions, and shipping affect profit?*

![Python](https://img.shields.io/badge/Python-pandas-blue)
![MySQL](https://img.shields.io/badge/SQL-MySQL-orange)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow)

---

## 📑 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Business Problem](#2-business-problem)
3. [Objectives](#3-objectives)
4. [Tech Stack](#4-tech-stack)
5. [Dataset](#5-dataset)
6. [Project Workflow](#6-project-workflow)
7. [Data Cleaning & Preparation (Python)](#7-data-cleaning--preparation-python)
8. [Exploratory Data Analysis (Python)](#8-exploratory-data-analysis-python)
9. [Business Analysis (SQL)](#9-business-analysis-sql)
10. [Dashboard (Power BI)](#10-dashboard-power-bi)
11. [Key Findings](#11-key-findings)
12. [Business Recommendations](#12-business-recommendations)
13. [Limitations & Future Work](#13-limitations--future-work)
14. [Repository Structure](#14-repository-structure)
15. [How to Run This Project](#15-how-to-run-this-project)
16. [Author](#16-author)

---

## 1. Project Overview

Superstore is a retail business selling **Furniture, Office Supplies, and Technology** products to Consumer, Corporate, and Home Office customers across four US regions. Sales are healthy, but profit is thin and some orders lose money.

This project analyzes the Superstore sales data end to end:

1. **Python** cleans the data (including a major duplicate-data problem) and explores it.
2. **MySQL** answers ten business questions on sales, losses, discounts, customers, and delivery.
3. **Power BI** presents the results in an interactive dashboard.
4. This report summarizes the findings and recommendations.

---

## 2. Business Problem

Management wants to know:

- How much are we **selling and earning**, and what is our profit margin?
- **What share of orders loses money**, and which sub-categories, states, and customers cause the losses?
- Do **discounts** protect sales at the cost of profit?
- Which **regions, segments, and ship modes** perform best?
- How do **sales and profit change over time**?

**Core challenge:** find where profit leaks so the business can grow sales without eroding margin.

---

## 3. Objectives

| # | Objective | Deliverable |
|---|-----------|-------------|
| 1 | Clean and validate the raw dataset | Python notebook |
| 2 | Explore sales and profit patterns visually | EDA charts |
| 3 | Answer business questions with SQL | `superstore.sql` |
| 4 | Build an interactive dashboard | `superstore_dashboard.pbix` |
| 5 | Summarize findings and recommend actions | This report |

---

## 4. Tech Stack

| Layer | Tools |
|-------|-------|
| Data cleaning & EDA | Python, pandas, NumPy, matplotlib, seaborn |
| Database | MySQL (via SQLAlchemy + PyMySQL) |
| Visualization | Power BI Desktop |
| Version control | Git & GitHub |

---

## 5. Dataset

**Source file:** `Superstore.csv`
**Raw size:** 1,000,000 rows × 21 columns
**Clean size:** **9,993 rows × 21 columns** (see §7)
**Period:** 2011–2014 · **Country:** United States

| Column | Description |
|--------|-------------|
| `row_id` | Row number |
| `order_id`, `order_date`, `ship_date`, `ship_mode` | Order and shipping details |
| `customer_id`, `customer_name`, `segment` | Customer details (Consumer / Corporate / Home Office) |
| `country`, `city`, `state`, `postal_code`, `region` | Location (Central / East / South / West) |
| `product_id`, `category`, `sub_category`, `product_name` | Product hierarchy |
| `sales` | Sales amount (USD) |
| `quantity` | Units sold |
| `discount` | Discount rate (0 to 0.8) |
| `profit` | Profit (USD, can be negative) |

### Summary statistics (clean data)

| Metric | Value |
|--------|-------|
| Rows | 9,993 |
| Average sales per row | $229.85 |
| Average quantity | 3.79 |
| Average discount | 15.6% |
| Profit range | −$6,599.98 to +$8,399.98 |
| Missing values | 0 |

---

## 6. Project Workflow

```
Superstore.csv (1,000,000 rows)
        │
        ▼
┌─────────────────────────────┐
│ 1. Python: clean            │  Remove 990K duplicate rows → 9,993 rows
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ 2. Python: EDA              │  Sales, profit, discount, trend charts
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ 3. MySQL                    │  Load → 10 business questions
└──────────────┬──────────────┘
               ▼
┌─────────────────────────────┐
│ 4. Power BI                 │  KPIs + interactive dashboard
└─────────────────────────────┘
```

---

## 7. Data Cleaning & Preparation (Python)

Notebook: `super_store_project.ipynb`

### 7.1 The key data-quality problem: inflated duplicates

The raw file contained **1,000,000 rows**, far more than a normal Superstore dataset. Investigation showed:

| Check | Result |
|-------|--------|
| Exact duplicate rows (including `Row ID`) | 0, which looked clean at first |
| Duplicate rows **excluding `Row ID`** | **990,007** |
| Largest order | 1,421 line items for one order ID (not realistic) |

The `Row ID` column was hiding the problem: each record had been copied many times with a new row number. Comparing the first block of rows with a later block confirmed they were identical copies.

**Fix:**
```python
cols = [c for c in data.columns if c != 'Row ID']
data = data.drop_duplicates(subset=cols, keep='first')
data = data.head(9994)
data['Row ID'] = range(1, len(data) + 1)
```

**Result:** **9,993 unique rows** (one row fewer than the standard 9,994 because one true duplicate was removed). After cleaning, the largest order has 14 line items, which is realistic.

> 💡 **Lesson:** always check for duplicates *excluding ID columns*. A unique row ID can hide fully duplicated records.

### 7.2 Other cleaning steps

| Step | Action |
|------|--------|
| Dates | Converted `Order Date` and `Ship Date` to `datetime` |
| Missing values | Checked all 21 columns: none missing |
| Column names | Converted to lowercase `snake_case` (e.g., `Sub-Category` → `sub_category`) |
| Index | Reset and re-numbered `row_id` from 1 to 9,993 |
| Outliers | Reviewed `sales` with a boxplot; large values were kept as genuine big orders |
| Export | Saved as `superstore_clean_final.csv` and loaded into MySQL |

### 7.3 Loading into MySQL

```python
from sqlalchemy import create_engine
engine = create_engine("mysql+pymysql://<user>:<password>@localhost:3306/superstore")
data.to_sql("superstore_clean_final", con=engine, if_exists="replace", index=False)
```

> 🔒 Keep database credentials out of the repository. Use environment variables or a `.env` file listed in `.gitignore`.

---

## 8. Exploratory Data Analysis (Python)

Quick aggregations and charts were used to understand the data before writing SQL.

### Headline numbers

| Metric | Value |
|--------|-------|
| **Total sales** | **$2,296,919.49** |
| **Total profit** | **$286,409.08** |
| **Profit margin** | **12.47%** |

### Sales by category

| Category | Sales |
|----------|-------|
| Technology | $836,154 |
| Furniture | $741,718 |
| Office Supplies | $719,047 |

### Sales by region

| Region | Sales |
|--------|-------|
| West | $725,458 |
| East | $678,500 |
| Central | $501,240 |
| South | $391,722 |

### Sales by segment

| Segment | Sales |
|---------|-------|
| Consumer | $1,161,401 |
| Corporate | $706,146 |
| Home Office | $429,372 |

### Most profitable sub-categories

| Sub-category | Profit |
|--------------|--------|
| Copiers | $55,618 |
| Phones | $44,516 |
| Accessories | $41,937 |
| Paper | $34,054 |
| Binders | $30,222 |
| Chairs | $26,602 |
| Storage | $21,279 |
| Appliances | $18,138 |
| Furnishings | $13,059 |
| Envelopes | $6,964 |

### Top products by sales
1. Canon imageCLASS 2200 Advanced Copier: **$61,600**
2. Fellowes PB500 Electric Punch Plastic Comb Binding Machine: **$27,453**
3. Cisco TelePresence System EX90 Videoconferencing Unit: **$22,638**

### Charts created
Discount vs. profit scatter · sales by category · profit and sales by region · profit by sub-category · top 10 states by sales · monthly sales trend · profit by segment · sales share by ship mode.

> 📸 *Add your best 2 or 3 chart screenshots here, e.g.:* `![Discount vs Profit](images/discount_vs_profit.png)`

---

## 9. Business Analysis (SQL)

Script: `superstore.sql` · Table: `superstore_clean_final`

| # | Business question | SQL techniques |
|---|-------------------|----------------|
| 1 | Total sales, total profit, and number of orders | `SUM`, `ROUND`, `COUNT` |
| 2 | What percentage of orders run at a **loss**? | `CASE WHEN` inside `SUM` |
| 3 | Which **5 sub-categories** cause the highest total loss? | `WHERE`, `GROUP BY`, `ORDER BY`, `LIMIT` |
| 4 | Which **10 states** are the most loss-making? | Same pattern at state level |
| 5 | How does **average profit change by discount level**? | `CASE WHEN` bucketing (0%, 0–20%, 20–50%, 50%+) |
| 6 | **Year-wise profit trend** (2011–2014) with growth % | CTE + `LAG()` window function |
| 7 | **Top 5 most profitable** and **top 5 loss-causing** customers | `GROUP BY`, `ORDER BY` asc/desc |
| 8 | Which **ship mode** has the longest average delivery time? | `DATEDIFF`, date quality check |
| 9 | Which products sold at **>30% discount still lose money**? | Multi-condition `WHERE` |
| 10 | Which **region** has the highest **profit margin %**? | Ratio of sums |

### Sample queries

**Discount level vs. profit**
```sql
SELECT
  CASE
    WHEN discount = 0    THEN '0% No Discount'
    WHEN discount <= 0.2 THEN '0-20% Low'
    WHEN discount <= 0.5 THEN '20-50% Medium'
    ELSE '50%+ High Discount'
  END AS discount_level,
  COUNT(*)              AS total_orders,
  ROUND(AVG(profit), 2) AS avg_profit,
  ROUND(SUM(profit), 2) AS total_profit
FROM superstore_clean_final
GROUP BY discount_level
ORDER BY AVG(profit) DESC;
```

**Year-over-year profit growth**
```sql
WITH yearly_profit AS (
  SELECT YEAR(order_date) AS year, ROUND(SUM(profit), 2) AS total_profit
  FROM superstore_clean_final
  GROUP BY YEAR(order_date)
)
SELECT year, total_profit,
       LAG(total_profit) OVER (ORDER BY year) AS prev_year_profit,
       ROUND((total_profit - LAG(total_profit) OVER (ORDER BY year))
             / LAG(total_profit) OVER (ORDER BY year) * 100, 2) AS growth_percent
FROM yearly_profit
ORDER BY year;
```

**Region profit margin**
```sql
SELECT region,
       ROUND(100 * SUM(profit) / SUM(sales), 2) AS profit_margin_percentage
FROM superstore_clean_final
GROUP BY region
ORDER BY profit_margin_percentage DESC;
```

> ✅ Query 8 includes a data-quality check (`ship_date < order_date`) and filters out any invalid rows before calculating delivery time.
> ℹ️ "Orders" in Q1–Q2 count **rows** (order line items), not unique order IDs.

---

## 10. Dashboard (Power BI)

File: `superstore_dashboard.pbix` · **"Superstore Sales Dashboard"** (single page, 2560×1440)

### 10.1 KPI cards
**Total Orders · Total Sales · Total Profit · Profit Margin % · Avg Delivery Days · Loss %**

### 10.2 Visuals

| Visual | Type | Insight |
|--------|------|---------|
| Profit by segment | Pie chart | Which customer segment earns the most profit |
| Sales by ship mode | Funnel | Share of sales by Standard, Second, First Class, Same Day |
| Profit by month | Stacked area chart | Profit trend and seasonality |
| Sales by month | Line chart | Sales trend over time |
| Profit and discount by sub-category | Combo (column + line) | Where high discounts coincide with low or negative profit |

### 10.3 Filters (slicers)
**Year** · **Region** · **Product name** · **City** · **State**, all cross-filtering every visual and KPI.

### 10.4 Dashboard preview

> <img width="1183" height="673" alt="image" src="https://github.com/user-attachments/assets/ae0548ca-5df4-47b1-8fcb-b006805d28eb" />


---

## 11. Key Findings
>.

### 11.1 Overall performance
- The business generated **\$2.30M in sales** and **\$286K in profit**, a **12.47% margin**.
- Technology is the top category by sales (**\$836K**), followed closely by Furniture and Office Supplies.
- **West** (\$725K) and **East** (\$679K) lead sales; **South** is the smallest (\$392K).
- **Consumer** customers account for about half of all sales (\$1.16M).

### 11.2 Profit drivers
- **Copiers, Phones, and Accessories** are the biggest profit contributors, while Paper and Binders add steady profit.
- Some sub-categories lose money. The EDA chart flags **Tables and Bookcases** as loss-making. *(confirm with SQL Q3)*

### 11.3 Losses (SQL Q2–Q4, Q9)

| Question | Result |
|----------|--------|
| Share of orders making a loss | **[18.71]%** ([1870] of 9,993 rows) |
| Top 5 loss-making sub-categories | **[Binders, Tables, Machines, Bookcases, Chairs]** |
| Top 10 loss-making states | **[Texas, Ohio, Pennsylvania, Illinois, North Carolina, Colorado, Florida, Tennessee, Arizona, New York]** |
| Products with >30% discount that still lost money | **[Cubify CubeX 3D Printer Double Head Print, Cubify CubeX 3D Printer Triple Head Print, GBC DocuBind P400 Electric Binding System, Lexmark MX611dhe Monochrome Laser Printer, Ibico EPK-21 Electric Binding System,.....] …** |

### 11.4 Discount impact (SQL Q5)

| Discount level | Orders | Avg profit | Total profit |
|----------------|--------|-----------|--------------|
| No discount | [4798] | \$[66.9] | \$[320987.6] |
| 0–20% | [3803] | \$[26.5] | \$[100785.47] |
| 20–50% | [536] | \$[-109.71] | \$[-58804.95] |
| 50%+ | [856] | \$[89.44] | \$[-76559.05] |

*State the pattern, e.g., "Average profit turns negative above [X]% discount."*

### 11.5 Time, customers, and delivery

| Question | Result |
|----------|--------|
| Profit by year (2011 → 2014) | \$[49556.03] → \$[61618.6] → \$[81726.93] → \$[93507.51]; growth **[24.34]%**, **[32.63]%**, **[14.41]%** |
| Top 5 profitable customers | **[Tamara Chand, Raymond Buch, Sanjit Chand, Hunter Lopez, Adrian Barton]** |
| Top 5 loss-causing customers | **[Cindy Stewart, Grant Thornton, Luke Foster, Sharelle Roach, Henry Goldwyn]** |
| Slowest ship mode | **[Standard class]**, **[52]** days on average |
| Highest-margin region | **[West]** at **[11.94]%** |
| Monthly sales pattern | Peaks in **November–December** (from the monthly trend chart) |

---

## 12. Business Recommendations

| # | Area | Recommendation | Evidence |
|---|------|----------------|----------|
| 1 | **Discount policy** | Cap discounts at the level where average profit turns negative; require approval for discounts above that level. | SQL Q5, Q9 |
| 2 | **Loss-making products** | Review pricing, supplier cost, or discontinue persistent loss-making sub-categories such as Tables and Bookcases. | SQL Q3, EDA |
| 3 | **Regional focus** | Fix low-margin regions and states before pushing more sales there; replicate what works in the highest-margin region. | SQL Q4, Q10 |
| 4 | **Protect profit makers** | Keep stock and promotion focus on Copiers, Phones, and Accessories, the top profit drivers. | EDA |
| 5 | **Customer management** | Reward top profitable customers; review pricing and discount terms for repeat loss-making ones. | SQL Q7 |
| 6 | **Seasonal planning** | Prepare inventory and logistics ahead of the November–December sales peak. | Monthly trend |
| 7 | **Shipping** | Investigate slow ship modes to improve delivery times and customer satisfaction. | SQL Q8 |

---

## 13. Limitations & Future Work

**Limitations**
- Data covers **2011–2014** only and may not reflect current conditions.
- "Orders" are counted as **rows (line items)**, not unique order IDs.
- No **cost, returns, or customer-satisfaction** data, so profit drivers are inferred from sales, discount, and profit only.
- Findings show association, not causation. A loss on a discounted order may also reflect high product cost.

**Future work**
- Count **unique orders** and calculate average order value.
- Build a **profit prediction model** or flag likely loss-making orders.
- Add **RFM customer segmentation** and customer lifetime value.
- Add a second dashboard page for loss analysis (state map, discount bands).
- Forecast monthly sales for inventory planning.

---

## 14. Repository Structure

```
superstore-sales-analysis/
│
├── data/
│   └── superstore_clean_final.csv
│
├── python/
│   └── super_store_project.ipynb
│
├── sql/
│   └── superstore.sql
│
├── dashboard/
│   ├── superstore_dashboard.pbix
│   └── dashboard_preview.png
│
├── images/                     # EDA chart screenshots
│
├── .gitignore
└── README.md
```

*(Adjust to match your actual folders.)*

---

## 15. How to Run This Project

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
   ```
2. **Install dependencies**
   ```bash
   pip install pandas numpy matplotlib seaborn sqlalchemy pymysql jupyter
   ```
3. **Clean the data:** run `python/super_store_project.ipynb` (update the CSV path first).
4. **Load into MySQL:** create the database (`CREATE DATABASE superstore;`), set your connection details through environment variables, and run the notebook's last cell.
5. **Run the analysis:** open `sql/superstore.sql` in MySQL Workbench and execute the queries.
6. **View the dashboard:** open `dashboard/superstore_dashboard.pbix` in Power BI Desktop and refresh the data source.

---
