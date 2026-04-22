------------------------------------------------------------
-- daily_inbound_facts
------------------------------------------------------------

DECLARE @start_year int = 2024;



IF OBJECT_ID('tempdb..#border') IS NOT NULL DROP TABLE #border;
with monthly_border as (
	select
		YEAR(TRAVEL_DATE) as year,
	    MONTH(TRAVEL_DATE) as month,
	--    FROM_COUNTRY_NAME_EN as country,
	    NATIONALITY_COUNTRY_EN as country,
	    sum(NUMBER_OF_TOURIST) as border_monthly_visits

	    from MT.tdp.BOARDER_INBOUND_VW
		-- where year(TRAVEL_DATE) >= @start_year
		group by
		    YEAR(TRAVEL_DATE),
		    MONTH(TRAVEL_DATE),
		    --FROM_COUNTRY_NAME_EN
		    NATIONALITY_COUNTRY_EN
),
daily_border as ( -- MT.tdp.BOARDER_INBOUND_VW
select
    YEAR(TRAVEL_DATE) as year,
    MONTH(TRAVEL_DATE) as month,
    DAY(TRAVEL_DATE) as day,
--    FROM_COUNTRY_NAME_EN as country,
    NATIONALITY_COUNTRY_EN as country,
    sum(NUMBER_OF_TOURIST) as border_daily_visits
    

from MT.tdp.BOARDER_INBOUND_VW
-- where year(TRAVEL_DATE) >= @start_year
group by
    YEAR(TRAVEL_DATE),
    MONTH(TRAVEL_DATE),
    DAY(TRAVEL_DATE),
    --FROM_COUNTRY_NAME_EN
    NATIONALITY_COUNTRY_EN
),
border as (
	SELECT
	    d.*,
	    m.border_monthly_visits,
	    1.0 * d.border_daily_visits / m.border_monthly_visits AS border_daily_ratio
	FROM daily_border d
	JOIN monthly_border m
	    ON m.year    = d.year
	   AND m.month   = d.month
	   AND m.country = d.country
)select * into #border from border


IF OBJECT_ID('tempdb..#daily_inbound_facts') IS NOT NULL DROP TABLE #daily_inbound_facts;
with inbound_visits_facts as( -- mt.mas.MAS_INBOUND_INC_VW
	select 
		'fact_inbound' as data_type,
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
		and year >= @start_year
	group by
		YEAR,
		MONTH_NUM,
		ORIGIN_COUNTRY_NAME_EN,
		VISIT_PURPOSE_EN
),daily_inbound_facts as (
	select
		m.data_type,
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
	    m.monthly_visits * b.border_daily_ratio as mas_daily_visits,
	    m.monthly_nights * b.border_daily_ratio as mas_daily_nights,
	    m.monthly_spend * b.border_daily_ratio as mas_daily_spend
	
	from inbound_visits_facts m
	left join #border b
	    on m.year = b.year
	    and m.month = b.month
	    and m.country = b.country
)select * into #daily_inbound_facts from daily_inbound_facts

select * from #daily_inbound_facts


