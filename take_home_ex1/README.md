# Take-home Exercise 1 — Visual Analytics on a Motor Insurance Portfolio

Visual analytics study of a Spanish motor insurance portfolio (354,140 policy-years, 2022–2024) to identify and statistically validate drivers of profitability and volatility.

## Deliverables

| File | Format | Purpose |
|---|---|---|
| `presentation.qmd` | Quarto revealjs (15 slides) | Executive summary with speaker notes |
| `report.qmd`       | Quarto HTML | Reproducible technical report |
| `index.qmd`        | Quarto HTML | Landing page linking both |

## Data

Place `motor_insurance.csv` in the `data/` folder. The file is excluded from git (95 MB) — download from the Mendeley Data link in the brief.

```
take_home_ex1/
├── data/
│   └── motor_insurance.csv   ← place here (not tracked in git)
├── presentation.qmd
├── report.qmd
├── index.qmd
└── README.md
```

## Render

```bash
quarto render report.qmd
quarto render presentation.qmd
quarto render index.qmd
```

Or render everything: `quarto render`.

## R packages required

```r
install.packages("pacman")
pacman::p_load(
  tidyverse, scales, lubridate,
  ggridges, ggdist, ggstatsplot, patchwork, ggcorrplot, ggrepel,
  knitr, gt, skimr
)
```

## Analytical highlights

- Portfolio loss ratio deteriorated from **65.6% (2022) → 74.7% (2024)** — +9 pp in 2 years
- **Comp. (basic)** policy line runs at **93.9% LR** — the single largest under-performer
- **Diesel** vehicles run **9 pp** above gasoline
- **Top 5% of policies generate 83% of losses** — extreme concentration
- Semi-annual / quarterly payers run **8–13 pp** above annual payers (adverse selection)
- All differences validated by chi-square (p < 0.001) and Kruskal-Wallis (H = 1,241, p < 10⁻²⁶⁰)
