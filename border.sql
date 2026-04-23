------------------------------------------------------------
-- border
------------------------------------------------------------

DECLARE @T SYSNAME = 'border';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;

WITH monthly_border AS (
    SELECT
        YEAR(TRAVEL_DATE) AS year,
        MONTH(TRAVEL_DATE) AS month,
        NATIONALITY_COUNTRY_EN AS country,
        SUM(NUMBER_OF_TOURIST) AS border_monthly_visits
    FROM MT.tdp.BOARDER_INBOUND_VW
    GROUP BY
        YEAR(TRAVEL_DATE),
        MONTH(TRAVEL_DATE),
        NATIONALITY_COUNTRY_EN
),
daily_border AS (
    SELECT
        YEAR(TRAVEL_DATE) AS year,
        MONTH(TRAVEL_DATE) AS month,
        DAY(TRAVEL_DATE) AS day,
        NATIONALITY_COUNTRY_EN AS country,
        SUM(NUMBER_OF_TOURIST) AS border_daily_visits
    FROM MT.tdp.BOARDER_INBOUND_VW
    GROUP BY
        YEAR(TRAVEL_DATE),
        MONTH(TRAVEL_DATE),
        DAY(TRAVEL_DATE),
        NATIONALITY_COUNTRY_EN
),
border AS (
    SELECT
    	DATEFROMPARTS(d.year, d.month, d.day) as date,
        d.*,
        m.border_monthly_visits,
        1.0 * d.border_daily_visits / m.border_monthly_visits AS border_daily_ratio
    FROM daily_border d
    JOIN monthly_border m
        ON m.year    = d.year
       AND m.month   = d.month
       AND m.country = d.country
)
SELECT * INTO #result FROM border;

-- SELECT * FROM #border;

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;
