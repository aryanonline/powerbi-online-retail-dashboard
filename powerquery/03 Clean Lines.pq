// Staging query (untick Enable load): tidy text, drop exact duplicates, and label every line
// instead of deleting it, so the Data quality page can show what was excluded and why.
let
    Source = #"Raw Lines",
    Tidied = Table.TransformColumns(
        Source,
        {
            {"Invoice", each Text.Trim(_), type text},
            {"StockCode", each Text.Upper(Text.Trim(_)), type text},
            {"Description", each if _ = null or Text.Trim(_) = "" then null else Text.Trim(_), type nullable text},
            {"Country", each Text.Trim(_), type text}
        }
    ),
    // Some lines repeat exactly across all eight columns. Identical rows are treated as duplicates.
    RemovedDuplicates = Table.Distinct(Tidied),
    AddedLineType = Table.AddColumn(
        RemovedDuplicates,
        "Line Type",
        each
            if not fnIsProductCode([StockCode]) then "Non-product"
            else if Text.StartsWith([Invoice], "C") then "Return"
            else if [Price] <= 0 then "Zero price"
            else if [Quantity] <= 0 then "Stock adjustment"
            else "Sale",
        type text
    ),
    AddedLineAmount = Table.AddColumn(AddedLineType, "Line Amount", each [Quantity] * [Price], type number),
    AddedDate = Table.AddColumn(AddedLineAmount, "Date", each DateTime.Date([InvoiceDate]), type date),
    // Lines without a customer ID are guest orders: they count toward revenue, not customer metrics.
    AddedCustomerKey = Table.AddColumn(
        AddedDate,
        "Customer Key",
        each if [Customer ID] = null then -1 else [Customer ID],
        Int64.Type
    )
in
    AddedCustomerKey
