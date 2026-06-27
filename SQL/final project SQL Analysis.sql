-- 1- KPIs
/*Total aggregation: 100k customers, $58.2M premiums vs. $137.8M claims = -$79.6M loss (237% loss ratio). 
Avg medical cost ($3,009) is 5x avg premium ($582) – severe underpricing.*/

SELECT
COUNT(*) AS TOTAL_CUSTOMERS,
Sum(annual_premium) as Total_premiums,
sum(total_claims_paid) as total_claims_paid,
sum(profit) as profit,
avg(annual_medical_cost) as AVG_Medical_cost
FROM fact_insurance;

-- 2- CUSTOMER SEGMENTATION

-- Which age group has tha highest medical cost?
/*Seniors show the highest avg medical cost ($3,618.7) vs. Teens the lowest ($361.8), 
confirming age is a primary cost driver and justifying higher premiums for older age groups.*/

SELECT
p.`age group`,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.`age group`
ORDER BY avg_cost DESC;

-- Medical cost by gender
/*Medical costs are nearly identical across genders ($3,000–$3,020),
 indicating gender is not a significant cost driver.*/

SELECT
p.sex,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.sex;

-- Urban VS Rural utilization 
/*Suburban has highest cost ($3,023) and visits (1.94); regional differences are minimal.*/

SELECT
p.urban_rural,
AVG(f.visits_last_year) AS avg_visits,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.urban_rural;

-- Which regions are most expensive?
/*South highest ($3,044), Central lowest ($2,968); regional cost variation is minimal.*/

SELECT
p.region,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_person_info p
ON f.person_info_key = p.person_info_key
GROUP BY p.region
ORDER BY avg_cost DESC;


-- 3- LIFESTYLE ANALYSIS

-- Smokers VS non-smoker
/*Current smokers have highest cost ($4,296) and claims ($1,997), 
1.6x higher than Never smokers; smoking is a major cost driver.*/

SELECT
l.smoker,
AVG(f.annual_medical_cost) AS avg_cost,
AVG(f.total_claims_paid) AS avg_claims
FROM fact_insurance f
JOIN dim_lifestyle l
ON f.lifestile_key = l.lifestile_key
GROUP BY l.smoker;

-- BMI Category Impact
/*Obese has highest cost ($3,177) and risk (0.578); cost rises with BMI.*/

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
/*Alcohol frequency shows negligible cost impact ($2,990–$3,056);
 not a major cost driver.*/

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
/*Stage 2 Hypertension has highest cost ($3,883), Normal lowest ($2,653);
 BP severity drives costs.*/

SELECT
c.`BP category`,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_clinical c
ON f.clinical_key = c.clinical_key
GROUP BY c.`BP category`
ORDER BY avg_cost DESC;

-- Diabetes category VS Claims
/*Diabetes category has highest claims (2.69) and paid amount ($2,338), 
1.8x higher than Normal; diabetes is a major cost driver.*/

SELECT
c.`diabetes category`,
AVG(f.claims_count) AS avg_claims,
AVG(f.total_claims_paid) AS avg_claim_paid
FROM fact_insurance f
JOIN dim_clinical c
ON f.clinical_key = c.clinical_key
GROUP BY c.`diabetes category`;

-- LDL Category analysis 
/*Very High LDL costs most ($3,236), Optimal least ($2,958);
 higher LDL increases costs.*/

SELECT
c.`ldl category`,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_clinical c
ON f.clinical_key = c.clinical_key
GROUP BY c.`ldl category`;

-- 5- Chronic Disease Analysis 

-- Cost by chronic condition count
/*Cost rises sharply with chronic conditions: 6 conditions cost $18,748 vs. 0 at $2,176;
 chronic burden is the strongest cost driver.*/

SELECT
ch.chronic_count,
AVG(f.annual_medical_cost) AS avg_cost
FROM fact_insurance f
JOIN dim_chronic ch
ON f.chronic_key = ch.chronic_key
GROUP BY ch.chronic_count
ORDER BY ch.chronic_count DESC;

