------------------------------------------------------------
-- daily_domestic_facts
------------------------------------------------------------

declare @start_date date = '2024-01-01';

IF OBJECT_ID('tempdb..#daily_domestic_facts') IS NOT NULL DROP TABLE #daily_domestic_facts;
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
	data_type,
	year,
	month,
	country,
	purpose,
	monthly_visits,
	monthly_nights,
	monthly_spend,
	days_in_month,
	
	1.0 * monthly_visits / days_in_month as daily_visits,
    1.0 * monthly_nights / days_in_month as daily_nights,
    1.0 * monthly_spend / days_in_month as daily_spend
	
from monthly_domestic_facts mf

)select * into #daily_domestic_facts from daily_domestic_facts

select * from #daily_domestic_facts


EXEC ibraheem_test.dailyData.usp_UpsertDailyTable 'daily_domestic_facts';
