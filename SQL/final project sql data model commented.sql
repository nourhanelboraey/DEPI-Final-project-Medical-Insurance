-- ============================================================
-- MEDICARE INSURANCE DATA WAREHOUSE
-- ============================================================


-- ============================================================
-- PHASE 1: SETUP & DATA CLEANING
-- ============================================================

USE medicare_insurance;


SET SQL_SAFE_UPDATES = 0;



-- ============================================================
-- PHASE 2: DIMENSION TABLES
-- ============================================================

-- ----------------------------------------------------------
-- dim_lifestyle
-- ----------------------------------------------------------
CREATE TABLE dim_lifestyle (
    lifestile_key  INT AUTO_INCREMENT PRIMARY KEY,
    bmi            FLOAT,
    smoker         VARCHAR(20),
    alcohol_freq   VARCHAR(20)
);

INSERT INTO dim_lifestyle (bmi, smoker, alcohol_freq)
SELECT DISTINCT
    ROUND(bmi, 2),
    smoker,
    alcohol_freq
FROM medical_insurance;

-- Duplicate check
SELECT bmi, smoker, alcohol_freq, COUNT(*) AS cnt
FROM dim_lifestyle
GROUP BY bmi, smoker, alcohol_freq
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------
-- dim_chronic
-- ----------------------------------------------------------
CREATE TABLE dim_chronic (
    chronic_key              INT AUTO_INCREMENT PRIMARY KEY,
    chronic_count            INT,
    hypertension             VARCHAR(5),
    diabetes                 VARCHAR(5),
    asthma                   VARCHAR(5),
    copd                     VARCHAR(5),
    cardiovascular_disease   VARCHAR(5),
    cancer_history           VARCHAR(5),
    kidney_disease           VARCHAR(5),
    liver_disease            VARCHAR(5),
    arthritis                VARCHAR(5),
    mental_health            VARCHAR(5)
);

INSERT INTO dim_chronic (
    chronic_count, hypertension, diabetes, asthma, copd,
    cardiovascular_disease, cancer_history, kidney_disease,
    liver_disease, arthritis, mental_health
)
SELECT DISTINCT
    chronic_count, hypertension, diabetes, asthma, copd,
    cardiovascular_disease, cancer_history, kidney_disease,
    liver_disease, arthritis, mental_health
FROM medical_insurance;

-- Duplicate check
SELECT
    chronic_count, hypertension, diabetes, asthma, copd,
    cardiovascular_disease, cancer_history, kidney_disease,
    liver_disease, arthritis, mental_health,
    COUNT(*) AS cnt
FROM dim_chronic
GROUP BY
    chronic_count, hypertension, diabetes, asthma, copd,
    cardiovascular_disease, cancer_history, kidney_disease,
    liver_disease, arthritis, mental_health
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------
-- dim_clinical
-- ----------------------------------------------------------
CREATE TABLE dim_clinical (
    clinical_key  INT AUTO_INCREMENT PRIMARY KEY,
    systolic_bp   INT,
    diastolic_bp  INT,
    ldl           DECIMAL(10, 2),
    hba1c         DECIMAL(5,  2)
);

INSERT INTO dim_clinical (systolic_bp, diastolic_bp, ldl, hba1c)
SELECT DISTINCT
    systolic_bp,
    diastolic_bp,
    ROUND(ldl,   2),
    ROUND(hba1c, 2)
FROM medical_insurance;

-- Duplicate check
SELECT systolic_bp, diastolic_bp, ldl, hba1c, COUNT(*) AS cnt
FROM dim_clinical
GROUP BY systolic_bp, diastolic_bp, ldl, hba1c
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------
-- dim_person_info
-- ----------------------------------------------------------
CREATE TABLE dim_person_info (
    person_info_key  INT AUTO_INCREMENT PRIMARY KEY,
    age              INT,
    sex              VARCHAR(20),
    region           VARCHAR(20),
    urban_rural      VARCHAR(20)
);

INSERT INTO dim_person_info (age, sex, region, urban_rural)
SELECT DISTINCT age, sex, region, urban_rural
FROM medical_insurance;

