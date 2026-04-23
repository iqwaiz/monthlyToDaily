------------------------------------------------------------
-- daily_domestic_estimates
------------------------------------------------------------

declare @domestic_estimates_start date;
set @domestic_estimates_start = '2025-11-01';

IF OBJECT_ID('tempdb..#daily_domestic_estimates') IS NOT NULL DROP TABLE #daily_domestic_estimates;
select
	'domestic_estimate' as data_type,
	d.DayDate as date,
	d.[YEAR] as year,
	d.[MONTH] as month,
	d.[DayofMonth] as day,
	s.PURPOSE as purpose,
	'Saudi Arabia' as country,
	s.Visitors_YTD as visits,
	s.Spend_YTD as spend
into #daily_domestic_estimates
from [MT].[estimates].[TOURISM_FLOWS_YTD_TBL] s
left join SIDR.dbo.DIM_DATE d
on s.DATE_KEY = d.ID_Day
where
	TOURIST_TYPE = 'Domestic'
	and PURPOSE != 'Hajj'
	and d.DayDate >= @domestic_estimates_start
	
select * from #daily_domestic_estimates;

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable 'daily_domestic_estimates';