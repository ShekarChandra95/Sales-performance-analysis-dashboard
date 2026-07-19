# Sales Performance Analysis Dashboard

End-to-end analytics project built on uploaded sales dataset (9,800 orders, 2015–2018,
Superstore-style: Orders, Customers, Products, Regions). Pipeline: **Excel → SQL → Python → Power BI**.

```
Raw CSV
   → Excel: clean missing values, flag issues, derive Year/Month
   → SQL: load into a relational table, run 12 business queries
   → Python: EDA with Pandas/NumPy/Matplotlib/Seaborn, 9 charts + insights
   → Power BI: interactive dashboard (working HTML preview + build guide for the real .pbix)
```

## Folder Guide

```
data/
  raw_sales_data.csv          Original upload, untouched
  Sales_Data_Cleaning.xlsx    Excel workbook: Raw Data | Cleaning Summary | Cleaned Data
  sales_data_cleaned.csv      final cleaned dataset (used by SQL & Python)

sql/
  business_queries.sql        schema + 12 business queries (MySQL/Postgres syntax)
  sales.db                    SQLite database with the cleaned data loaded, for quick testing

python/
  eda_sales_analysis.py       standalone EDA script (run: python eda_sales_analysis.py)
  EDA_sales_analysis.ipynb    same analysis as an executed Jupyter notebook
  charts/                     9 PNG charts generated from the analysis
  key_insights_summary.csv    headline numbers, exported for reporting

powerbi/
  Sales_Performance_Dashboard.html   interactive dashboard preview (open in any browser)
  PowerBI_Build_Guide.md             DAX measures + page-by-page plan to build the real .pbix
  data_exports/                      pre-aggregated CSVs (region, category, top products, etc.)
```

## 1. Excel — Cleaning

Only issue found: **11 missing Postal Codes**, all for Burlington, VT orders. Verified against
the other Burlington, VT rows in the file and filled with the correct ZIP (05401) using an
`IF(ISBLANK(...))` formula rather than deleting the rows. No duplicate rows were found.

- **Raw Data** — the original 9,800 rows, with missing cells highlighted in yellow
- **Cleaning Summary** — `COUNTBLANK()` formulas across every column + duplicate check
- **Cleaned Data** — formula-driven copy of Raw Data with Postal Code fixed, plus derived
  `Order Year`, `Order Month`, `Order Month Name` columns (via `YEAR()`/`MONTH()`/`TEXT()`)

Every formula in the workbook recalculates live — change a cell in Raw Data and the Cleaning
Summary counts and Cleaned Data values update automatically.

## 2. SQL — Business Queries (tested, real results)

12 queries covering: yearly revenue & orders, YoY growth, monthly trend, regional performance,
state-level performance, category/sub-category breakdown, top products, segment analysis, top
customers, ship-mode/fulfilment time, repeat vs one-time customers, and high-value order outliers.

Sample results (from `sales.db`):
| Region | Total Sales | Orders |
|---|---|---|
| West | $710,219.68 | 1,587 |
| East | $669,518.73 | 1,369 |
| Central | $492,646.91 | 1,156 |
| South | $389,151.46 | 810 |

## 3. Python — EDA Highlights

- **Total revenue (2015–2018): $2,261,536.78**
- **2018 was the best year** ($722,052.02), up **20.3% YoY** after a dip in 2016 (‑4.3%)
- **Technology** is the top category ($827,455.87), led by **Phones** ($327,782.45)
- **West region** leads sales; **Consumer segment** drives ~51% of revenue
- Best-selling single product: **Canon imageCLASS 2200 Advanced Copier**
- **98.4% of customers are repeat buyers** (793 unique customers, 4,922 unique orders)
- **11.7% of orders are statistical outliers** (IQR method) — mostly large B2B-style purchases,
  worth modeling separately from typical basket sizes
- **Same Day** shipping is fastest, as expected; see `charts/08_shipping_time_by_mode.png`

Full charts are in `python/charts/`; the notebook has all outputs embedded.

## 4. Power BI — Dashboard

Open `powerbi/Sales_Performance_Dashboard.html` in any browser — it's a fully interactive
preview (Year / Region / Category filters, KPI cards, trend line, regional bar chart, category
breakdown, segment donut, top states, and two data tables), built on the real query results
above. Use `PowerBI_Build_Guide.md` to recreate the same report natively in Power BI Desktop,
including the DAX measures and a 5-page report plan (Executive Overview, Regional, Product,
Customer, Fulfilment).

## Suggested resume/README bullet
> Built an end-to-end Sales Performance Analysis Dashboard on a 9,800-row, 4-year retail sales
> dataset — cleaned data in Excel, wrote 12 SQL business queries, performed EDA in Python
> (Pandas/NumPy/Seaborn), and designed an interactive Power BI-style dashboard, surfacing a 20%
> YoY sales rebound in 2018, a 98% customer repeat rate, and Technology as the leading category.
