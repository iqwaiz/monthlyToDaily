

IF OBJECT_ID('tempdb..#border') IS NOT NULL DROP TABLE #border;
with border as ( -- MT.tdp.BOARDER_INBOUND_VW
select
    YEAR(TRAVEL_DATE) as year,
    MONTH(TRAVEL_DATE) as month,
    DAY(TRAVEL_DATE) as day,
--    FROM_COUNTRY_NAME_EN as country,
    NATIONALITY_COUNTRY_EN as country,
    sum(NUMBER_OF_TOURIST) as border_daily_visits,
    
    sum(sum(NUMBER_OF_TOURIST)) OVER (
        partition by 
            YEAR(TRAVEL_DATE),
            MONTH(TRAVEL_DATE),
            --FROM_COUNTRY_NAME_EN
            NATIONALITY_COUNTRY_EN
    ) as border_monthly_visits,
    
    -- daily percentage of monthly total
    (1.0 * sum(NUMBER_OF_TOURIST)) / sum(sum(NUMBER_OF_TOURIST)) OVER (
    partition by 
                YEAR(TRAVEL_DATE),
                MONTH(TRAVEL_DATE),
                --FROM_COUNTRY_NAME_EN
                NATIONALITY_COUNTRY_EN
        ) as border_daily_ratio

from MT.tdp.BOARDER_INBOUND_VW
-- where year(TRAVEL_DATE) >= @start_year
group by
    YEAR(TRAVEL_DATE),
    MONTH(TRAVEL_DATE),
    DAY(TRAVEL_DATE),
    --FROM_COUNTRY_NAME_EN
    NATIONALITY_COUNTRY_EN
) select * into #border from border 

select * from #border


-----------





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

select * from #border