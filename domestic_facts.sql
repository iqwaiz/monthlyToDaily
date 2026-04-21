DECLARE @start_year int = 2024;


with mas_dom_visits as( -- mt.mas.MAS_DOMESTICS_INC_VW
select 
	'fact_domestics' as data_type,
	YEAR as year,
	MONTH_NUM as month,
	'Saudi Arabia' as country,
	VISIT_PURPOSE_EN as purpose,
	sum(TRIPS) as mas_monthly_visitors,
	sum(NIGHTS) as mas_monthly_nights,
	sum(SPEND_SAR) as spend,
	sum(TRIPS)/DAY(EOMONTH(DATEFROMPARTS(YEAR, MONTH_NUM, 1))) as mas_avg_daily_visits,
	-- percentage weight of this purpose within the same year-month-country
    sum(TRIPS) * 1.0 / sum(sum(TRIPS)) OVER (partition by YEAR, MONTH_NUM) as purpose_weight

from mt.mas.MAS_DOMESTICS_INC_VW
where 
	TRIP_TYPE_EN='tourist trip'
	and VISIT_PURPOSE_EN != 'Hajj'
	and year >= 2024 --@start_year
group by
	YEAR,
	MONTH_NUM,
	-- ORIGIN_COUNTRY_NAME_EN,
	VISIT_PURPOSE_EN
)

--create temp table t1 as 
select * from mas_dom_visits



