------------------------------------------------------------
-- daily_domestic_estimates
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_domestic_estimates
(
    @start_date DATE = '2020-01-01'
)
AS
BEGIN
    SET NOCOUNT ON;







DECLARE @T SYSNAME = 'daily_domestic_estimates';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;

with daily_domestic_estimates as (select
	'domestic_estimate' as data_type,
	d.DayDate as date,
	d.[YEAR] as year,
	d.[MONTH] as month,
	d.[DayofMonth] as day,
	s.PURPOSE as purpose,
	'Saudi Arabia' as country,
	s.Visitors_YTD as daily_visits,
	s.Spend_YTD as daily_spend

from [MT].[estimates].[TOURISM_FLOWS_YTD_TBL] s
left join SIDR.dbo.DIM_DATE d
on s.DATE_KEY = d.ID_Day
where
	TOURIST_TYPE = 'Domestic'
	and YTD_Source = 'Estimated'
	and PURPOSE != 'Hajj'
	and d.DayDate >= @start_date
) 
select * into #result from daily_domestic_estimates;

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;



END;