-- Duplicate check
SELECT age, sex, region, urban_rural, COUNT(*) AS cnt
FROM dim_person_info
GROUP BY age, sex, region, urban_rural
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------
-- dim_socioeconomic
-- ----------------------------------------------------------
CREATE TABLE dim_socioeconomic (
    socio_key         INT AUTO_INCREMENT PRIMARY KEY,
    income            INT,
    education         VARCHAR(30),
    marital_status    VARCHAR(30),
    employment_status VARCHAR(30),
    household_size    INT,
    dependents        INT
);

INSERT INTO dim_socioeconomic (
    income, education, marital_status,
    employment_status, household_size, dependents
)
SELECT DISTINCT
    income, education, marital_status,
    employment_status, household_size, dependents
FROM medical_insurance;

-- Duplicate check
SELECT
    income, education, marital_status,
    employment_status, household_size, dependents,
    COUNT(*) AS cnt
FROM dim_socioeconomic
GROUP BY
    income, education, marital_status,
    employment_status, household_size, dependents
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------
-- dim_network_tier
-- ----------------------------------------------------------
CREATE TABLE dim_network_tier (
    tier_key     INT AUTO_INCREMENT PRIMARY KEY,
    network_tier VARCHAR(10)
);

INSERT INTO dim_network_tier (network_tier)
SELECT DISTINCT network_tier
FROM medical_insurance;


-- ----------------------------------------------------------
-- dim_plan_type
-- ----------------------------------------------------------
CREATE TABLE dim_plan_type (
    plan_key  INT AUTO_INCREMENT PRIMARY KEY,
    plan_type VARCHAR(10)
);

INSERT INTO dim_plan_type (plan_type)
SELECT DISTINCT plan_type
FROM medical_insurance;


-- ----------------------------------------------------------
-- dim_policy
-- ----------------------------------------------------------
CREATE TABLE dim_policy (
    policy_key               INT AUTO_INCREMENT PRIMARY KEY,
    plan_key                 INT,
    tier_key                 INT,
    deductible               INT,
    copay                    INT,
    policy_term_years        INT,
    policy_changes_last_2yrs INT,
    provider_quality         FLOAT,
    FOREIGN KEY (plan_key) REFERENCES dim_plan_type(plan_key),
    FOREIGN KEY (tier_key) REFERENCES dim_network_tier(tier_key)
);

INSERT INTO dim_policy (
    plan_key, tier_key,
    deductible, copay, policy_term_years,
    policy_changes_last_2yrs, provider_quality
)
SELECT DISTINCT
    p.plan_key,
    t.tier_key,
    s.deductible,
    s.copay,
    s.policy_term_years,
    s.policy_changes_last_2yrs,
    s.provider_quality
FROM medical_insurance s
JOIN dim_plan_type     p ON s.plan_type    = p.plan_type
JOIN dim_network_tier  t ON s.network_tier = t.network_tier;

-- Duplicate check
SELECT
    plan_key, tier_key, deductible, copay,
    policy_term_years, policy_changes_last_2yrs, provider_quality,
    COUNT(*) AS cnt
FROM dim_policy
GROUP BY
    plan_key, tier_key, deductible, copay,
    policy_term_years, policy_changes_last_2yrs, provider_quality
HAVING COUNT(*) > 1;


-- ============================================================
-- PHASE 3: FACT TABLE
-- ============================================================

CREATE TABLE fact_insurance (
    insurance_id                 INT AUTO_INCREMENT PRIMARY KEY,

    -- Foreign keys (populated in Phase 4)
    socio_key                    INT,
    lifestile_key                INT,
    chronic_key                  INT,
    clinical_key                 INT,
    person_info_key              INT,
    policy_key                   INT,

    -- Utilisation
    visits_last_year             INT,
    hospitalizations_last_3yrs   INT,
    days_hospitalized_last_3yrs  INT,
    medication_count             INT,

    -- Risk & costs
    risk_score                   DECIMAL(5,  2),
    annual_medical_cost          DECIMAL(10, 2),
    annual_premium               DECIMAL(10, 2),
    monthly_premium              DECIMAL(10, 2),

    -- Claims
    claims_count                 INT,
    avg_claim_amount             DECIMAL(10, 2),
    total_claims_paid            DECIMAL(12, 2),

    -- Procedure counts
    proc_imaging_count           INT,
    proc_surgery_count           INT,
    proc_physical_count          INT,
    proc_consult_count           INT,
    proc_lab_count               INT,

    -- Flags
    is_high_risk                 VARCHAR(5),
    had_major_procedure          VARCHAR(5),

    FOREIGN KEY (socio_key)       REFERENCES dim_socioeconomic(socio_key),
    FOREIGN KEY (lifestile_key)   REFERENCES dim_lifestyle(lifestile_key),
    FOREIGN KEY (chronic_key)     REFERENCES dim_chronic(chronic_key),
    FOREIGN KEY (clinical_key)    REFERENCES dim_clinical(clinical_key),
    FOREIGN KEY (person_info_key) REFERENCES dim_person_info(person_info_key),
    FOREIGN KEY (policy_key)      REFERENCES dim_policy(policy_key)
);

