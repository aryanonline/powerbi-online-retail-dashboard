# Online store sales and customer dashboard (Power BI)

A Power BI report built on real, messy transaction data: about 1.07 million invoice lines from a UK online gift retailer, December 2009 to December 2011.

<!-- Replace with the real screenshot once the report is built -->
![Overview page](screenshots/overview.png)

## What the data shows

- **Like-for-like growth.** 2011 revenue grew 2.7% on the same dates in 2010. A naive full-year comparison shows a 1.3% fall, because the data stops on 9 December 2011.
- **Bigger baskets, fewer orders.** Orders fell 3.6% while the average order rose 6.5% to £495.
- **Seasonality.** November revenue is 2.9 times February's.
- **Concentration.** 24% of customers (the Champions segment) bring 70% of customer revenue, and 22% of products make 80% of revenue.
- **Phantom orders.** The two largest orders, 80,995 paper craft kits (£168k) and 74,215 storage jars (£77k), were cancelled within 20 minutes. Ranking products on gross sales would have put both in the top 10.

## Questions it answers

- How are revenue, orders and average order value moving against last year?
- Which customers come back, and which are slipping away?
- Which products carry the business?
- What was wrong with the raw data, and how much did it matter?

## What I did with the data

Every cleaning rule lives in Power Query (`powerquery/`), so each step can be inspected and repeated on the next export.

- Appended the two yearly sheets and removed 34,335 exact duplicate rows (3.2%)
- Turned cancellations (invoice numbers starting with C) into returns, and report revenue net of them
- Moved postage (£433k) and bank charges, marketplace fees and manual adjustments (−£507k) out of product revenue
- Excluded zero-price lines and stock write-offs from revenue
- Kept orders with no customer ID in revenue as "Guest", but out of customer metrics
- Labelled every line rather than dropping it, so the Data quality page shows what was excluded and why

## Model

A star schema: one Invoice Lines fact table, with Date, Product, Customer and Country dimensions. The source folder is a parameter, so the report can point at a fresh export.

<!-- Add a screenshot of Model view here -->

## Measures worth a look

All 33 measures are in `dax/measures.tmdl`, grouped into folders.

- **Like-for-like year on year.** The data ends on 9 December 2011, so prior-year figures cover only the same dates. A naive comparison would set 9 days of December against a full month and turn +2.7% into −1.3%.
- **Cohort retention.** The share of each month's new customers who buy again 1 to 12 months later.
- **RFM segments.** Customers grouped into Champions, Loyal, New or promising, Needs attention, At risk and Lost.
- **Pareto analysis.** How many products make up 80% of revenue.

## Run it yourself

1. Download [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) and unzip it.
2. Run `python prep/convert_to_csv.py <path to xlsx> <path to csv>`.
3. Open `OnlineRetail.pbip` in Power BI Desktop, set the `DataFolder` parameter to the CSV's folder, and refresh.

Full build steps are in `docs/build-steps.md`.

## Data

Online Retail II by Daqing Chen, from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii), licensed CC BY 4.0. Prices are in pounds sterling.
