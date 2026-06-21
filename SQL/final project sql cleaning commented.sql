-- ============================================================
-- Medical Insurance Database Setup & Age Correction Script
-- Compatible with: MySQL Workbench
-- ============================================================


-- ------------------------------------------------------------
-- SECTION 1: Database Setup
-- ------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS medicare_insurance;
USE medicare_insurance;


-- ------------------------------------------------------------
-- SECTION 2: Add Temporary Helper Column
-- Used to compute the minimum plausible age per row
-- based on lifestyle, medical, and demographic attributes.
-- ------------------------------------------------------------

ALTER TABLE medical_insurance
ADD COLUMN min_age INT DEFAULT 0;


-- ------------------------------------------------------------
-- SECTION 3: Set min_age Constraints by Category
-- Each UPDATE raises min_age only if the new threshold
-- is higher than the current value (MAX logic via CASE).
-- ------------------------------------------------------------

-- >> Smoking Status
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 16 THEN min_age ELSE 16 END WHERE smoker = 'Current';
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END WHERE smoker = 'Former';

-- >> Alcohol Frequency
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END
WHERE alcohol_freq IN ('Occasional', 'Weekly', 'Daily');

UPDATE medical_insurance SET min_age = CASE WHEN min_age > 21 THEN min_age ELSE 21 END
WHERE alcohol_freq = 'Daily';

-- >> Employment Status
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 16 THEN min_age ELSE 16 END
WHERE employment_status IN ('Employed', 'Unemployed');

UPDATE medical_insurance SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END
WHERE employment_status = 'Self-employed';

UPDATE medical_insurance SET min_age = CASE WHEN min_age > 55 THEN min_age ELSE 55 END
WHERE employment_status = 'Retired';

-- >> Marital Status
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END
WHERE marital_status = 'Married';

UPDATE medical_insurance SET min_age = CASE WHEN min_age > 20 THEN min_age ELSE 20 END
WHERE marital_status IN ('Divorced', 'Widowed');

-- >> Dependents Count
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END WHERE dependents >= 1;
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 20 THEN min_age ELSE 20 END WHERE dependents >= 3;
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 25 THEN min_age ELSE 25 END WHERE dependents >= 5;
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 28 THEN min_age ELSE 28 END WHERE dependents >= 6;

-- >> Education Level
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 16 THEN min_age ELSE 16 END WHERE education = 'HS';
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END WHERE education = 'Some College';
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 22 THEN min_age ELSE 22 END WHERE education = 'Bachelors';
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 24 THEN min_age ELSE 24 END WHERE education = 'Masters';
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 28 THEN min_age ELSE 28 END WHERE education = 'Doctorate';

-- >> Medical Conditions (general baseline)
UPDATE medical_insurance
SET min_age = CASE WHEN min_age > 18 THEN min_age ELSE 18 END
WHERE hypertension = 1
   OR diabetes = 1
   OR asthma = 1
   OR copd = 1
   OR cardiovascular_disease = 1
   OR cancer_history = 1
   OR kidney_disease = 1
   OR liver_disease = 1
   OR arthritis = 1
   OR mental_health = 1;

-- >> Medical Conditions (condition-specific overrides)
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 25 THEN min_age ELSE 25 END WHERE arthritis = 1;
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 35 THEN min_age ELSE 35 END WHERE copd = 1;
UPDATE medical_insurance SET min_age = CASE WHEN min_age > 35 THEN min_age ELSE 35 END WHERE cardiovascular_disease = 1;

-- >> Edge Case: Very old rows that are implausible — flag with sentinel value 100
-- Applies when age >= 95 AND any suspicious attribute is present
UPDATE medical_insurance
SET min_age = 100
WHERE age >= 95
  AND (
        employment_status IN ('Employed', 'Self-employed')
        OR medication_count < 3
        OR (
            hypertension = 0
            AND diabetes = 0
            AND asthma = 0
            AND copd = 0
            AND cardiovascular_disease = 0
            AND cancer_history = 0
            AND kidney_disease = 0
            AND liver_disease = 0
            AND arthritis = 0
            AND mental_health = 0
        )
        OR smoker = 'Current'
  );


-- ------------------------------------------------------------
-- SECTION 4: Impute Age for Rows Violating min_age
-- Strategy (cascading fallback):
--   1. Median of 5-factor group (edu, employment, marital, alcohol, smoker)
--   2. Median of 4-factor group (edu, employment, marital, alcohol)
--   3. Global median of all valid-age rows
-- Always picks the MAX of (median, min_age) to stay realistic.
--
-- MySQL note: Unlike SQL Server, MySQL does NOT support
-- UPDATE...JOIN with a FROM clause. Use multi-table UPDATE syntax.
-- Also, MySQL doesn't allow referencing the same table being
-- updated in a subquery directly — so we wrap it in a derived table.
-- ------------------------------------------------------------

