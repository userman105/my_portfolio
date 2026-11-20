"""Rebuild web/chronicare/diabetes-insights/data.js from the BRFSS 2015 CSV.

Usage:
    python tools/build_insights_data.py path/to/diabetes_012_health_indicators_BRFSS2015.csv

Each respondent is packed into a 28-bit integer (one field per dashboard
dimension) and identical combinations are collapsed into (packed value, count)
pairs, then base64-encoded. 253,680 rows become ~117k pairs (~0.9 MB).
The dimension order and bit widths must match app.js (it reads them from
the `layout` object written into data.js, so only the labels are shared).
"""
import base64
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd

OUT = Path(__file__).resolve().parent.parent / "web/chronicare/diabetes-insights/data.js"


def main(csv_path: str) -> None:
    df = pd.read_csv(csv_path).astype(int)

    # BRFSS age codes are 5-year bands: 1 = 18-24, 2 = 25-29 ... 13 = 80+.
    age = np.select([df.Age == 1, df.Age <= 3, df.Age <= 5, df.Age <= 7, df.Age <= 9], [0, 1, 2, 3, 4], 5)
    days = lambda s: np.select([s == 0, s <= 10, s <= 20], [0, 1, 2], 3)  # none / 1-10 / 11-20 / 21-30
    bmi = np.select([df.BMI < 18.5, df.BMI < 25, df.BMI < 30], [0, 1, 2], 3)
    comorbidity = df.HighBP + df.HighChol + df.HeartDiseaseorAttack + df.Stroke

    dims = dict(age=age, sex=df.Sex, edu=df.Education - 1, inc=df.Income - 1, st=df.Diabetes_012, bmi=bmi,
                hbp=df.HighBP, hch=df.HighChol, pa=df.PhysActivity, cm=comorbidity, gh=df.GenHlth - 1,
                dw=df.DiffWalk, md=days(df.MentHlth), pd=days(df.PhysHlth))
    bits = dict(age=3, sex=1, edu=3, inc=3, st=2, bmi=2, hbp=1, hch=1, pa=1, cm=3, gh=3, dw=1, md=2, pd=2)

    packed = np.zeros(len(df), dtype=np.uint32)
    shift, layout = 0, {}
    for key, width in bits.items():
        values = np.asarray(dims[key]).astype(np.uint32)
        assert values.max() < 2 ** width, f"{key} does not fit in {width} bits"
        packed |= values << shift
        layout[key] = [shift, width]
        shift += width

    uniq, counts = np.unique(packed, return_counts=True)
    assert counts.max() < 65536 and counts.sum() == len(df)
    blob = uniq.astype("<u4").tobytes() + counts.astype("<u2").tobytes()
    js = f"window.BRFSS_DATA={{n:{len(uniq)},layout:{json.dumps(layout, separators=(',', ':'))},b64:\"{base64.b64encode(blob).decode()}\"}};\n"
    OUT.write_text(js)
    print(f"{len(df):,} rows -> {len(uniq):,} unique combinations, {len(js) // 1024} KB -> {OUT}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