-- Insert measures only (FK columns remain NULL until Phase 4)
INSERT INTO fact_insurance (
    visits_last_year, hospitalizations_last_3yrs, days_hospitalized_last_3yrs,
    medication_count, risk_score,
    annual_medical_cost, annual_premium, monthly_premium,
    claims_count, avg_claim_amount, total_claims_paid,
    proc_imaging_count, proc_surgery_count, proc_physical_count,
    proc_consult_count, proc_lab_count,
    is_high_risk, had_major_procedure
)
SELECT
    visits_last_year, hospitalizations_last_3yrs, days_hospitalized_last_3yrs,
    medication_count, risk_score,
    annual_medical_cost, annual_premium, monthly_premium,
    claims_count, avg_claim_amount, total_claims_paid,
    proc_imaging_count, proc_surgery_count, proc_physio_count,   -- source column name
    proc_consult_count, proc_lab_count,
    is_high_risk, had_major_procedure
FROM medical_insurance;

-- Verify measures loaded (all should be 0)
SELECT
    SUM(CASE WHEN visits_last_year            IS NULL THEN 1 ELSE 0 END) AS visits_nulls,
    SUM(CASE WHEN hospitalizations_last_3yrs  IS NULL THEN 1 ELSE 0 END) AS hosp_nulls,
    SUM(CASE WHEN days_hospitalized_last_3yrs IS NULL THEN 1 ELSE 0 END) AS days_nulls,
    SUM(CASE WHEN medication_count            IS NULL THEN 1 ELSE 0 END) AS meds_nulls,
    SUM(CASE WHEN risk_score                  IS NULL THEN 1 ELSE 0 END) AS risk_nulls,
    SUM(CASE WHEN annual_medical_cost         IS NULL THEN 1 ELSE 0 END) AS cost_nulls,
    SUM(CASE WHEN annual_premium              IS NULL THEN 1 ELSE 0 END) AS premium_nulls,
    SUM(CASE WHEN monthly_premium             IS NULL THEN 1 ELSE 0 END) AS monthly_nulls,
    SUM(CASE WHEN claims_count                IS NULL THEN 1 ELSE 0 END) AS claims_nulls,
    SUM(CASE WHEN avg_claim_amount            IS NULL THEN 1 ELSE 0 END) AS avg_claim_nulls,
    SUM(CASE WHEN total_claims_paid           IS NULL THEN 1 ELSE 0 END) AS total_claims_nulls,
    SUM(CASE WHEN proc_imaging_count          IS NULL THEN 1 ELSE 0 END) AS imaging_nulls,
    SUM(CASE WHEN proc_surgery_count          IS NULL THEN 1 ELSE 0 END) AS surgery_nulls,
    SUM(CASE WHEN proc_physical_count         IS NULL THEN 1 ELSE 0 END) AS physio_nulls,
    SUM(CASE WHEN proc_consult_count          IS NULL THEN 1 ELSE 0 END) AS consult_nulls,
    SUM(CASE WHEN proc_lab_count              IS NULL THEN 1 ELSE 0 END) AS lab_nulls,
    SUM(CASE WHEN is_high_risk                IS NULL THEN 1 ELSE 0 END) AS risk_flag_nulls,
    SUM(CASE WHEN had_major_procedure         IS NULL THEN 1 ELSE 0 END) AS procedure_flag_nulls
