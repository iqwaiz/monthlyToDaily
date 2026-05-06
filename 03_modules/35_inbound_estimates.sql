------------------------------------------------------------
-- daily_inbound_estimates
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_inbound_estimates
AS
BEGIN
    SET NOCOUNT ON;








DECLARE @inbound_estimates_start date;-- = (SELECT MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]);

--SELECT @inbound_estimates_start = MAX(DATEFROMPARTS(YEAR, [MONTH_NUM],1)) FROM [MT].[mas].[MAS_INBOUND_INC_VW]  WITH (NOLOCK);
set @inbound_estimates_start = '2024-01-01';

DECLARE @T SYSNAME = 'daily_inbound_estimates';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;

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
	WHERE est.date_estimate >= @inbound_estimates_start
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
	WHERE est.date_estimate >= @inbound_estimates_start
	AND est.purpose <> 'Hajj'
	GROUP BY
		est.date_estimate,
		--r.Busines_Unit,
		est.origin_country,
		est.purpose

),
monthly_inbound_estimates as(
	select
		'inbound_estimate' as data_type,
	    v.date_estimate as date,
	    YEAR(v.date_estimate) as year,
	    MONTH(v.date_estimate) as month,
	    -- day(EOMONTH(DATEFROMPARTS(year(v.date_estimate), month(v.date_estimate), 1))) as days_in_month,
	    DAY(EOMONTH(v.date_estimate)) as days_in_month,
	    v.purpose,
	    v.origin_country as country,
	    -- b.Busines_Unit as BU,
	    v.visits,
	    s.spend,
	    v.nights
        -- t.visits_target,
        -- t.spend_target
	FROM inbound_visit_estimates v
	LEFT JOIN inbound_spend_estimates s
	    ON v.date_estimate = s.date_estimate
	   AND v.origin_country = s.origin_country
	   AND v.purpose = s.purpose
	LEFT JOIN SIDR.dbo.Ref_Country c
	    ON v.origin_country = c.Country_Name_En
	-- LEFT JOIN SIDR.dbo.Rel_BU_level_Country b WITH (NOLOCK)
	--     ON b.Country_Key = c.country_key
    -- LEFT JOIN ibraheem_test.dailyData.targets t
	-- 	ON t.year    = YEAR(v.date_estimate)
	-- 	AND t.month   = MONTH(v.date_estimate)
	-- 	AND t.country = v.origin_country
	-- 	AND t.BU      = b.Busines_Unit
	-- 	AND t.purpose = v.purpose
), daily_inbound_estimates as(
	select
	    m.data_type,
--	    m.date,
--	    DATEADD(DAY, d.day - 1, m.date) as full_date,
	    DATEFROMPARTS(m.year, m.month, d.[DayofMonth]) as date,
	    m.year,
	    m.month,
	    d.[DayofMonth] as day,
--	    m.days_in_month,
	    m.purpose,
	    m.country,
	    -- m.BU,
	    m.visits / m.days_in_month as daily_visits,
	    m.spend  / m.days_in_month as daily_spend,
	    m.nights / m.days_in_month as daily_nights
	    -- m.visits_target / m.days_in_month as visits_target,
        -- m.spend_target  / m.days_in_month as spend_target
	FROM monthly_inbound_estimates m
	join SIDR.dbo.DIM_DATE d
	    on d.[YEAR] = m.[year] and d.[MONTH] = m.month
)SELECT * INTO #result FROM daily_inbound_estimates;


EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;





END;