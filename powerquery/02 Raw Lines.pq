// Staging query (right-click > untick Enable load): the source file, typed, nothing removed.
let
    Source = Csv.Document(
        File.Contents(DataFolder & "online_retail_II.csv"),
        [Delimiter = ",", Columns = 8, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"Invoice", type text},
            {"StockCode", type text},
            {"Description", type text},
            {"Quantity", Int64.Type},
            {"InvoiceDate", type datetime},
            {"Price", type number},
            {"Customer ID", Int64.Type},
            {"Country", type text}
        },
        "en-US"
    )
in
    Typed
