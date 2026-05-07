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


with mas_facts as( -- mt.mas.MAS_INBOUND_INC_VW
	select 
		'inbound_fact_mas' as data_type,
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
		and DATEFROMPARTS(YEAR, MONTH_NUM, 1) >= @start_date
	group by
		YEAR,
		MONTH_NUM,
		ORIGIN_COUNTRY_NAME_EN,
		VISIT_PURPOSE_EN
),daily_mas_facts as (
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
	
	from mas_facts m
	left join ibraheem_test.dailyData.border b
	    on m.year = b.year
	    and m.month = b.month
	    and m.country = b.country
),flows_facts as( --[MT].[estimates].[TOURISM_FLOWS_YTD_TBL]
select 
	'inbound_fact_flows' as data_type,
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
	YTD_Source = 'DS Official'
	and TOURIST_TYPE = 'Inbound'
),combined as(
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
FROM flows_facts t1
FULL OUTER JOIN daily_mas_facts t2
    ON  t1.date = t2.date
    AND t1.country = t2.country 
    AND t1.purpose = t2.purpose
)
select * into #result from combined

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;






END;