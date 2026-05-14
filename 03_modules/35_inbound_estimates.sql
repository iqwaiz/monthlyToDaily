------------------------------------------------------------
-- daily_inbound_estimates
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_inbound_estimates
(
    @start_date DATE = '2020-01-01'
)
AS
BEGIN
    SET NOCOUNT ON;





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
WHERE date_estimate >= @start_date
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
WHERE date_estimate >= @start_date
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
		d.DateFormat1 >= @start_date
		and YTD_Source = 'Estimated'
		and TOURIST_TYPE = 'Inbound'
		and purpose != 'Hajj'
),t1_months as (
	SELECT DISTINCT year, month
    FROM daily_inbound_estimates
), t1_data as (
	select
		t.data_type,
	    t.date,
	    t.year,
	    t.month,
	    t.day,
	    t.country,
	    t.purpose,
	    t.daily_visits,
	    t.daily_spend
    from daily_inbound_estimates t
),t2_data as (
	SELECT 
		t.data_type,
	    t.date,
	    t.year,
	    t.month,
	    t.day,
	    t.country,
	    t.purpose,
	    t.daily_visits,
	    t.daily_spend
    FROM flows_estimates t
    WHERE NOT EXISTS (
        SELECT 1
        FROM t1_months t1m
        WHERE t.year = t1m.year
          AND t.month = t1m.month
    )
),combined as(
	SELECT * FROM t1_data
    UNION ALL
    SELECT * FROM t2_data
)SELECT * INTO #result FROM combined;


EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;





END;