FROM fact_insurance;


-- ============================================================
-- PHASE 4: INDEXES (before FK population for performance)
-- ============================================================

CREATE INDEX idx_mi_person_id         ON medical_insurance (person_id);
CREATE INDEX idx_mi_clinical_lookup   ON medical_insurance (systolic_bp, diastolic_bp, ldl, hba1c);
CREATE INDEX idx_dim_clinical_lookup  ON dim_clinical      (systolic_bp, diastolic_bp, ldl, hba1c);
CREATE INDEX idx_dim_policy_values    ON dim_policy        (plan_key, tier_key, deductible, copay, policy_term_years);
CREATE INDEX idx_fact_clinical_key    ON fact_insurance    (clinical_key);
CREATE INDEX idx_fact_policy_key      ON fact_insurance    (policy_key);


-- ============================================================
-- PHASE 5: POPULATE FOREIGN KEYS IN FACT TABLE
-- ============================================================

-- socio_key
UPDATE fact_insurance f
JOIN medical_insurance mi ON f.insurance_id = mi.person_id
SET f.socio_key = (
    SELECT ds.socio_key
    FROM dim_socioeconomic ds
    WHERE ds.income            = mi.income
      AND ds.education         = mi.education
      AND ds.marital_status    = mi.marital_status
      AND ds.employment_status = mi.employment_status
      AND ds.household_size    = mi.household_size
      AND ds.dependents        = mi.dependents
    LIMIT 1
);

-- lifestile_key
UPDATE fact_insurance f
JOIN medical_insurance mi ON f.insurance_id = mi.person_id
SET f.lifestile_key = (
    SELECT dl.lifestile_key
    FROM dim_lifestyle dl
    WHERE dl.bmi          = mi.bmi
      AND dl.smoker       = mi.smoker
      AND dl.alcohol_freq = mi.alcohol_freq
    LIMIT 1
);

-- clinical_key
UPDATE fact_insurance f
JOIN medical_insurance mi ON f.insurance_id = mi.person_id
JOIN dim_clinical dc
    ON  dc.systolic_bp  = mi.systolic_bp
    AND dc.diastolic_bp = mi.diastolic_bp
    AND dc.ldl          = mi.ldl
    AND dc.hba1c        = mi.hba1c
SET f.clinical_key = dc.clinical_key;

-- chronic_key
UPDATE fact_insurance f
JOIN medical_insurance mi ON f.insurance_id = mi.person_id
SET f.chronic_key = (
    SELECT dch.chronic_key
    FROM dim_chronic dch
    WHERE dch.hypertension           = mi.hypertension
      AND dch.diabetes               = mi.diabetes
      AND dch.asthma                 = mi.asthma
      AND dch.copd                   = mi.copd
      AND dch.cardiovascular_disease = mi.cardiovascular_disease
      AND dch.cancer_history         = mi.cancer_history
      AND dch.kidney_disease         = mi.kidney_disease
      AND dch.liver_disease          = mi.liver_disease
      AND dch.arthritis              = mi.arthritis
      AND dch.mental_health          = mi.mental_health
    LIMIT 1
);

-- person_info_key
UPDATE fact_insurance f
JOIN medical_insurance mi ON f.insurance_id = mi.person_id
SET f.person_info_key = (
    SELECT dp.person_info_key
    FROM dim_person_info dp
    WHERE dp.age         = mi.age
      AND dp.sex         = mi.sex
      AND dp.region      = mi.region
      AND dp.urban_rural = mi.urban_rural
    LIMIT 1
);

-- policy_key
UPDATE fact_insurance f
JOIN medical_insurance mi ON f.insurance_id = mi.person_id
SET f.policy_key = (
    SELECT dpo.policy_key
    FROM dim_policy dpo
    JOIN dim_plan_type    pt ON dpo.plan_key = pt.plan_key
    JOIN dim_network_tier nt ON dpo.tier_key = nt.tier_key
    WHERE pt.plan_type                = mi.plan_type
      AND nt.network_tier             = mi.network_tier
      AND dpo.deductible              = mi.deductible
      AND dpo.copay                   = mi.copay
      AND dpo.policy_term_years       = mi.policy_term_years
      AND dpo.policy_changes_last_2yrs = mi.policy_changes_last_2yrs
      AND dpo.provider_quality        = mi.provider_quality
    LIMIT 1
);


