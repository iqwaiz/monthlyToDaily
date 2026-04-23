------------------------------------------------------------
-- daily_inbound_facts
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_inbound_facts
AS
BEGIN
    SET NOCOUNT ON;







declare @start_date date = '2024-01-01';

DECLARE @T SYSNAME = 'daily_inbound_facts';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;


with inbound_visits_facts as( -- mt.mas.MAS_INBOUND_INC_VW
	select 
		'inbound_fact' as data_type,
		YEAR as year,
		MONTH_NUM as month,
		ORIGIN_COUNTRY_NAME_EN as country,
		VISIT_PURPOSE_EN as purpose,
		sum(TRIPS) as monthly_visits,
		sum(NIGHTS) as monthly_nights,
		sum(SPEND_SAR) as monthly_spend,
		sum(TRIPS)/DAY(EOMONTH(DATEFROMPARTS(YEAR, MONTH_NUM, 1))) as avg_daily_visits,
		-- percentage weight of this purpose within the same year-month-country
	    sum(TRIPS) * 1.0 / sum(sum(TRIPS)) OVER (partition by YEAR, MONTH_NUM, ORIGIN_COUNTRY_NAME_EN) as purpose_weight
	
	from mt.mas.MAS_INBOUND_INC_VW
	where 
		TRIP_TYPE_EN='tourist trip'
		and VISIT_PURPOSE_EN != 'Hajj'
		and year >= year(@start_date)
		and MONTH_NUM >= month(@start_date)
	group by
		YEAR,
		MONTH_NUM,
		ORIGIN_COUNTRY_NAME_EN,
		VISIT_PURPOSE_EN
),daily_inbound_facts as (
	select
		m.data_type,
		DATEFROMPARTS(m.year, m.month, b.day) as date,
	    m.year,
	    m.month,
	    b.day,
	    m.country,
	    m.purpose,
	    m.monthly_visits,
	    m.monthly_nights,
	    m.monthly_spend,
	    m.avg_daily_visits,
	--    m.purpose_weight,
	
	    b.border_daily_visits,
	    b.border_monthly_visits,
	    b.border_daily_ratio,
		
	    -- mas daily visits distributed by daily border weight + purpose weight
	    --m.monthly_visits * b.border_daily_ratio * m.purpose_weight as mas_daily_visits
	    m.monthly_visits * b.border_daily_ratio as daily_visits,
	    m.monthly_nights * b.border_daily_ratio as daily_nights,
	    m.monthly_spend * b.border_daily_ratio as daily_spend
	
	from inbound_visits_facts m
	left join ibraheem_test.dailyData.border b
	    on m.year = b.year
	    and m.month = b.month
	    and m.country = b.country
)select * into #result from daily_inbound_facts


EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;






END;