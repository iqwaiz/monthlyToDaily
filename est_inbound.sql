DECLARE @inbound_fact_end_date date = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

SELECT @inbound_fact_end_date = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW];


with inbound_visit_estimates as(
	SELECT
		[date_estimate],
		year(date_estimate) as year,
		month(date_estimate) as month,
		[Busines_Unit], 
		[origin_country], 
		[purpose], 
		SUM([border_visits_estimate_coeffeicient]) AS VISITORS, 
		SUM([alos]*[border_visits_estimate_coeffeicient]) AS NIGHTS
	FROM [ANALYTICS].[dbo].[INBOUND_VISITS_ESTIMATION] as est with(nolock)
	LEFT JOIN SIDR.dbo.Ref_Country as c
	ON est.[origin_country] = c.Country_Name_En
	LEFT JOIN [SIDR].[dbo].[Rel_BU_level_Country] as r with(nolock)
	ON r.Country_Key = c.country_key
	WHERE [date_estimate] > @inbound_fact_end_date  AND [purpose] <> 'Hajj'
	GROUP BY [date_estimate], [Busines_Unit], [origin_country], [purpose]
),
inbound_spend_estimates as (
	SELECT 
		[date_estimate], 
		[Busines_Unit], 
		[origin_country],
		[purpose], 
		SUM([spend_estimate_coeffeicient]) AS SPEND
	FROM [ANALYTICS].[dbo].[INBOUND_SPEND_ESTIMATION] as est with(nolock)
	LEFT JOIN SIDR.dbo.Ref_Country as c
	ON est.[origin_country] = c.Country_Name_En
	LEFT JOIN [SIDR].[dbo].[Rel_BU_level_Country] as r with(nolock)
	ON r.Country_Key = c.country_key
	WHERE [date_estimate] > @inbound_fact_end_date  AND [purpose] <> 'Hajj'
	GROUP BY [date_estimate], [Busines_Unit], [origin_country], [purpose]
),
inbound_estimates as(
	select
		'est_inbound' as data_type,
		year,
		month,
		day(EOMONTH(DATEFROMPARTS(year, month, 1))) as days_in_month,
		a.purpose, --as VISIT_PURPOSE_EN,
		a.origin_country as country,
		a.busines_Unit,
		a.VISITORS as visits,
		b.SPEND as spend,
		a.NIGHTS as nights
	from inbound_visit_estimates a
	left join inbound_spend_estimates b on a.date_estimate = b.date_estimate and a.busines_Unit = b.busines_Unit and a.origin_country = b.origin_country and a.purpose =b.purpose -- and a.data_type = b.data_type
)select * from inbound_estimates

-------



DECLARE @inbound_fact_end_date date;-- = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

SELECT @inbound_fact_end_date = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]  WITH (NOLOCK);


with inbound_visit_estimates as(
	SELECT
		est.date_estimate,
		r.Busines_Unit,
		est.origin_country,
        est.purpose,
		SUM(est.border_visits_estimate_coeffeicient) AS visits,
        SUM(est.alos * est.border_visits_estimate_coeffeicient) AS nights
	FROM [ANALYTICS].[dbo].[INBOUND_VISITS_ESTIMATION] as est with(nolock)
	LEFT JOIN SIDR.dbo.Ref_Country as c
	ON est.origin_country = c.Country_Name_En
	LEFT JOIN [SIDR].[dbo].[Rel_BU_level_Country] as r with(nolock)
	ON r.Country_Key = c.country_key
	WHERE est.date_estimate > @inbound_fact_end_date
	AND est.purpose <> 'Hajj'
	GROUP BY
		est.date_estimate,
		r.Busines_Unit,
		est.origin_country,
		est.purpose
),
inbound_spend_estimates as (
	SELECT 
		est.date_estimate,
		r.Busines_Unit,
		est.origin_country,
        est.purpose,
		SUM(est.spend_estimate_coeffeicient) as spend
	FROM [ANALYTICS].[dbo].[INBOUND_SPEND_ESTIMATION] as est with(nolock)
	LEFT JOIN SIDR.dbo.Ref_Country as c
	ON est.origin_country = c.Country_Name_En
	LEFT JOIN [SIDR].[dbo].[Rel_BU_level_Country] as r with(nolock)
	ON r.Country_Key = c.country_key
	WHERE est.date_estimate > @inbound_fact_end_date
	AND est.purpose <> 'Hajj'
	GROUP BY
		est.date_estimate,
		r.Busines_Unit,
		est.origin_country,
		est.purpose

),
inbound_estimates as(
	select
		'est_inbound' as data_type,
		year(a.date_estimate) as year,
		month(a.date_estimate) as month,
--		day(EOMONTH(DATEFROMPARTS(year(a.date_estimate), month(a.date_estimate), 1))) as days_in_month,
		a.purpose, --as VISIT_PURPOSE_EN,
		a.origin_country as country,
		a.Busines_Unit,
		a.visits,
		b.spend,
		a.nights
	from inbound_visit_estimates a
	left join inbound_spend_estimates b on a.date_estimate = b.date_estimate and a.busines_Unit = b.busines_Unit and a.origin_country = b.origin_country and a.purpose =b.purpose -- and a.data_type = b.data_type
)select * from inbound_estimates

