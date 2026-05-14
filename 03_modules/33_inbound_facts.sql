------------------------------------------------------------
-- daily_inbound_facts
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_daily_inbound_facts
(
    @start_date DATE = '2020-01-01'
)
AS
BEGIN
    SET NOCOUNT ON;







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
	and purpose != 'Hajj'
),t1_months as (
	SELECT DISTINCT year, month
    FROM flows_facts
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
    from flows_facts t
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
    FROM daily_mas_facts t
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
)
select * into #result from combined

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;






END;