-- Top Diseases Driving Cost 
/*Diabetes ($4,105), Cardiovascular ($4,067), and Hypertension ($3,964) 
all drive similarly high costs, with diabetes the highest.*/

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
/*High Comorbidity costs double ($5,858 vs $2,928) but only 2.8% of customers;
 severe chronic clustering drives extreme costs.*/

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
/*All plans are unprofitable; POS loses least ($-11.9M), HMO most ($-28M).*/

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
/*Silver has highest avg claims ($1,389), Bronze lowest ($1,364);
 tier differences are minimal.*/

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
/*edium deductible claims ($1,390) slightly exceed High ($1,343);
 deductible impact is marginal.*/

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
/*High-risk customers represent 36.78% of the total book.*/

SELECT
ROUND(
100.0 * SUM(CASE WHEN is_high_risk='True' THEN 1 ELSE 0 END)
/ COUNT(*),2
) AS high_risk_percentage
FROM fact_insurance;

-- High-risk cost impact 
/*High-risk cost ($4,042) and claims ($2,153) are 1.7x and 2.3x higher than non-high-risk.*/

SELECT
is_high_risk,
AVG(annual_medical_cost) avg_cost,
AVG(total_claims_paid) avg_claims
FROM fact_insurance
GROUP BY is_high_risk;

-- Risk segment distribution
/*Medium Risk dominates (46%), High Risk is smallest (21%).*/

SELECT
risk_segment,
COUNT(*) customers
FROM fact_insurance
GROUP BY risk_segment
ORDER BY customers DESC;

-- 8- Utilization Analysis 

-- Which procedures are used most?
/*Consult/imaging/lab 0.51 avg each, surgery lowest at 0.16.*/

SELECT
AVG(proc_imaging_count) imaging,
AVG(proc_surgery_count) surgery,
AVG(proc_consult_count) consult,
AVG(proc_lab_count) lab
FROM fact_insurance;

-- Hospitalization Impact
/*Hospitalized cost nearly double ($5,029 vs $2,810).*/

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
/*No clear income-risk pattern; risk fluctuates inconsistently across income levels.*/

SELECT
s.income,
AVG(f.risk_score) avg_risk
FROM fact_insurance f
JOIN dim_socioeconomic s
ON f.socio_key = s.socio_key
GROUP BY s.income
ORDER BY s.income;


-- Education level Analysis
/*Education has minimal impact; No HS highest cost ($3,081) and risk (0.529).*/

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
/*Top cost $65.7K, 10th $51.1K.*/

SELECT
insurance_id,
annual_medical_cost
FROM fact_insurance
ORDER BY annual_medical_cost DESC
LIMIT 10;


-- loss ratio by plan type
/*Loss ratio 2.36 across all plans; HMO highest (2.39).*/

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
/*Only Teens profitable (+$486); Middle Age loses most (-$34.2M).*/

SELECT
    p.`age group`,
    SUM(profit) AS profit
FROM fact_insurance f
JOIN dim_person_info p
    ON f.person_info_key = p.person_info_key
GROUP BY p.`age group`
ORDER BY profit DESC;


-- Loss ratio by risk segment 
/*Loss ratio rises with risk: High 3.31, Medium 2.30, Low 1.50.*/

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
/*Avg claims rise sharply with chronic count: 0 = $632, 6+ = $20,868.*/

SELECT
    chronic_count,
    AVG(total_claims_paid) avg_claims
FROM fact_insurance f
JOIN dim_chronic c
    ON f.chronic_key = c.chronic_key
GROUP BY chronic_count
ORDER BY chronic_count DESC;


-- Smoking Impact on claims
/*Current smokers have highest claims ($1,997) and risk (0.737).*/

SELECT
    l.smoker,
    AVG(total_claims_paid) avg_claims,
    AVG(risk_score) avg_risk
FROM fact_insurance f
JOIN dim_lifestyle l
    ON f.lifestile_key = l.lifestile_key
GROUP BY l.smoker;


-- plan tyoe + network tier Matrix
/*PPO Platinum highest claims ($1,441), POS Platinum lowest ($1,323);
 plan-tier variation is minimal.*/

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

