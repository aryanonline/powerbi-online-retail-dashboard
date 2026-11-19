// Small table for the Data quality page: rows in the file, duplicates removed, rows kept.
let
    SourceRows = Table.RowCount(#"Raw Lines"),
    UniqueRows = Table.RowCount(#"Clean Lines"),
    Summary = #table(
        type table [Step = text, Rows = Int64.Type, #"Step Order" = Int64.Type],
        {
            {"Rows in the source file", SourceRows, 1},
            {"Exact duplicate rows removed", SourceRows - UniqueRows, 2},
            {"Rows kept and labelled", UniqueRows, 3}
        }
    )
in
    Summary
