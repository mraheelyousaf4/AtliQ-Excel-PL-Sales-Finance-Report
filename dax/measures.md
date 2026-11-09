# DAX Measures and Calculated Columns

All measures live in the Power Pivot data model of `p_and_l_add_quarters.xlsx` (Power Pivot > Manage > Calculation Area).

> **How this file was made:** the measure names and their logic were read from the workbook's data model. The model stores formulas in a compressed form, so the syntax below is reconstructed from the readable fragments and checked against the report outputs (for example, India's Gap % of -5.6% and every Status label match). Before quoting any formula in an interview, open Power Pivot and compare it with your own.

[Back to README](../README.md)

---

## Base measures (finance)

| Measure | DAX | Purpose |
|---|---|---|
| `NetSales` | `= SUM ( fact_sales_monthly_with_cost[net_sales_amount] )` | Revenue after all discounts |
| `COGS` | `= SUM ( fact_sales_monthly_with_cost[total_cogs] )` | Cost of goods sold |
| `Gross Margin` | `= [NetSales] - [COGS]` | Profit before operating costs |
| `GM %` | `= DIVIDE ( [Gross Margin], [NetSales], 0 )` | Gross margin as a share of net sales |

## Year measures (sales reports)

```DAX
2019 = CALCULATE ( [NetSales], dim_date[FY] = "2019" )
2020 = CALCULATE ( [NetSales], dim_date[FY] = "2020" )
2021 = CALCULATE ( [NetSales], dim_date[FY] = "2021" )
```

`FY` is stored as text in `dim_date`, which is why the filter compares to `"2021"` in quotes.

## Target measures (Market Performance vs Target)

```DAX
Target_21   = SUM ( ns_targets_2021[ns_target] )

2021-Target = [2021] - [Target_21]

Gap %       = DIVIDE ( [2021-Target], [Target_21], 0 )

Rank =
IF (
    NOT ISBLANK ( [2021] ),
    RANKX ( ALLSELECTED ( dim_market[market] ), [2021], , DESC, SKIP )
)

Status =
VAR g = [Gap %]
RETURN
    SWITCH (
        TRUE (),
        g < -0.12, "Far off",
        g < -0.08, "Behind",
        "Close"
    )
```

| Status | Rule | Markets in FY2021 |
|---|---|:-:|
| Close | within 8% of target | 6 |
| Behind | 8% to 12% short | 14 |
| Far off | more than 12% short | 3 |

## Calculated columns

| Table | Column | What it does |
|---|---|---|
| `fact_sales_monthly_with_cost` | `total_cogs` | Combines freight cost and manufacturing cost into one cost per row |
| `fact_sales_monthly_with_cost` | `customer name`, `FY` | Lookups that bring the customer name and fiscal year onto the fact table |
| `dim_date` | `mmm` | Month name (Sep, Oct, ...) for report columns |
| `dim_date` | `fy_month_no` | Fiscal month number (Sep = 1), used to sort months in fiscal order |
| `dim_date` | `quarter` | Fiscal quarter (Q1 = Sep to Nov, Q2 = Dec to Feb, Q3 = Mar to May, Q4 = Jun to Aug) |

## Worksheet formulas next to the pivots

| Report | Formula | Note |
|---|---|---|
| P&L by Fiscal Year, `21 vs 20` | `=IFERROR(E10/D10-1,"")` | Growth %: 204.5% means FY2021 is 3.05 times FY2020 |
| Customer report, `21 vs 20` | `=IFERROR(E901/D901,"")` | Ratio, not growth: 304.5% means the same 3.05 times. See the review notes in the walkthrough |
