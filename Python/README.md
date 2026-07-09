# Python Phase — Cleaning, Modeling, EDA & Dashboards

Notebook: `DEPI_insurance_project.ipynb` (pandas, matplotlib/seaborn). This phase independently reproduces the full pipeline in Python — cleaning, star-schema modeling, exploratory analysis, and dashboards — as a cross-check against the SQL and Excel versions.

## 1. Cleaning

- **Age validation & imputation.** Rows with `age < 16` or `age >= 95` combined with contradictory attributes (still employed, very few medications, no chronic conditions, active smoking) are flagged as suspicious, then corrected with a contextual median: a 5-factor group median (education, employment, marital status, alcohol frequency, smoker), falling back to a 4-factor group median, then the global median — always floored at a realistic minimum age.
- **Diabetes / HbA1c consistency check.** `diabetes = 1` rows with `hba1c < 6.5` (below the clinical diagnostic threshold) are recoded to `diabetes = 0`.
- **Procedure mismatch check.** `had_major_procedure = 1` rows with `proc_surgery_count = 0` are recoded to `had_major_procedure = 0`.
- **Missing values.** Missing `alcohol_freq` is filled as `"Unknown"`.

## 2. Data Modeling

The cleaned dataset is restructured into the same star schema used in SQL and Excel: a central `fact_insurance` table (medical costs, claims, utilization) linked to dimension tables for person, socioeconomic, lifestyle, chronic conditions, clinical indicators, and policy details.

## 3. Exploratory Data Analysis

30+ breakdowns, including:

- Summary statistics (cost, BMI, age range) and cost by smoking status, region, sex, and chronic condition count
- Age-group and cost-bucket segmentation
- Regional cost distribution vs. regional average, and top-5 costs by region
- Correlation of age, risk profile, and every numeric factor against `annual_medical_cost`
- Cost decile analysis and cumulative share of total cost
- High-risk vs. low-risk comparison (cost, claims, chronic conditions)
- Premium vs. cost by risk level, and loss ratio by plan type
- Procedure count correlation with cost, and profile of the top 10% most expensive members

## 4. Dashboards

Four dashboards built with matplotlib/seaborn:

1. **Insurance Cost Overview** — total costs, members, premiums, average cost per member, cost distribution
2. **Risk Factors Analysis** — smoking, BMI, and chronic condition impact on cost
3. **Financial & Risk Segmentation Analysis** — loss ratio, average premium, plan types, high-risk member counts
4. **Executive Insights** — highest-cost members, premium vs. cost comparison, and top-line risk distribution

## Screenshots

<img width="2282" height="1267" alt="image" src="https://github.com/user-attachments/assets/886859a2-d0d4-4d31-b290-7573157cc358" />
<img width="1859" height="869" alt="image" src="https://github.com/user-attachments/assets/8296e29b-b289-40d8-8ff7-a0d3ed4b3a60" />
<img width="1897" height="784" alt="image" src="https://github.com/user-attachments/assets/1c2dcb72-ce5d-4df9-a82d-66d0c349350d" />
<img width="2653" height="1719" alt="image" src="https://github.com/user-attachments/assets/0d590589-3129-43d3-82b6-cb10ba855933" />
<img width="1856" height="835" alt="image" src="https://github.com/user-attachments/assets/8ce71190-54da-4114-8de0-43cd390ac143" />
<img width="2677" height="1796" alt="image" src="https://github.com/user-attachments/assets/9a8ae2e8-7ee0-4dff-a49d-1546d66b5269" />
<img width="2330" height="825" alt="image" src="https://github.com/user-attachments/assets/d296436f-e99c-4102-9015-0a9fbd829ff5" />
<img width="3081" height="1665" alt="image" src="https://github.com/user-attachments/assets/10172aa7-449b-4e15-b8e7-dcd68a21b188" />

**Data Model**

<img width="1067" height="1390" alt="Data Model" src="https://github.com/user-attachments/assets/fafcd821-9f10-4890-bb4b-268297ea9709" />
