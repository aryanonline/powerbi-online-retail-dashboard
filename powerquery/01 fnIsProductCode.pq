// True for real product stock codes: five digits plus an optional letter suffix (85123A),
// or the DCGS gift-shop codes. False for postage, fees, discounts, manual adjustments,
// bank charges, samples and test codes (POST, DOT, M, D, C2, AMAZONFEE, BANK CHARGES, ...).
(code as nullable text) as logical =>
    code <> null
        and (
            (Text.Length(code) >= 5 and Text.Length(Text.Select(Text.Start(code, 5), {"0".."9"})) = 5)
            or Text.StartsWith(code, "DCGS")
        )
