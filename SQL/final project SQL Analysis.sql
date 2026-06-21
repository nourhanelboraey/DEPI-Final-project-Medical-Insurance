-- 1- KPIs
SELECT
COUNT(*) AS TOTAL_CUSTOMERS,
Sum(annual_premium) as Total_premiums,
sum(total_claims_paid) as total_claims_paid,
sum(profit) as profit,
avg(annual_medical_cost) as AVG_Medical_cost
FROM fact_insurance;

--- 2- CUSTOMER SEGMENTATION

-- Which age group has tha highest medical cost?

SELECT
p.`age group`,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.`age group`
ORDER BY avg_cost DESC;

-- Medical cost by gender

SELECT
p.sex,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.sex;

-- Urban VS Rural utilization 

SELECT
p.urban_rural,
AVG(f.visits_last_year) AS avg_visits,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.urban_rural;

-- Which regions are most expensive?

SELECT
p.region,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.region
ORDER BY avg_cost DESC;


-- 3- LIFESTYLE ANALYSIS

-- Smokers VS non-smokers

SELECT
l.smoker,
AVG(f.annual_medical_cost) AS avg_cost,
AVG(f.total_claims_paid) AS avg_claims
FROM fact_insurance f
JOIN dim_lifestyle l
ON f.lifestile_key = l.lifestile_key
GROUP BY l.smoker;

-- BMI Category Impact

SELECT
l.bmi_category,
AVG(f.annual_medical_cost) AS avg_cost,
AVG(f.risk_score) AS avg_risk
FROM fact_insurance f
JOIN dim_lifestyle l
ON f.lifestile_key = l.lifestile_key
GROUP BY l.bmi_category
ORDER BY avg_cost DESC;

-- Alcohol consumption analysis

SELECT
l.alcohol_freq,
AVG(f.annual_medical_cost) AS avg_cost,
AVG(f.claims_count) AS avg_claims
FROM fact_insurance f
JOIN dim_lifestyle l
ON f.lifestile_key = l.lifestile_key
GROUP BY l.alcohol_freq;

-- 4- Clinical risk analysis

-- which BP Category generates the highest cost 

SELECT
c.`BP category`,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_clinical c
ON f.clinical_key = c.clinical_key
GROUP BY c.`BP category`
ORDER BY avg_cost DESC;

-- Diabetes category VS Claims

SELECT
c.`diabetes category`,
AVG(f.claims_count) AS avg_claims,
AVG(f.total_claims_paid) AS avg_claim_paid
FROM fact_insurance f
JOIN dim_clinical c
ON f.clinical_key = c.clinical_key
GROUP BY c.`diabetes category`;

-- LDL Category analysis 

SELECT
c.`ldl category`,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_clinical c
ON f.clinical_key = c.clinical_key
GROUP BY c.`ldl category`;

-- 5- Chronic Disease Analysis 

-- Cost by chronic condition count

SELECT
ch.chronic_count,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_chronic ch
ON f.chronic_key = ch.chronic_key
GROUP BY ch.chronic_count
ORDER BY ch.chronic_count DESC;

-- Top Diseases Driving Cost 

SELECT
AVG(CASE WHEN diabetes='True'
THEN f.annual_medical_cost END) AS diabetes_cost,

AVG(CASE WHEN hypertension='True'
THEN f.annual_medical_cost END) AS hypertension_cost,

AVG(CASE WHEN cardiovascular_disease='True'
THEN f.annual_medical_cost END) AS cardiovascular_cost
FROM fact_insurance f
JOIN dim_chronic ch
ON f.chronic_key = ch.chronic_key;

-- Multi_condition customers 

SELECT
`multi condition`,
COUNT(*) AS customers,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_chronic ch
ON f.chronic_key = ch.chronic_key
GROUP BY `multi condition`;


-- 6- Policy Analysis 

-- Which plantype is most profitable?
SELECT
pt.plan_type,
sum(profit) AS profit
FROM fact_insurance f
JOIN dim_policy p
ON f.policy_key = p.policy_key
JOIN dim_plan_type pt
ON p.plan_key = pt.plan_key
GROUP BY pt.plan_type
ORDER BY profit DESC;

-- Which network tier has the highest claims

SELECT
nt.network_tier,
AVG(f.total_claims_paid) AS avg_claims
FROM fact_insurance f
JOIN dim_policy p
ON f.policy_key = p.policy_key
JOIN dim_network_tier nt
ON p.tier_key = nt.tier_key
GROUP BY nt.network_tier
ORDER BY avg_claims DESC;

