"""Convert the UCI Online Retail II workbook into one CSV file for a faster Power BI refresh.

No cleaning happens here. Every cleaning rule lives in Power Query, where a client can see it.
The script only appends the two yearly sheets and writes them out unchanged.

Usage (from the repository folder):
    python prep/convert_to_csv.py "C:/path/to/online_retail_II.xlsx" "C:/path/to/data/online_retail_II.csv"
"""

import sys
import time
from pathlib import Path

import pandas as pd

EXPECTED_COLUMNS = [
    "Invoice",
    "StockCode",
    "Description",
    "Quantity",
    "InvoiceDate",
    "Price",
    "Customer ID",
    "Country",
]


def convert(source: Path, target: Path) -> None:
    started = time.time()
    print(f"Reading {source} (about 2 to 4 minutes for the full workbook)...")
    sheets = pd.read_excel(
        source,
        sheet_name=None,
        dtype={"Invoice": str, "StockCode": str},
        engine="openpyxl",
    )

    frames = []
    for name, frame in sheets.items():
        missing = [column for column in EXPECTED_COLUMNS if column not in frame.columns]
        if missing:
            sys.exit(f"Sheet '{name}' is missing columns: {missing}")
        print(f"  {name}: {len(frame):,} rows")
        frames.append(frame[EXPECTED_COLUMNS])

    lines = pd.concat(frames, ignore_index=True)

    # Keep values as they are, but write them in formats Power Query reads the same way in any locale.
    lines["Customer ID"] = lines["Customer ID"].astype("Int64")
    lines["InvoiceDate"] = pd.to_datetime(lines["InvoiceDate"]).dt.strftime("%Y-%m-%d %H:%M:%S")

    target.parent.mkdir(parents=True, exist_ok=True)
    lines.to_csv(target, index=False, encoding="utf-8")
    print(f"Wrote {len(lines):,} rows to {target} in {time.time() - started:.0f} seconds")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    convert(Path(sys.argv[1]), Path(sys.argv[2]))
