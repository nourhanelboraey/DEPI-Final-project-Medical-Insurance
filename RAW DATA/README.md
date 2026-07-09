# Medical Insurance Dataset

`medical_insurance_1_.csv` — **100,000 rows × 54 columns**. One row = one policyholder.

## Overview

Synthetic health-insurance data combining demographics, health/lifestyle info, chronic condition flags, policy details, and claims/cost history. Suited for risk scoring, premium/cost modeling, and BI dashboards (Demographics, Risk Analysis, Customers, Policy & Ops).

`person_id` is a unique key (no duplicates).

## Column Dictionary

### Identifiers
| Column | Type | Description |
|---|---|---|
| `person_id` | int | Unique policyholder ID (1–100,000) |

### Demographics
| Column | Type | Description |
|---|---|---|
| `age` | int | 0–100 (includes minors covered as dependents) |
| `sex` | category | Female, Male, Other |
| `region` | category | North, South, East, West, Central |
| `urban_rural` | category | Urban, Suburban, Rural |
| `income` | float | Annual income; right-skewed, median ≈ 36,200 |
| `education` | category | No HS, HS, Some College, Bachelors, Masters, Doctorate |
| `marital_status` | category | Single, Married, Divorced, Widowed |
| `employment_status` | category | Employed, Self-employed, Unemployed, Retired |
| `household_size` | int | 1–9 |
| `dependents` | int | 0–7 |

### Health & Lifestyle
| Column | Type | Description |
|---|---|---|
| `bmi` | float | Body Mass Index, 12.0–50.4 |
| `smoker` | category | Never, Former, Current |
| `alcohol_freq` | category | None, Occasional, Weekly, Daily — **~30.1% missing** |
| `visits_last_year` | int | Outpatient/GP visits in last 12 months |
| `hospitalizations_last_3yrs` | int | Inpatient admissions, last 3 years (0–3) |
| `days_hospitalized_last_3yrs` | int | Total inpatient days, last 3 years (0–21) |
| `medication_count` | int | Active prescriptions (0–11) |
| `systolic_bp` / `diastolic_bp` | float | Blood pressure, mmHg |
| `ldl` | float | LDL cholesterol, mg/dL |
| `hba1c` | float | Hemoglobin A1c, % (diabetes marker) |

### Chronic Conditions
| Column | Type | Description |
|---|---|---|
| `chronic_count` | int | Sum of the 10 flags below (0–6) |
| `hypertension`, `diabetes`, `asthma`, `copd`, `cardiovascular_disease`, `cancer_history`, `kidney_disease`, `liver_disease`, `arthritis`, `mental_health` | binary | 1 = condition present |

### Policy Details
| Column | Type | Description |
|---|---|---|
| `plan_type` | category | HMO, PPO, EPO, POS |
| `network_tier` | category | Bronze, Silver, Gold, Platinum |
| `deductible` | int | 500–5,000 |
| `copay` | int | 10–50 |
| `policy_term_years` | int | Years held (1–10) |
| `policy_changes_last_2yrs` | int | 0–2 |
| `provider_quality` | float | Network quality rating, 1.5–5.0 |

### Risk & Financial
| Column | Type | Description |
|---|---|---|
| `risk_score` | float | Normalized underwriting risk, 0–1 |
| `annual_medical_cost` | float | Total annual cost incurred |
| `annual_premium` / `monthly_premium` | float | Premium charged |
| `claims_count` | int | Claims filed (0–23) |
| `avg_claim_amount` | float | Average $ per claim |
| `total_claims_paid` | float | Total $ paid out |
| `is_high_risk` | binary | 1 = flagged high risk |

### Procedure Utilization
| Column | Type | Description |
|---|---|---|
| `proc_imaging_count`, `proc_surgery_count`, `proc_physio_count`, `proc_consult_count`, `proc_lab_count` | int | Counts per procedure type (0–7) |
| `had_major_procedure` | binary | 1 = at least one major/surgical procedure |

## Key Statistics

- **Age:** 0–100, mean ≈ 47.5
- **Income:** 1,100–1,061,800, median 36,200 (long right tail)
- **BMI:** 12.0–50.4, mean ≈ 27.0
- **Smoker:** Never 69.7% · Former 18.2% · Current 12.1%
- **Plan type:** PPO 35.2% · HMO 34.7% · EPO 15.1% · POS 15.0%
- **Chronic conditions:** 46.5% none, 37.6% exactly one, 15.9% two or more
- **High risk:** 36.8% flagged `is_high_risk = 1`
- **Annual medical cost:** 55.55–65,724.90, mean ≈ 3,009 (right-skewed)
- **Annual premium:** 211.67–10,962.55, mean ≈ 582
- **Correlations with `annual_medical_cost`:** `risk_score` r≈0.31, `chronic_count` r≈0.30, `age` r≈0.13 (all moderate-to-weak)
