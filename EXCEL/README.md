# Excel Phase — Cleaning, Modeling & Dashboards

## Files

| File | Purpose |
|---|---|
| `POWER QUERY.xlsb` | Power Query cleaning steps and star-schema table build |
| `medical_insurance_cleaned.csv` | Cleaned dataset exported for use in the other tools |
| `DATA MODEL + DASHBOARD.xlsx` | Data model relationships and the final dashboards |

## 1. Cleaning (Power Query)

Cleaning mirrors the logic used in SQL and Python: correcting implausible ages (rows under 16 or 95+ that contradict other attributes such as employment status, medication count, or chronic conditions) via contextual median imputation, fixing the diabetes/HbA1c and major-procedure/surgery-count inconsistencies, and filling missing `alcohol_freq` values as `"Unknown"`.

Two engineered columns were added at this stage to support later analysis:
- `income_log` — log-transformed income, for less skewed distribution analysis
- `flag_high_cost_no_claims` — flags members with high medical cost but no recorded claims

## 2. Data Model — Star Schema

`POWER QUERY.xlsb` builds the same star schema as the SQL and Python versions: `fact_insurance` plus `dim_person_info`, `dim_socioeconomic`, `dim_lifestyle`, `dim_chronic`, `dim_clinical`, `dim_policy`, `dim_plan_type`, and `dim_network_tier`.

## 3. Dashboards

`DATA MODEL + DASHBOARD.xlsx` contains the Demographics, Customers, and Risk Analysis dashboards, plus a Data Model view showing the relationships between the fact and dimension tables.

## Screenshots

<img width="2459" height="1188" alt="image" src="https://github.com/user-attachments/assets/a1eff632-a01d-4fce-84f9-ab14403ae2fa" />
<img width="2516" height="1117" alt="Demographic Dashboard" src="https://github.com/user-attachments/assets/c24a2d54-a5cf-474d-acd1-0ee64c881c59" />
<img width="2362" height="1052" alt="Customers Dashboard" src="https://github.com/user-attachments/assets/8e575e81-cb76-4d12-b87b-94c336318a86" />
<img width="2411" height="1113" alt="Risk Analysis Dashboard" src="https://github.com/user-attachments/assets/abb4fe30-4d74-41bc-af7a-57b929ecfc69" />
<img width="1622" height="811" alt="Data Model" src="https://github.com/user-attachments/assets/08ef45bf-0334-4c3f-91b5-1eab679d9eaf" />
