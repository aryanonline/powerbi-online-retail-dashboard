// Dimension: one row per country as written in the data, with a map-friendly name and a UK / International split.
let
    Countries = Table.Distinct(Table.SelectColumns(#"Clean Lines", {"Country"})),
    AddedCountryName = Table.AddColumn(
        Countries,
        "Country Name",
        each
            if [Country] = "EIRE" then "Ireland"
            else if [Country] = "RSA" then "South Africa"
            else if [Country] = "USA" then "United States"
            else if [Country] = "Korea" then "South Korea"
            else [Country],
        type text
    ),
    AddedMarket = Table.AddColumn(
        AddedCountryName,
        "Market",
        each if [Country] = "United Kingdom" then "UK" else "International",
        type text
    )
in
    AddedMarket
