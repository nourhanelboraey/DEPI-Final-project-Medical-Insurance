# SQL Phase — Database Setup, Cleaning, Modeling & Analysis

Built and run in **MySQL Workbench**. This phase covers the full pipeline from raw table to a queryable star schema, in three scripts.

## Files

| File | Purpose |
|---|---|
| `final project sql cleaning commented.sql` | Creates the database, validates and corrects implausible ages |
| `final project sql data model commented.sql` | Builds the star schema (fact + dimension tables) from the cleaned data |
| `final project SQL Analysis.sql` | Runs the business analysis queries against the star schema |

## 1. Cleaning

The cleaning script flags and corrects records with implausible `age` values (under 16 or 95+) when other columns contradict the reported age — for example, still employed, very few medications on file, no chronic conditions, or an active smoker at an extreme age.

Rather than dropping these rows, ages are corrected using a cascading median-imputation strategy:

1. Median age within a matching group of education, employment status, marital status, alcohol frequency, and smoking status (5-factor match)
2. Fallback: median within a 4-factor group (drops smoking status)
3. Fallback: global median across all valid-age rows

Each replacement is floored against a rule-based minimum plausible age for that record (e.g. a current smoker can't be under 16; arthritis implies at least 25; a retiree can't be under 55), so imputed ages stay medically and demographically realistic. Because MySQL doesn't support `UPDATE ... FROM`, the medians are computed via window functions and joined back using MySQL's multi-table `UPDATE ... JOIN` syntax.

## 2. Data Model — Star Schema

| Table | Role |
|---|---|
| `fact_insurance` | Utilization, risk score, costs, premiums, claims, procedure counts |
| `dim_person_info` | Core person attributes |
| `dim_socioeconomic` | Income, education, employment, household |
| `dim_lifestyle` | BMI, smoking, alcohol frequency |
| `dim_chronic` | Chronic condition flags and count |
| `dim_clinical` | Blood pressure, LDL, HbA1c, risk score |
| `dim_policy` | Deductible, copay, policy term, provider quality (references `dim_plan_type`, `dim_network_tier`) |

## 3. Analysis

The analysis script answers 10 categories of business questions: KPIs, customer segmentation, lifestyle analysis, clinical risk analysis, chronic disease analysis, policy analysis, high-risk member analysis, utilization analysis, socioeconomic analysis, and top-line business insights (top customers, loss ratio by plan/risk segment, smoking impact on claims).

## Data Model Diagram

<img width="1120" height="846" alt="datamodel picture" src="https://github.com/user-attachments/assets/f6d3643c-9522-401c-b15d-5f4a7f5a3aea" />
