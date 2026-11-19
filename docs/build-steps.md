# Build steps

About two evenings in total. Work on your personal laptop only.

## Before you start

- Power BI Desktop (free, Microsoft Store)
- Python from Anaconda (pandas and openpyxl are included)
- This repo cloned to a folder such as `C:\Users\<you>\Projects\powerbi-online-retail-dashboard`

## 1. Get the data (10 minutes)

1. Download **Online Retail II** from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) and unzip `online_retail_II.xlsx` into a data folder outside the repo.
2. Convert it to CSV, which makes every refresh much faster:

   ```
   python prep/convert_to_csv.py "<data folder>\online_retail_II.xlsx" "<data folder>\online_retail_II.csv"
   ```

   It should report 525,461 rows for 2009-2010 and 541,910 for 2010-2011.

## 2. Turn on project saving (2 minutes)

File > Options and settings > Options > Preview features. Tick **Power BI Project (.pbip) save option** and **Store semantic model using TMDL format** if they are listed, then restart Desktop. Newer versions have both on already.

## 3. Load the queries (15 minutes)

Home > Transform data opens Power Query.

1. Manage parameters > New. Name `DataFolder`, type Text, current value = the folder that holds `online_retail_II.csv`, for example `C:\Users\<you>\Projects\data\` (keep the trailing backslash).
2. For each file in `powerquery/`, in number order from 01: New source > Blank query > Advanced editor > paste the file > Done. Rename the query to the file name without the number: `fnIsProductCode`, `Raw Lines`, `Clean Lines`, `Invoice Lines`, `Product`, `Customer`, `Country`, `Load Summary`.
3. Right-click `Raw Lines` and `Clean Lines` and untick **Enable load**. They are staging steps, not tables.
4. Close & apply. The first load takes a few minutes.

## 4. Add the DAX tables (5 minutes)

1. Modeling > New table. Paste `Date` from `dax/tables.dax`, then do the same for `Month Offset`.
2. Select the Date table > Table tools > Mark as date table, using the Date column.
3. Select `Date[Month Start]` > Column tools > Format > custom `mmm yyyy`.

## 5. Relationships (5 minutes)

In Model view, keep exactly these four, each one-to-many and single direction. Delete anything else Desktop created on its own.

| From (one side) | To (many side) |
| --- | --- |
| Date[Date] | Invoice Lines[Date] |
| Product[StockCode] | Invoice Lines[StockCode] |
| Customer[Customer Key] | Invoice Lines[Customer Key] |
| Country[Country] | Invoice Lines[Country] |

`Month Offset` and `Load Summary` stay unconnected.

## 6. Measures (2 minutes)

TMDL view > open a new tab > paste all of `dax/measures.tmdl` > Apply. This adds 33 measures in five folders to Invoice Lines, and the two Pareto columns to Product. If Desktop shows an error, send Claude the message.

## 7. Tidy the model (5 minutes)

- `Customer[Segment]` > Sort by column > `Segment Order`
- `Load Summary[Step]` > Sort by column > `Step Order`
- Hide from report view: in Invoice Lines, `StockCode`, `Customer Key`, `Country`, `Date`, `Quantity`, `Price` and `Line Amount`. Also hide `Customer[Segment Order]` and `Load Summary[Step Order]`. Visuals should use measures, not raw columns.

## 8. Theme (1 minute)

View > Themes > Browse for themes > `theme/portfolio-theme.json`.

## 9. Build the pages

Follow `docs/layout-spec.md`.

## 10. Check your numbers

These come from running the same rules over the data in Python. If a figure in the report differs, a step above went wrong.

| Where | Expected |
| --- | --- |
| Load Summary | 1,067,371 rows in the file, 34,335 duplicates removed, 1,033,036 kept |
| Rows by Line Type | Sale 1,003,338; Return 17,914; Zero price 5,961; Non-product 5,823 |
| All years | Revenue £18,927,421; Gross Sales £19,643,847; Returns Value £716,426 |
| Year 2011 selected | Revenue £9,013,228, +2.7% vs £8,778,902; Orders 18,223, −3.6%; Average Order Value £494.61, +6.5%; Active Customers 4,214, +1.0% |
| Customers | 5,942 customers; Repeat Customer Rate 72.4%; 1,395 Champions |
| Cohorts | Dec 2009 cohort 951 customers; Jan 2010 cohort retention after 1 month 21.5% |
| Products | 4,723 products sold; 1,037 make 80% of revenue (22.0%) |
| Guest Revenue Share | 13.6% |

## 11. Save and share

1. File > Save as > Power BI project (.pbip), into the repo folder, named `OnlineRetail`.
2. Take one screenshot per page (Win + Shift + S) into `screenshots/` and send them to Claude for review.
3. Commit and push.
