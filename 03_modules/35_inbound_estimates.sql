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


IF OBJECT_ID('tempdb..#visits') IS NOT NULL DROP TABLE #visits;
SELECT
	date_estimate,
	year(date_estimate) as year,
	month(date_estimate) as month,
	origin_country  as country,
    purpose,
	SUM(border_visits_estimate_coeffeicient) as visits,
    SUM(alos * border_visits_estimate_coeffeicient) as nights,
    DAY(EOMONTH(date_estimate)) AS days_in_month
into #visits
FROM [ANALYTICS].[dbo].[INBOUND_VISITS_ESTIMATION] with(nolock)
WHERE date_estimate >= @inbound_estimates_start
AND purpose <> 'Hajj'
GROUP BY
	date_estimate,
	origin_country,
	purpose;


IF OBJECT_ID('tempdb..#spend') IS NOT NULL DROP TABLE #spend;
SELECT
	date_estimate,
	origin_country  as country,
    purpose,
    SUM(spend_estimate_coeffeicient) as spend
into #spend
FROM [ANALYTICS].[dbo].[INBOUND_SPEND_ESTIMATION] with(nolock)
WHERE date_estimate >= @inbound_estimates_start
AND purpose <> 'Hajj'
GROUP BY
	date_estimate,
	origin_country,
	purpose;
		
		
with daily_inbound_estimates as (
	select
		'inbound_analytics_estimates' as data_type,
	    DATEFROMPARTS(v.year, v.month, d.[DayofMonth]) as date,
	    v.year,
	    v.month,
	    d.[DayofMonth] as day,
	    v.purpose,
	    v.country,
	    v.visits / v.days_in_month as daily_visits,
	    s.spend  / v.days_in_month as daily_spend,
	    v.nights / v.days_in_month as daily_nights
	FROM #visits v
    LEFT JOIN #spend s ON v.date_estimate = s.date_estimate AND v.country = s.country AND v.purpose = s.purpose
	join SIDR.dbo.DIM_DATE d
	    -- on d.[YEAR] = v.year and d.[MONTH] = v.month
	    on d.DateFormat1 BETWEEN v.date_estimate AND EOMONTH(v.date_estimate)
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
		d.DateFormat1 >= @inbound_estimates_start
		and YTD_Source = 'Estimated'
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