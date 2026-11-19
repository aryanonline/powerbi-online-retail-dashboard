// Fact table: one row per invoice line, with only the columns the model needs.
let
    Source = #"Clean Lines",
    KeptColumns = Table.SelectColumns(
        Source,
        {"Invoice", "StockCode", "Customer Key", "Country", "Date", "Quantity", "Price", "Line Amount", "Line Type"}
    )
in
    KeptColumns