-------------



DECLARE @inbound_fact_end_date date;-- = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

--SELECT @inbound_fact_end_date = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]  WITH (NOLOCK);
set @inbound_fact_end_date = '2025-11-01';

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
inbound_estimates as(
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
	    v.nights
	FROM inbound_visit_estimates v
	LEFT JOIN inbound_spend_estimates s
	    ON v.date_estimate = s.date_estimate
	   AND v.origin_country = s.origin_country
	   AND v.purpose = s.purpose
	LEFT JOIN SIDR.dbo.Ref_Country c
	    ON v.origin_country = c.Country_Name_En
	LEFT JOIN SIDR.dbo.Rel_BU_level_Country b WITH (NOLOCK)
	    ON b.Country_Key = c.country_key
)select * from inbound_estimates






------------ daily


DECLARE @inbound_fact_end_date date;-- = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

--SELECT @inbound_fact_end_date = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]  WITH (NOLOCK);
set @inbound_fact_end_date = '2025-11-01';

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
	    v.nights
	FROM inbound_visit_estimates v
	LEFT JOIN inbound_spend_estimates s
	    ON v.date_estimate = s.date_estimate
	   AND v.origin_country = s.origin_country
	   AND v.purpose = s.purpose
	LEFT JOIN SIDR.dbo.Ref_Country c
	    ON v.origin_country = c.Country_Name_En
	LEFT JOIN SIDR.dbo.Rel_BU_level_Country b WITH (NOLOCK)
	    ON b.Country_Key = c.country_key
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
	    m.visits / m.days_in_month AS visits_daily,
	    m.spend  / m.days_in_month AS spend_daily,
	    m.nights / m.days_in_month AS nights_daily
	FROM monthly_inbound_estimates m
	CROSS APPLY (
	    SELECT TOP (m.days_in_month)
	           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as day
	    FROM master..spt_values
	) d
)
select * from daily_inbound_estimates




---------- daily with targets




DECLARE @inbound_fact_end_date date;-- = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

--SELECT @inbound_fact_end_date = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]  WITH (NOLOCK);
set @inbound_fact_end_date = '2025-11-01';

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
targets as (
	select
	    vt.Year as year,
	    vt.MonthNo as month,
	    vt.Country as country,
	    vt.BU,
	    vt.Purpose as purpose,
	    vt.Committed_value as visits_target,
	    st.Committed_value as spend_target
	FROM [SIDR].[Business_Review].[Fact_Visits_Target] vt
	JOIN [SIDR].[Business_Review].[Fact_Spend_Target] st
	      ON  st.Year      = vt.Year
	      AND st.MonthNo   = vt.MonthNo
	      AND st.Country   = vt.Country
	      AND st.BU        = vt.BU
	      AND st.Purpose   = vt.Purpose
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
    LEFT JOIN targets t
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
)
select * from daily_inbound_estimates







------- with temp tables



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
targets as (
	select
	    vt.Year as year,
	    vt.MonthNo as month,
	    vt.Country as country,
	    vt.BU,
	    vt.Purpose as purpose,
	    vt.Committed_value as visits_target,
	    st.Committed_value as spend_target
	FROM [SIDR].[Business_Review].[Fact_Visits_Target] vt
	JOIN [SIDR].[Business_Review].[Fact_Spend_Target] st
	      ON  st.Year      = vt.Year
	      AND st.MonthNo   = vt.MonthNo
	      AND st.Country   = vt.Country
	      AND st.BU        = vt.BU
	      AND st.Purpose   = vt.Purpose
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
SELECT * FROM #targets;


