-- ============================================================
-- PHASE 6: FINAL VERIFICATION
-- ============================================================

-- FK null counts (all should be 0)
SELECT
    COUNT(*)                                                          AS total_rows,
    SUM(CASE WHEN socio_key       IS NULL THEN 1 ELSE 0 END)         AS socio_key_nulls,
    SUM(CASE WHEN lifestile_key   IS NULL THEN 1 ELSE 0 END)         AS lifestyle_key_nulls,
    SUM(CASE WHEN chronic_key     IS NULL THEN 1 ELSE 0 END)         AS chronic_key_nulls,
    SUM(CASE WHEN clinical_key    IS NULL THEN 1 ELSE 0 END)         AS clinical_key_nulls,
    SUM(CASE WHEN person_info_key IS NULL THEN 1 ELSE 0 END)         AS person_info_key_nulls,
    SUM(CASE WHEN policy_key      IS NULL THEN 1 ELSE 0 END)         AS policy_key_nulls
FROM fact_insurance;

-- Duplicate rows check in fact table
SELECT
    socio_key, lifestile_key, chronic_key, clinical_key, person_info_key, policy_key,
    visits_last_year, hospitalizations_last_3yrs, days_hospitalized_last_3yrs,
    medication_count, risk_score,
    annual_medical_cost, annual_premium, monthly_premium,
    claims_count, avg_claim_amount, total_claims_paid,
    proc_imaging_count, proc_surgery_count, proc_physical_count,
    proc_consult_count, proc_lab_count,
    is_high_risk, had_major_procedure,
    COUNT(*) AS cnts
FROM fact_insurance
GROUP BY
    socio_key, lifestile_key, chronic_key, clinical_key, person_info_key, policy_key,
    visits_last_year, hospitalizations_last_3yrs, days_hospitalized_last_3yrs,
    medication_count, risk_score,
    annual_medical_cost, annual_premium, monthly_premium,
    claims_count, avg_claim_amount, total_claims_paid,
    proc_imaging_count, proc_surgery_count, proc_physical_count,
    proc_consult_count, proc_lab_count,
    is_high_risk, had_major_procedure
HAVING COUNT(*) > 1;


-- ============================================================
-- PHASE 7: New Columns
-- ============================================================

-- 1. Update dim_clinical (Adding binned categories)
ALTER TABLE dim_clinical
    ADD COLUMN `BP category` VARCHAR(50) NULL,
    ADD COLUMN `ldl category` VARCHAR(50) NULL,
    ADD COLUMN `Diabetes category` VARCHAR(50) NULL;

-- 2. Update dim_chronic (Adding multi-condition tracking)
ALTER TABLE dim_chronic
    ADD COLUMN `multi condition` VARCHAR(50) NULL,
    ADD COLUMN `diabetes and cardiovascular` VARCHAR(100) NULL;

-- 3. Update dim_lifestyle 
ALTER TABLE dim_lifestyle
    ADD COLUMN `bmi category` VARCHAR(50) NULL;

-- 4. Update dim_person_info
ALTER TABLE dim_person_info
    ADD COLUMN `Age group` VARCHAR(30) NULL;

-- 5. Update fact_insurance
ALTER TABLE fact_insurance
    ADD COLUMN risk_segment VARCHAR(50) NULL,
    ADD COLUMN `Cost Efficiency` DECIMAL(10, 2) NULL,
    ADD COLUMN Profit DECIMAL(12, 2) NULL,
    ADD COLUMN Utilization DECIMAL(5, 2) NULL, 
    ADD COLUMN `Hidden Risks` VARCHAR(100) NULL,
    ADD COLUMN `Claims Consistency` VARCHAR(50) NULL;
    
    
    
    
    SET SQL_SAFE_UPDATES = 0;

