// Dimension: one row per customer, with first and last purchase, orders, cohort month
// and an RFM segment. Recency is scored in quintiles; frequency uses plain order-count bands.
let
    CustomerLines = Table.Buffer(
        Table.SelectColumns(
            Table.SelectRows(#"Clean Lines", each [Customer Key] <> -1),
            {"Customer Key", "Invoice", "Date", "Line Type", "Country"}
        )
    ),
    SaleLines = Table.SelectRows(CustomerLines, each [Line Type] = "Sale"),
    EndDate = List.Max(SaleLines[Date]),
    AllCustomers = Table.Group(
        CustomerLines,
        {"Customer Key"},
        {
            {
                "Main Country",
                each Table.Max(Table.Group(_, {"Country"}, {{"Rows", Table.RowCount, Int64.Type}}), "Rows")[Country],
                type text
            }
        }
    ),
    PerBuyer = Table.Group(
        SaleLines,
        {"Customer Key"},
        {
            {"First Purchase", each List.Min([Date]), type date},
            {"Last Purchase", each List.Max([Date]), type date},
            {"Orders", each List.Count(List.Distinct([Invoice])), Int64.Type}
        }
    ),
    Joined = Table.ExpandTableColumn(
        Table.NestedJoin(AllCustomers, {"Customer Key"}, PerBuyer, {"Customer Key"}, "B", JoinKind.LeftOuter),
        "B",
        {"First Purchase", "Last Purchase", "Orders"}
    ),
    AddedRecency = Table.AddColumn(
        Joined,
        "Recency Days",
        each if [Last Purchase] = null then null else Duration.Days(EndDate - [Last Purchase]),
        type nullable number
    ),

    // Recency quintiles: rank buyers from most to least recent; ties share the better score.
    Buyers = Table.SelectRows(AddedRecency, each [Last Purchase] <> null),
    BuyerCount = Table.RowCount(Buyers),
    IndexedBuyers = Table.AddIndexColumn(
        Table.Sort(Buyers, {{"Recency Days", Order.Ascending}}),
        "Row", 0, 1, Int64.Type
    ),
    FirstRowPerRecency = Table.Group(
        IndexedBuyers,
        {"Recency Days"},
        {{"First Row", each List.Min([Row]), Int64.Type}}
    ),
    WithFirstRow = Table.ExpandTableColumn(
        Table.NestedJoin(IndexedBuyers, {"Recency Days"}, FirstRowPerRecency, {"Recency Days"}, "F", JoinKind.LeftOuter),
        "F",
        {"First Row"}
    ),
    AddedRScore = Table.AddColumn(
        WithFirstRow,
        "R Score",
        each 5 - Number.IntegerDivide([First Row] * 5, BuyerCount),
        Int64.Type
    ),
    AddedFScore = Table.AddColumn(
        AddedRScore,
        "F Score",
        each
            if [Orders] >= 10 then 5
            else if [Orders] >= 5 then 4
            else if [Orders] >= 3 then 3
            else if [Orders] = 2 then 2
            else 1,
        Int64.Type
    ),
    AddedSegment = Table.AddColumn(
        AddedFScore,
        "Segment",
        each
            if [R Score] >= 4 and [F Score] >= 4 then "Champions"
            else if [R Score] >= 3 and [F Score] >= 3 then "Loyal"
            else if [R Score] >= 4 then "New or promising"
            else if [R Score] = 3 then "Needs attention"
            else if [F Score] >= 3 then "At risk"
            else "Lost",
        type text
    ),
    ScoredBuyers = Table.RemoveColumns(AddedSegment, {"Row", "First Row"}),

    NonBuyers = Table.AddColumn(
        Table.SelectRows(AddedRecency, each [Last Purchase] = null),
        "Segment",
        each "No purchases",
        type text
    ),
    Guest = #table(
        type table [#"Customer Key" = Int64.Type, #"Main Country" = text, Segment = text],
        {{-1, "Unknown", "Guest"}}
    ),
    Combined = Table.Combine({ScoredBuyers, NonBuyers, Guest}),
    SegmentOrder = [
        Champions = 1,
        Loyal = 2,
        #"New or promising" = 3,
        #"Needs attention" = 4,
        #"At risk" = 5,
        Lost = 6,
        #"No purchases" = 7,
        Guest = 8
    ],
    AddedSegmentOrder = Table.AddColumn(Combined, "Segment Order", each Record.Field(SegmentOrder, [Segment]), Int64.Type),
    AddedCohortMonth = Table.AddColumn(
        AddedSegmentOrder,
        "Cohort Month",
        each if [First Purchase] = null then null else Date.StartOfMonth([First Purchase]),
        type nullable date
    ),
    Final = Table.TransformColumnTypes(
        AddedCohortMonth,
        {
            {"Customer Key", Int64.Type},
            {"Main Country", type text},
            {"First Purchase", type date},
            {"Last Purchase", type date},
            {"Orders", Int64.Type},
            {"Recency Days", Int64.Type},
            {"R Score", Int64.Type},
            {"F Score", Int64.Type},
            {"Segment", type text},
            {"Segment Order", Int64.Type},
            {"Cohort Month", type date}
        }
    )
in
    Final
