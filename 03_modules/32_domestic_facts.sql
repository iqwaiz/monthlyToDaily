------------------------------------------------------------
-- daily_domestic_facts
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_domestic_facts
AS
BEGIN
    SET NOCOUNT ON;








declare @start_date date = '2024-01-01';

DECLARE @T SYSNAME = 'daily_domestic_facts';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;

with monthly_domestic_facts as( -- mt.mas.MAS_DOMESTICS_INC_VW
select 
	'domestic_fact' as data_type,
	YEAR as year,
	MONTH_NUM as month,
	'Saudi Arabia' as country,
	VISIT_PURPOSE_EN as purpose,
	sum(TRIPS) as monthly_visits,
	sum(NIGHTS) as monthly_nights,
	sum(SPEND_SAR) as monthly_spend,
	DAY(EOMONTH(DATEFROMPARTS(YEAR, MONTH_NUM, 1))) as days_in_month
--	sum(TRIPS)/DAY(EOMONTH(DATEFROMPARTS(YEAR, MONTH_NUM, 1))) as mas_avg_daily_visits,
	-- percentage weight of this purpose within the same year-month-country
--    sum(TRIPS) * 1.0 / sum(sum(TRIPS)) OVER (partition by YEAR, MONTH_NUM) as purpose_weight

from mt.mas.MAS_DOMESTICS_INC_VW
where 
	TRIP_TYPE_EN='tourist trip'
	and VISIT_PURPOSE_EN != 'Hajj'
	and year >= year(@start_date)
	and MONTH_NUM >= month(@start_date)
group by
	YEAR,
	MONTH_NUM,
	-- ORIGIN_COUNTRY_NAME_EN,
	VISIT_PURPOSE_EN
),daily_domestic_facts as (
select
	mf.data_type,
	DATEFROMPARTS(mf.year, mf.month, d.[DayofMonth]) as date,
	mf.year,
	mf.month,
	d.[DayofMonth] as day,
	mf.country,
	mf.purpose,
	mf.monthly_visits,
	mf.monthly_nights,
	mf.monthly_spend,
	mf.days_in_month,
	
	1.0 * mf.monthly_visits / mf.days_in_month as daily_visits,
    1.0 * mf.monthly_nights / mf.days_in_month as daily_nights,
    1.0 * mf.monthly_spend / mf.days_in_month as daily_spend
	
from monthly_domestic_facts mf
join SIDR.dbo.DIM_DATE d
    on d.[YEAR] = mf.[year] and d.[MONTH] = mf.month

)select * into #result from daily_domestic_facts

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;



END;