-- 1. Populating dim_clinical (Standard medical thresholds)
UPDATE dim_clinical
SET 
    `BP category` = CASE 
        WHEN systolic_bp < 120 AND diastolic_bp < 80 THEN 'Normal'
        WHEN systolic_bp BETWEEN 120 AND 129 AND diastolic_bp < 80 THEN 'Elevated'
        WHEN systolic_bp BETWEEN 130 AND 139 OR diastolic_bp BETWEEN 80 AND 89 THEN 'Stage 1 Hypertension'
        WHEN systolic_bp >= 140 OR diastolic_bp >= 90 THEN 'Stage 2 Hypertension'
        ELSE 'Unknown'
    END,
    `ldl category` = CASE 
        WHEN ldl < 100 THEN 'Optimal'
        WHEN ldl BETWEEN 100 AND 129 THEN 'Near Optimal'
        WHEN ldl BETWEEN 130 AND 159 THEN 'Borderline High'
        WHEN ldl BETWEEN 160 AND 189 THEN 'High'
        WHEN ldl >= 190 THEN 'Very High'
        ELSE 'Unknown'
    END,
    `Diabetes category` = CASE 
        WHEN hba1c < 5.7 THEN 'Normal'
        WHEN hba1c BETWEEN 5.7 AND 6.4 THEN 'Prediabetes'
        WHEN hba1c >= 6.5 THEN 'Diabetes'
        ELSE 'Unknown'
    END;

-- 2. Populating dim_chronic
UPDATE dim_chronic
SET 
    `multi condition` = CASE 
        WHEN chronic_count >= 3 THEN 'High Comorbidity'
        WHEN chronic_count <3 THEN 'low Comorbidity'
        ELSE 'No Chronic Conditions'
    END;

UPDATE dim_chronic
SET 
    `diabetes and cardiovascular` = CASE 
        WHEN diabetes = 'True' AND cardiovascular_disease = 'True' THEN 'Both'
        WHEN diabetes = 'True' THEN 'Diabetes Only'
        WHEN cardiovascular_disease = 'True' THEN 'Cardiovascular Only'
        ELSE 'Neither'
    END;

-- 3. Populating dim_lifestyle (Standard CDC BMI categories)
UPDATE dim_lifestyle
SET `bmi category` = CASE 
    WHEN bmi < 18.5 THEN 'Underweight'
    WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal weight'
    WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
    WHEN bmi >= 30.0 THEN 'Obese'
    ELSE 'Unknown'
END;

-- 4. Populating dim_person_info
UPDATE dim_person_info
SET `Age group` = CASE 
    WHEN age < 18 THEN 'Teen'
    WHEN age < 30 THEN 'Young'
    WHEN age < 50 THEN 'Adult'
    WHEN age < 65 THEN 'Middle Age'
    ELSE 'Senior'
END;


-- 5. Populating fact_insurance (Business logic metrics)
UPDATE fact_insurance
SET 
    -- Profit: Annual Premium received minus the Total Claims Paid
    Profit = annual_premium - total_claims_paid,
    
    -- Utilization: Percentage of visits that resulted in hospitalizations
    Utilization = CASE 
        WHEN visits_last_year > 0 THEN (hospitalizations_last_3yrs / 3.0) / visits_last_year 
        ELSE 0 
    END,
    
    -- Cost Efficiency: Average claim size compared to the total claims paid
    `Cost Efficiency` = CASE 
        WHEN claims_count > 0 THEN total_claims_paid / claims_count 
        ELSE 0 
    END,
    
    -- Risk Segment: Binning based on the existing numerical risk_score
    risk_segment = CASE 
        WHEN risk_score >= 7.5 THEN 'High Risk'
        WHEN risk_score BETWEEN 4.0 AND 7.49 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END,
    
    -- Hidden Risks: Flagging individuals with high risk score but no declared chronic conditions
   `Hidden Risks` = CASE 
        WHEN is_high_risk = 'True' AND chronic_key IN (SELECT chronic_key FROM dim_chronic WHERE chronic_count = 0) THEN 'High Risk / Undiagnosed'
        ELSE 'Monitored / Low Risk'
    END,
    
    -- Claims Consistency: Looking at claim behavior patterns
    `Claims Consistency` = CASE 
        WHEN claims_count > 0 AND avg_claim_amount > 0 THEN 'Active Claims'
        ELSE 'No/Low Activity'
    END;

SET SQL_SAFE_UPDATES = 1;
