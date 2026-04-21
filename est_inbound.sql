------------------------------------------------------------
-- daily_inbound_estimates
------------------------------------------------------------


DECLARE @inbound_fact_end_date date;-- = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

--SELECT @inbound_fact_end_date = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]  WITH (NOLOCK);
set @inbound_fact_end_date = '2025-11-01';


IF OBJECT_ID('tempdb..#targets') IS NOT NULL DROP TABLE #targets;
with targets AS (
    SELECT
        vt.Year AS year,
        vt.MonthNo AS month,
        vt.Country AS country,
        vt.BU,
        vt.Purpose AS purpose,
        vt.Committed_value AS visits_target,
        st.Committed_value AS spend_target
    FROM [SIDR].[Business_Review].[Fact_Visits_Target] vt
    JOIN [SIDR].[Business_Review].[Fact_Spend_Target] st
          ON  st.Year    = vt.Year
          AND st.MonthNo = vt.MonthNo
          AND st.Country = vt.Country
          AND st.BU      = vt.BU
          AND st.Purpose = vt.Purpose
)SELECT * INTO #targets FROM targets;


IF OBJECT_ID('tempdb..#daily_inbound_estimates') IS NOT NULL DROP TABLE #daily_inbound_estimates;
with inbound_visit_estimates as(
	SELECT
		est.date_estimate,
		--r.Busines_Unit,
		est.origin_country,
        est.purpose,
		SUM(est.border_visits_estimate_coeffeicient) as visits,
        SUM(est.alos * est.border_visits_estimate_coeffeicient) as nights
	FROM [ANALYTICS].[dbo].[INBOUND_VISITS_ESTIMATION] as est with(nolock)
	--LEFT JOIN SIDR.dbo.Ref_Country as c
	--ON est.origin_country = c.Country_Name_En
	--LEFT JOIN [SIDR].[dbo].[Rel_BU_level_Country] as r with(nolock)
	--ON r.Country_Key = c.country_key
	WHERE est.date_estimate > @inbound_fact_end_date
	AND est.purpose <> 'Hajj'
	GROUP BY
		est.date_estimate,
		--r.Busines_Unit,
		est.origin_country,
		est.purpose
),
inbound_spend_estimates as (
	SELECT 
		est.date_estimate,
		--r.Busines_Unit,
		est.origin_country,
        est.purpose,
		SUM(est.spend_estimate_coeffeicient) as spend
	FROM [ANALYTICS].[dbo].[INBOUND_SPEND_ESTIMATION] as est with(nolock)
	--LEFT JOIN SIDR.dbo.Ref_Country as c
	--ON est.origin_country = c.Country_Name_En
	--LEFT JOIN [SIDR].[dbo].[Rel_BU_level_Country] as r with(nolock)
	--ON r.Country_Key = c.country_key
	WHERE est.date_estimate > @inbound_fact_end_date
	AND est.purpose <> 'Hajj'
	GROUP BY
		est.date_estimate,
		--r.Busines_Unit,
		est.origin_country,
		est.purpose

),
monthly_inbound_estimates as(
	select
		'est_inbound' as data_type,
	    v.date_estimate as date,
	    YEAR(v.date_estimate) as year,
	    MONTH(v.date_estimate) as month,
	    -- day(EOMONTH(DATEFROMPARTS(year(v.date_estimate), month(v.date_estimate), 1))) as days_in_month,
	    DAY(EOMONTH(v.date_estimate)) as days_in_month,
	    v.purpose,
	    v.origin_country as country,
	    b.Busines_Unit as BU,
	    v.visits,
	    s.spend,
	    v.nights,
        t.visits_target,
        t.spend_target
	FROM inbound_visit_estimates v
	LEFT JOIN inbound_spend_estimates s
	    ON v.date_estimate = s.date_estimate
	   AND v.origin_country = s.origin_country
	   AND v.purpose = s.purpose
	LEFT JOIN SIDR.dbo.Ref_Country c
	    ON v.origin_country = c.Country_Name_En
	LEFT JOIN SIDR.dbo.Rel_BU_level_Country b WITH (NOLOCK)
	    ON b.Country_Key = c.country_key
    LEFT JOIN #targets t
		ON t.year    = YEAR(v.date_estimate)
		AND t.month   = MONTH(v.date_estimate)
		AND t.country = v.origin_country
		AND t.BU      = b.Busines_Unit
		AND t.purpose = v.purpose
), daily_inbound_estimates as(
	select
	    m.data_type,
--	    m.date,
--	    DATEADD(DAY, d.day - 1, m.date) as full_date,
	    DATEFROMPARTS(m.year, m.month, d.day) as full_date,
	    m.year,
	    m.month,
	    d.day,
--	    m.days_in_month,
	    m.purpose,
	    m.country,
	    m.BU,
	    m.visits / m.days_in_month as visits_daily,
	    m.spend  / m.days_in_month as spend_daily,
	    m.nights / m.days_in_month as nights_daily,
	    m.visits_target / m.days_in_month as visits_target,
        m.spend_target  / m.days_in_month as spend_target
	FROM monthly_inbound_estimates m
	CROSS APPLY (
	    SELECT TOP (m.days_in_month)
	           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as day
	    FROM master..spt_values
	) d
)SELECT * INTO #daily_inbound_estimates FROM daily_inbound_estimates;




SELECT * FROM #daily_inbound_estimates;
--SELECT * FROM #targets;



















