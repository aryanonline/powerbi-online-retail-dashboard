// Dimension: one row per stock code, with a readable name and all-time net revenue (used for the Pareto curve).
let
    Lines = Table.Buffer(Table.SelectColumns(#"Clean Lines", {"StockCode", "Description", "Line Type", "Line Amount"})),
    // A stock code can carry several descriptions. Use the most common one from real sales or service lines,
    // ignoring stock notes such as "damaged" that appear on zero-price adjustments.
    NamedLines = Table.SelectRows(
        Lines,
        each [Description] <> null and ([Line Type] = "Sale" or [Line Type] = "Non-product")
    ),
    DescriptionCounts = Table.Group(
        NamedLines,
        {"StockCode", "Description"},
        {{"Rows", each Table.RowCount(_), Int64.Type}}
    ),
    BestDescription = Table.Group(
        DescriptionCounts,
        {"StockCode"},
        {{"Description", each Table.Max(_, "Rows")[Description], type text}}
    ),
    // Net of cancellations, so an order that was placed and cancelled the same day adds nothing.
    LifetimeRevenue = Table.Group(
        Table.SelectRows(Lines, each [Line Type] = "Sale" or [Line Type] = "Return"),
        {"StockCode"},
        {{"Lifetime Revenue", each List.Sum([Line Amount]), type number}}
    ),
    AllCodes = Table.Distinct(Table.SelectColumns(Lines, {"StockCode"})),
    WithDescription = Table.ExpandTableColumn(
        Table.NestedJoin(AllCodes, {"StockCode"}, BestDescription, {"StockCode"}, "D", JoinKind.LeftOuter),
        "D",
        {"Description"}
    ),
    WithRevenue = Table.ExpandTableColumn(
        Table.NestedJoin(WithDescription, {"StockCode"}, LifetimeRevenue, {"StockCode"}, "R", JoinKind.LeftOuter),
        "R",
        {"Lifetime Revenue"}
    ),
    AddedProduct = Table.AddColumn(
        WithRevenue,
        "Product",
        each if [Description] = null then "Unnamed item " & [StockCode] else Text.Proper([Description]),
        type text
    ),
    AddedIsProduct = Table.AddColumn(AddedProduct, "Is Product", each fnIsProductCode([StockCode]), type logical),
    Final = Table.TransformColumnTypes(
        Table.SelectColumns(AddedIsProduct, {"StockCode", "Product", "Is Product", "Lifetime Revenue"}),
        {{"StockCode", type text}, {"Product", type text}, {"Is Product", type logical}, {"Lifetime Revenue", type number}}
    )
in
    Final