-- Impact of deductible on cost 

SELECT
CASE
WHEN deductible < 500 THEN 'Low'
WHEN deductible < 1500 THEN 'Medium'
ELSE 'High'
END AS deductible_group,

AVG(f.total_claims_paid) AS avg_claims
FROM fact_insurance f
JOIN dim_policy p
ON f.policy_key = p.policy_key
GROUP BY deductible_group;

-- 7- High Risk analysis 

-- High-risk customer percentage

SELECT
ROUND(
100.0 * SUM(CASE WHEN is_high_risk='True' THEN 1 ELSE 0 END)
/ COUNT(*),2
) AS high_risk_percentage
FROM fact_insurance;

-- High-risk cost impact 

SELECT
is_high_risk,
AVG(annual_medical_cost) avg_cost,
AVG(total_claims_paid) avg_claims
FROM fact_insurance
GROUP BY is_high_risk;

-- Risk segment distribution

SELECT
risk_segment,
COUNT(*) customers
FROM fact_insurance
GROUP BY risk_segment
ORDER BY customers DESC;

-- 8- Utilization Analysis 

-- Which procedures are used most?

SELECT
AVG(proc_imaging_count) imaging,
AVG(proc_surgery_count) surgery,
AVG(proc_consult_count) consult,
AVG(proc_lab_count) lab
FROM fact_insurance;

-- Hospitalization Impact

SELECT
CASE
WHEN hospitalizations_last_3yrs > 0
THEN 'Hospitalized'
ELSE 'Not Hospitalized'
END AS status,

AVG(annual_medical_cost) avg_cost
FROM fact_insurance
GROUP BY status;


-- 9- Sicioeconomic Analysis

-- Income VS Risk score 

SELECT
s.income,
AVG(f.risk_score) avg_risk
FROM fact_insurance f
JOIN dim_socioeconomic s
ON f.socio_key = s.socio_key
GROUP BY s.income
ORDER BY s.income;


-- Education level Analysis

SELECT
s.education,
AVG(f.annual_medical_cost) avg_cost,
AVG(f.risk_score) avg_risk
FROM fact_insurance f
JOIN dim_socioeconomic s
ON f.socio_key = s.socio_key
GROUP BY s.education;



-- 10- Business Insights

-- top 10 most expensive customers

SELECT
insurance_id,
annual_medical_cost
FROM fact_insurance
ORDER BY annual_medical_cost DESC
LIMIT 10;


-- loss ratio by plan type

SELECT
pt.plan_type,
ROUND(
SUM(f.total_claims_paid) /
SUM(f.annual_premium),2
) AS loss_ratio
FROM fact_insurance f
JOIN dim_policy p
ON f.policy_key = p.policy_key
JOIN dim_plan_type pt
ON p.plan_key = pt.plan_key
GROUP BY pt.plan_type
ORDER BY loss_ratio DESC;


-- Most profitable customers segment

SELECT
    p.`age group`,
    SUM(profit) AS profit
FROM fact_insurance f
JOIN dim_person_info p
    ON f.person_info_key = p.person_info_key
GROUP BY p.`age group`
ORDER BY profit DESC;


-- Loss ratio by risk segment 

SELECT
    risk_segment,
    ROUND(
        SUM(total_claims_paid) /
        SUM(annual_premium),2
    ) AS loss_ratio
FROM fact_insurance
GROUP BY risk_segment
ORDER BY loss_ratio DESC;


-- chronic diseases driving claims

SELECT
    chronic_count,
    AVG(total_claims_paid) avg_claims
FROM fact_insurance f
JOIN dim_chronic c
    ON f.chronic_key = c.chronic_key
GROUP BY chronic_count
ORDER BY chronic_count DESC;


-- Smoking Impact on claims

SELECT
    l.smoker,
    AVG(total_claims_paid) avg_claims,
    AVG(risk_score) avg_risk
FROM fact_insurance f
JOIN dim_lifestyle l
    ON f.lifestile_key = l.lifestile_key
GROUP BY l.smoker;


-- plan tyoe + network tier Matrix

SELECT
    pt.plan_type,
    nt.network_tier,
    AVG(f.total_claims_paid) avg_claims
FROM fact_insurance f
JOIN dim_policy p
    ON f.policy_key = p.policy_key
JOIN dim_plan_type pt
    ON p.plan_key = pt.plan_key
JOIN dim_network_tier nt
    ON p.tier_key = nt.tier_key
GROUP BY
    pt.plan_type,
    nt.network_tier
ORDER BY avg_claims DESC;

------------- 

