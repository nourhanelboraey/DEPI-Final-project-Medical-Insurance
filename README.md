# DEPI Final Project — Medical Insurance Analytics

A full data-analytics pipeline built on a 100,000-record medical insurance dataset — from raw CSV to cleaned, modeled data, exploratory analysis, and dashboards — reproduced independently across five tools: **SQL, Python, Excel, Power BI, and Tableau**.

## Team (Team 3)

- Nourhan Adel Zakria Elboraey — Team Leader [https://github.com/nourhanelboraey]
- Taha Mohammed Hussein Ali  [https://github.com/Taha-M-H]
- Radwa Sayed Rashad Mohamed  [https://github.com/RADWa-2024]

## Dataset

- **Source:** [Medical Insurance Cost Prediction — Kaggle](https://www.kaggle.com/datasets/mohankrishnathalla/medical-insurance-cost-prediction?select=medical_insurance.csv)
- **Size:** 100,000 rows, 54+ raw columns (56 after cleaning/feature engineering)
- **Unit of observation:** one insured individual per row

The dataset spans six categories of variables:

| Category | Examples |
|---|---|
| Demographics & Socioeconomic | age, sex, region, income, education, employment_status |
| Lifestyle & Habits | bmi, smoker, alcohol_freq |
| Health & Clinical Indicators | hypertension, diabetes, cardiovascular_disease, hba1c, risk_score |
| Healthcare Utilization & Procedures | visits_last_year, hospitalizations_last_3yrs, proc_surgery_count |
| Insurance & Policy Information | plan_type, network_tier, deductible, provider_quality |
| Medical Costs & Claims | annual_medical_cost, annual_premium, claims_count, total_claims_paid |

Full column-by-column definitions are in [`DOCUMENTS/Medical Insurance Dataset Description.pdf`](./DOCUMENTS).

## Repository Structure

| Folder | Contents |
|---|---|
| `RAW DATA/` | Original, unmodified `medical_insurance.csv` from Kaggle |
| `SQL/` | MySQL scripts: database setup & cleaning, star-schema modeling, business analysis |
| `Python/` | Jupyter notebook covering cleaning, modeling, EDA, and dashboards |
| `EXCEL/` | Power Query cleaning/modeling workbook, cleaned CSV export, dashboard workbook |
| `Power BI/` | `.pbix` report with cleaning, modeling, and a multi-page report |
| `Tableau/` | `.twbx` workbook with the final visualization dashboards |
| `DOCUMENTS/` | Dataset description and team member/role documentation |

## Workflow

```
Raw CSV (Kaggle)
   │
   ▼
Data Cleaning  ──────────────►  done independently in SQL, Python, Excel, and Power BI
   │
   ▼
Star-Schema Modeling ────────►  same 4 tools, same schema
   │
   ▼
Analysis (SQL + Python EDA)
   │
   ▼
Dashboards ───────────────────►  Excel, Power BI, Python, and Tableau
```

## Data Cleaning

Cleaning was performed **independently in every tool that supports it** — SQL, Python, Excel (Power Query), and Power BI (Power Query) — so results could be cross-checked across tools. Tableau was used purely for visualization on top of the already-cleaned dataset, since it isn't built for row-level data cleaning.

The main issues identified and corrected:

1. **Implausible ages.** Rows with `age < 16` or `age >= 95` were flagged as suspicious when other attributes contradicted the reported age (e.g. still employed, very few medications, no chronic conditions, or an active smoker at an extreme age). Flagged rows were corrected — not dropped — using a cascading contextual median:
   - 1st choice: median age within the same group of education, employment status, marital status, alcohol frequency, and smoking status
   - 2nd choice (fallback): median within a 4-factor group (drops smoking status)
   - 3rd choice (fallback): global median across all valid rows
   - The result is always floored at a rule-based minimum plausible age for that record (e.g. a current smoker can't be younger than 16; a retiree can't be younger than 55).
2. **Diabetes / HbA1c inconsistency.** Records marked `diabetes = 1` but with an HbA1c lab value below the 6.5% clinical threshold were corrected to `diabetes = 0`, since the lab result doesn't support the diagnosis.
3. **Procedure mismatch.** Records marked `had_major_procedure = 1` with `proc_surgery_count = 0` were corrected to `had_major_procedure = 0`.
4. **Missing lifestyle data.** Missing `alcohol_freq` values were filled as `"Unknown"` rather than dropped.
5. **Feature engineering** (Excel pass): added `income_log` and `flag_high_cost_no_claims` to support later analysis.

## Data Modeling — Star Schema

The same star schema was rebuilt in SQL, Python, Excel (Power Query), and Power BI:

- **Fact table:** `fact_insurance` — utilization, risk score, costs, premiums, claims, and procedure counts
- **Dimension tables:** `dim_person_info`, `dim_socioeconomic`, `dim_lifestyle`, `dim_chronic`, `dim_clinical`, `dim_policy` (with lookup tables `dim_plan_type` and `dim_network_tier`)

See `SQL/README.md` for the entity diagram.

## Analysis

SQL and Python analysis covered:

- KPIs and customer segmentation (age, gender, urban vs. rural, region)
- Lifestyle analysis (smoking, BMI category, alcohol consumption)
- Clinical risk analysis (blood pressure, diabetes, LDL)
- Chronic disease analysis (cost by condition count, top cost-driving conditions, multi-condition members)
- Policy analysis (plan profitability, network tier claims, deductible impact)
- High-risk member analysis and risk segment distribution
- Utilization analysis (most-used procedures, hospitalization impact)
- Socioeconomic analysis (income vs. risk score, education level)
- Business insights (top customers by cost, loss ratio by plan/risk segment, smoking impact on claims)

The Python notebook additionally covers 30+ exploratory breakdowns, including cost deciles, cumulative cost share, and correlation analysis of every factor against `annual_medical_cost`.

## Dashboards

| Tool | Pages / Dashboards |
|---|---|
| **Excel** | Demographics, Customers, Risk Analysis, plus a Data Model view |
| **Power BI** | Home, Executive Overview, Financial Performance, Claims & Healthcare Utilization, Population Health & Risk, Members Demographics & Policy |
| **Python** | Insurance Cost Overview, Risk Factors Analysis, Financial & Risk Segmentation Analysis, Executive Insights |
| **Tableau** | Demographics, Customers, Risk Analysis, Policy & Operations |

Screenshots of each are in the respective tool folder's `README.md`.

## How to Reproduce

1. Start from `RAW DATA/medical_insurance.csv`.
2. Run the cleaning step in your tool of choice (`SQL/final project sql cleaning commented.sql`, or the "cleaning" section of `Python/DEPI_insurance_project.ipynb`, or the Excel/Power BI Power Query steps).
3. Build the star schema (`SQL/final project sql data model commented.sql`, or the modeling section of the notebook).
4. Run the SQL analysis script or the Python EDA cells for the business questions above.
5. Open the dashboard files directly: `EXCEL/DATA MODEL + DASHBOARD.xlsx`, `Power BI/Power BI Final Project.pbix`, or `Tableau/tableau final project fi.twbx`.