UPDATE medical_insurance mi
JOIN (
    SELECT
        bad.person_id,
        CASE
            WHEN ROUND(COALESCE(med5.median_age, med4.median_age, global_med.median_age), 0) > bad.min_age
            THEN ROUND(COALESCE(med5.median_age, med4.median_age, global_med.median_age), 0)
            ELSE bad.min_age
        END AS new_age
    FROM medical_insurance bad

    -- Fallback 1: 5-factor group median
    LEFT JOIN (
        SELECT
            education,
            employment_status,
            marital_status,
            alcohol_freq,
            smoker,
            AVG(age) AS median_age   -- approximated median via AVG of middle rows
        FROM (
            SELECT
                education,
                employment_status,
                marital_status,
                alcohol_freq,
                smoker,
                age,
                ROW_NUMBER() OVER (
                    PARTITION BY education, employment_status, marital_status, alcohol_freq, smoker
                    ORDER BY age
                ) AS rn,
                COUNT(*) OVER (
                    PARTITION BY education, employment_status, marital_status, alcohol_freq, smoker
                ) AS cnt
            FROM medical_insurance
            WHERE age >= min_age
        ) x
        WHERE rn IN (
            FLOOR((cnt + 1) / 2.0),
            FLOOR((cnt + 2) / 2.0)
        )
        GROUP BY education, employment_status, marital_status, alcohol_freq, smoker
    ) med5
        ON bad.education        = med5.education
       AND bad.employment_status = med5.employment_status
       AND bad.marital_status   = med5.marital_status
       AND bad.alcohol_freq     = med5.alcohol_freq
       AND bad.smoker           = med5.smoker

    -- Fallback 2: 4-factor group median (drops smoker)
    LEFT JOIN (
        SELECT
            education,
            employment_status,
            marital_status,
            alcohol_freq,
            AVG(age) AS median_age
        FROM (
            SELECT
                education,
                employment_status,
                marital_status,
                alcohol_freq,
                age,
                ROW_NUMBER() OVER (
                    PARTITION BY education, employment_status, marital_status, alcohol_freq
                    ORDER BY age
                ) AS rn,
                COUNT(*) OVER (
                    PARTITION BY education, employment_status, marital_status, alcohol_freq
                ) AS cnt
            FROM medical_insurance
            WHERE age >= min_age
        ) y
        WHERE rn IN (
            FLOOR((cnt + 1) / 2.0),
            FLOOR((cnt + 2) / 2.0)
        )
        GROUP BY education, employment_status, marital_status, alcohol_freq
    ) med4
        ON bad.education        = med4.education
       AND bad.employment_status = med4.employment_status
       AND bad.marital_status   = med4.marital_status
       AND bad.alcohol_freq     = med4.alcohol_freq

    -- Fallback 3: Global median across all valid rows
    CROSS JOIN (
        SELECT AVG(age) AS median_age
        FROM (
            SELECT
                age,
                ROW_NUMBER() OVER (ORDER BY age) AS rn,
                COUNT(*) OVER ()                 AS cnt
            FROM medical_insurance
            WHERE age >= min_age
        ) z
        WHERE rn IN (
            FLOOR((cnt + 1) / 2.0),
            FLOOR((cnt + 2) / 2.0)
        )
    ) global_med

    -- Only process rows where age is currently invalid
    WHERE bad.age < bad.min_age

) fixed ON mi.person_id = fixed.person_id
SET mi.age = fixed.new_age;


-- ------------------------------------------------------------
-- SECTION 5: Drop Temporary Helper Column
-- min_age was only needed for imputation; remove it now.
-- Note: MySQL uses DROP COLUMN directly — no constraint name needed.
-- ------------------------------------------------------------

ALTER TABLE medical_insurance
DROP COLUMN min_age;


-- ------------------------------------------------------------
-- SECTION 6: Validation Check
-- Confirms age range, average, and any remaining violations.
-- ------------------------------------------------------------

SELECT
    MIN(age)                                          AS min_age,
    MAX(age)                                          AS max_age,
    ROUND(AVG(CAST(age AS DECIMAL(10,2))), 2)         AS avg_age,
    COUNT(*)                                          AS total_rows,
    SUM(CASE WHEN age < 16 THEN 1 ELSE 0 END)        AS remaining_age_violations
FROM medical_insurance;