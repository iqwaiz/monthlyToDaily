------------------------------------------------------------
-- daily_inbound_estimates
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_inbound_estimates
AS
BEGIN
    SET NOCOUNT ON;







DECLARE @inbound_estimates_start date;

set @inbound_estimates_start = '2024-01-01';

DECLARE @T SYSNAME = 'daily_inbound_estimates';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;

with monthly_inbound_estimates as(
	SELECT
		'inbound_analytics_estimates' as data_type,
		v.date_estimate,
		YEAR(v.date_estimate) as year,
	    MONTH(v.date_estimate) as month,
	    DAY(EOMONTH(v.date_estimate)) as days_in_month,
		v.origin_country  as country,
        v.purpose,
		SUM(v.border_visits_estimate_coeffeicient) as visits,
        SUM(v.alos * v.border_visits_estimate_coeffeicient) as nights,
        SUM(s.spend_estimate_coeffeicient) as spend
	FROM [ANALYTICS].[dbo].[INBOUND_VISITS_ESTIMATION] as v with(nolock)
	LEFT JOIN [ANALYTICS].[dbo].[INBOUND_SPEND_ESTIMATION] as s with(nolock)
		ON v.date_estimate = s.date_estimate
	   AND v.origin_country = s.origin_country
	   AND v.purpose = s.purpose
	WHERE v.date_estimate >= @inbound_estimates_start
	AND v.purpose <> 'Hajj'
	GROUP BY
		v.date_estimate,
		v.origin_country,
		v.purpose
), daily_inbound_estimates as (
	select
	    m.data_type,
	    DATEFROMPARTS(m.year, m.month, d.[DayofMonth]) as date,
	    m.year,
	    m.month,
	    d.[DayofMonth] as day,
	    m.purpose,
	    m.country,
	    m.visits / m.days_in_month as daily_visits,
	    m.spend  / m.days_in_month as daily_spend,
	    m.nights / m.days_in_month as daily_nights
	FROM monthly_inbound_estimates m
	join SIDR.dbo.DIM_DATE d
	    on d.[YEAR] = m.[year] and d.[MONTH] = m.month
), flows_estimates as (
	select 
		'inbound_flows_estimates' as data_type,
		d.DateFormat1 as date,
		d.[YEAR] as year,
		d.[MONTH] as month,
		d.DayofMonth as day,
		f.[FROM_COUNTRY] as country,
		f.PURPOSE as purpose,
		f.Visitors_YTD as daily_visits,
		f.Spend_YTD as daily_spend
	from [MT].[estimates].[TOURISM_FLOWS_YTD_TBL] f
	left join SIDR.dbo.DIM_DATE d
		on f.DATE_KEY = d.ID_Day	
	where
		YTD_Source = 'Estimated'
		and TOURIST_TYPE = 'Inbound'
), combined as (
	SELECT 
		COALESCE(t1.data_type, t2.data_type) AS data_type,
	    COALESCE(t1.date, t2.date) AS date,
	    COALESCE(t1.year, t2.year) AS year,
	    COALESCE(t1.month, t2.month) AS month,
	    COALESCE(t1.day, t2.day) AS day,
	    COALESCE(t1.country, t2.country) AS country,
	    COALESCE(t1.purpose, t2.purpose) AS purpose,
	    COALESCE(t1.daily_visits, t2.daily_visits) AS daily_visits,
	    COALESCE(t1.daily_spend, t2.daily_spend) AS daily_spend
	FROM daily_inbound_estimates t1
	FULL OUTER JOIN flows_estimates t2
	    ON  t1.date = t2.date
	    AND t1.country = t2.country 
	    AND t1.purpose = t2.purpose
)SELECT * INTO #result FROM combined;


EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;





END;