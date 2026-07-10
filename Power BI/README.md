# Power BI Phase — Cleaning, Modeling & Report

File: `Power BI Final Project.pbix`

## 1. Cleaning & Transformation

Cleaning was rebuilt independently in Power Query (M), applying the same corrections used in the SQL, Python, and Excel versions: implausible-age correction via contextual median imputation, the diabetes/HbA1c and major-procedure/surgery-count consistency fixes, and handling of missing `alcohol_freq` values.

## 2. Data Model

The report uses the same star schema as the other tools — a central `fact_insurance` table linked to dimension tables for person, socioeconomic, lifestyle, chronic conditions, clinical indicators, and policy details — with DAX measures built on top for metrics such as smoker-status cost comparisons and chronic-condition impact.

## 3. Report Pages

The `.pbix` contains six pages:

1. **Home**
2. **Executive Overview**
3. **Financial Performance**
4. **Claims & Healthcare Utilization**
5. **Population Health & Risk**
6. **Members Demographics & Policy**

## Screenshots

<img width="1755" height="996" alt="image" src="https://github.com/user-attachments/assets/0933c48f-0cd5-4940-96b6-14c2cb293245" />
<img width="1799" height="1023" alt="image" src="https://github.com/user-attachments/assets/84becc59-1437-401d-bd29-f767254365c2" />
<img width="1761" height="994" alt="image" src="https://github.com/user-attachments/assets/e5426107-f6f2-4466-a44a-e804ca3ef93c" />
<img width="1767" height="989" alt="image" src="https://github.com/user-attachments/assets/2f919b15-f892-4378-a915-9b2859fd6b77" />
<img width="1758" height="999" alt="image" src="https://github.com/user-attachments/assets/21cc0327-1cec-46c0-9670-201349d065ce" />
<img width="2124" height="1254" alt="image" src="https://github.com/user-attachments/assets/060a9dfc-3ac5-4e5f-bdf8-67fc26ff6291" />

