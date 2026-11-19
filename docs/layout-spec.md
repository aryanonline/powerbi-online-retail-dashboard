# Layout spec

Canvas: 16:9, 1280 x 720. Margins 16 px, gaps 12 px. One accent colour (the theme's first colour). Titles say what the reader should notice, not just what the chart is.

## Page 1: Overview

**Top band (y 16 to 80)**

- Text box: "Online store performance" (20 pt). Under it: "UK online gift retailer, Dec 2009 to Dec 2011. Revenue in GBP, net of cancellations." (11 pt, grey)
- Right side: a Year slicer (dropdown, `Date[Year]`, default **2011**) and a Market slicer (tiles, `Country[Market]`).

**KPI row (y 90 to 190).** Five tiles in one Card (new) visual. Each shows a callout and a reference label "vs last year":

| Callout | Reference label |
| --- | --- |
| Revenue | Revenue YoY % |
| Orders | Orders YoY % |
| Average Order Value | Average Order Value YoY % |
| Active Customers | Active Customers YoY % |
| Return Rate | none |

Colour the YoY labels green when positive and red when negative (conditional formatting, rules).

**Middle left (x 16 to 820, y 200 to 450): line chart.** Title: "Monthly revenue against the same month last year".
- X axis: `Date[Month Start]`. Y axis: Revenue (accent colour) and Revenue PY (grey, dashed).
- Visual filter: `Date[Has Data]` is True.

**Middle right (x 832 to 1264, y 200 to 450): bar chart.** Title: "Top 10 international markets".
- Y axis: `Country[Country Name]`. X axis: Revenue.
- Visual filters: `Country[Market]` is International; Top N 10 by Revenue.

**Bottom left (x 16 to 820, y 462 to 704): bar chart.** Title: "Top 10 products by revenue".
- Y axis: `Product[Product]`. X axis: Revenue. Top N 10 by Revenue. Turn on drill-through to Product detail.

**Bottom right (x 832 to 1264, y 462 to 704): text box "What stands out".** These figures come from the real data, with Year 2011 and both markets selected:
- Revenue grew 2.7% on the same dates last year. A full-year comparison wrongly shows a 1.3% fall, because the 2011 data stops on 9 December.
- Orders fell 3.6%, but the average order rose 6.5% to £495. Growth came from bigger baskets, not more orders.
- November is the peak month, at 2.9 times February's revenue.

## Page 2: Customers

- **Slicers:** Year and Market, synced with the Overview page (View > Sync slicers).
- **KPI row:** Card (new) with Active Customers, New Customers, Returning Customers and Repeat Customer Rate.
- **Stacked column chart, left half.** Title: "New and returning customers each month". X axis: `Date[Month Start]`. Values: New Customers and Returning Customers. Visual filter: `Date[Has Data]` is True. Subtitle: "Dec 2009 counts everyone as new because the data starts there."
- **Matrix, right half.** Title: "About 1 in 5 new customers buys again the next month".
  - Rows: `Customer[Cohort Month]` (format mmm yyyy). Columns: `Month Offset[Offset]`. Values: Retention %.
  - Visual filters: Offset 1 to 12; Cohort Month Dec 2009 to Dec 2010.
  - Conditional formatting: background colour scale, white to accent.
  - Column header label: "Months after first purchase".
  - The matrix ignores the Year slicer by design, because a cohort needs its full history.
- **Table, bottom.** Title: "Champions are 24% of customers and 70% of customer revenue". Subtitle: "RFM segments as of 9 Dec 2011".
  - Columns: `Customer[Segment]`, Customers, Revenue, Customer Revenue Share, Average of `Customer[Orders]`.
  - Visual filter: Segment is not Guest and not No purchases.
  - Format > Edit interactions: turn off both slicers for this table, because the segments and their revenue are all-time.
  - Under it, a small text box: "Recency is scored in quintiles of days since last order. Frequency bands: 1, 2, 3 to 4, 5 to 9, and 10 or more orders."

## Page 3: Products

- **KPI row:** Card (new) with Products Sold, Products Making 80% of Revenue and Share of Products Making 80%.
- **Line chart, left half.** Title: "22% of products make 80% of revenue".
  - X axis: `Product[Revenue Rank]` (continuous). Y axis: Maximum of `Product[Cumulative Revenue Share]`.
  - Add a constant line at 80% (Analytics pane).
  - Subtitle: "All-time, not affected by slicers." Turn off interactions from slicers to this visual (Format > Edit interactions).
- **Table, right half.** Title: "Product league table".
  - Columns: `Product[Product]`, `Product[StockCode]`, Revenue, Units Sold, Orders, Return Rate, Product Revenue Share, Cumulative Revenue %.
  - Sort by Revenue, descending. Data bars on Revenue.

## Page 4: Data quality

Title: "What was wrong with the raw data, and what I did about it"

- **Table:** `Load Summary[Step]`, `Load Summary[Rows]`.
- **Bar chart:** Rows by `Invoice Lines[Line Type]`. Title: "Every line is labelled, nothing is silently dropped".
- **Table:** `Product[Product]`, Rows, Line Amount. Visual filter: `Product[Is Product]` is False. Title: "Postage, fees and adjustments kept out of product revenue".
- **Cards:** Guest Revenue Share ("Revenue from orders with no customer ID") and Returns Value.
- **Callout text box:** "The two largest orders in the data, 80,995 paper craft kits (£168k) and 74,215 storage jars (£77k), were cancelled within 20 minutes. Revenue is reported net of cancellations, so they don't distort the rankings."
- **Text box, the cleaning rules:**
  - Appended the two yearly sheets and removed exact duplicate rows
  - Cancellations (invoice numbers starting with C) became returns
  - Postage (£433k), and bank charges, marketplace fees and manual adjustments (−£507k), were moved out of product sales
  - Zero-price lines and stock write-offs were excluded from revenue
  - Orders without a customer ID count toward revenue but not toward customer metrics
  - December 2011 is partial (data ends on 9 December), so year-on-year figures compare like-for-like dates

## Page 5: Product detail (drill-through, hidden)

- Drill-through field: `Product[Product]`. Keep the back button.
- Card (new): Revenue, Units Sold, Orders, Return Rate.
- Line chart: Revenue by `Date[Month Start]`.
- Bar chart: Revenue by `Country[Country Name]`, Top N 10.
