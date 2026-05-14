------------------------------------------------------------
-- all_daily_data
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_all_daily_data
(
    @start_date DATE = '2020-01-01'
)
AS
BEGIN
    SET NOCOUNT ON;






DECLARE @domestic_estimates_start date;
DECLARE @inbound_estimates_start date;

DECLARE @domestic_predictions_start date;
DECLARE @inbound_predictions_start date;


------------------------------------------------------------
-- DOMESTIC FACTS
------------------------------------------------------------
IF OBJECT_ID('tempdb..#domestic_facts') IS NOT NULL DROP TABLE #domestic_facts;

SELECT *
INTO #domestic_facts
FROM ibraheem_test.dailyData.daily_domestic_facts
WHERE date >= @start_date;

SELECT @domestic_estimates_start =
       DATEADD(DAY, 1, MAX(date))
FROM #domestic_facts;

-- SELECT * FROM #domestic_facts;


------------------------------------------------------------
-- INBOUND FACTS
------------------------------------------------------------
IF OBJECT_ID('tempdb..#inbound_facts') IS NOT NULL DROP TABLE #inbound_facts;

SELECT *
INTO #inbound_facts
FROM ibraheem_test.dailyData.daily_inbound_facts
WHERE date >= @start_date;

SELECT @inbound_estimates_start =
       DATEADD(DAY, 1, MAX(date))
FROM #inbound_facts;

-- SELECT * FROM #inbound_facts;


------------------------------------------------------------
-- DOMESTIC ESTIMATES
------------------------------------------------------------
IF OBJECT_ID('tempdb..#domestic_estimates') IS NOT NULL DROP TABLE #domestic_estimates;

SELECT *
INTO #domestic_estimates
FROM ibraheem_test.dailyData.daily_domestic_estimates
WHERE date >= @domestic_estimates_start;

SELECT @domestic_predictions_start =
       DATEADD(DAY, 1, MAX(date))
FROM #domestic_estimates;

-- SELECT * FROM #domestic_estimates;


------------------------------------------------------------
-- INBOUND ESTIMATES
------------------------------------------------------------
IF OBJECT_ID('tempdb..#inbound_estimates') IS NOT NULL DROP TABLE #inbound_estimates;

SELECT *
INTO #inbound_estimates
FROM ibraheem_test.dailyData.daily_inbound_estimates
WHERE date >= @inbound_estimates_start;

SELECT @inbound_predictions_start =
       DATEADD(DAY, 1, MAX(date))
FROM #inbound_estimates;

-- SELECT * FROM #inbound_estimates;


------------------------------------------------------------
-- DOMESTIC PREDICTIONS
------------------------------------------------------------
/*
IF OBJECT_ID('tempdb..#domestic_predictions') IS NOT NULL DROP TABLE #domestic_predictions;

SELECT *
INTO #domestic_predictions
FROM ibraheem_test.dailyData.daily_domestic_predictions
WHERE date >= @domestic_predictions_start;

-- SELECT * FROM #domestic_predictions;

*/
------------------------------------------------------------
-- INBOUND PREDICTIONS
------------------------------------------------------------
/*
IF OBJECT_ID('tempdb..#inbound_predictions') IS NOT NULL DROP TABLE #inbound_predictions;

SELECT *
INTO #inbound_predictions
FROM ibraheem_test.dailyData.daily_inbound_predictions
WHERE date >= @inbound_predictions_start;

-- SELECT * FROM #inbound_predictions;

*/
------------------------------------------------------------
-- DATES
------------------------------------------------------------
/*
SELECT
    @domestic_estimates_start     AS domestic_estimates_start,
    @inbound_estimates_start      AS inbound_estimates_start,
    @domestic_predictions_start   AS domestic_predictions_start,
    @inbound_predictions_start    AS inbound_predictions_start;
*/
------------------------------------------------------------
-- COMBINED OUTPUT (ALL TABLES, NO LABELS)
------------------------------------------------------------
DECLARE @T SYSNAME = 'all_daily_data';
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;

with combined as(
	SELECT data_type, date, year, month, day, country, purpose, daily_visits, daily_spend
	FROM #domestic_facts
	UNION ALL
	SELECT data_type, date, year, month, day, country, purpose, daily_visits, daily_spend
	FROM #inbound_facts
	UNION ALL
	SELECT data_type, date, year, month, day, country, purpose, daily_visits, daily_spend
	FROM #domestic_estimates
	UNION ALL
	SELECT data_type, date, year, month, day, country, purpose, daily_visits, daily_spend
	FROM #inbound_estimates
	/*
	UNION ALL
	SELECT data_type, date, year, month, day, country, purpose, daily_visits, daily_spend
	FROM #domestic_predictions
	UNION ALL
	SELECT data_type, date, year, month, day, country, purpose, daily_visits, daily_spend
	FROM #inbound_predictions;
	*/
), combined_with_targets as (
	SELECT
	    --c.data_type,

		PARSENAME(REPLACE(c.data_type, '_', '.'), 3) AS data_domain,
        PARSENAME(REPLACE(c.data_type, '_', '.'), 2) AS data_type,
        PARSENAME(REPLACE(c.data_type, '_', '.'), 1) AS data_source,

	    c.date,
	    c.year,
	    c.month,
	    c.day,
	    c.country,
        bu.Busines_Unit as BU,
        c.purpose,
        c.daily_visits,
	    t.daily_visits_target,
	    c.daily_spend,
	    t.daily_spend_target
	FROM combined c
	LEFT JOIN ibraheem_test.dailyData.targets t
	    ON  c.date    = t.date
	    AND c.country = t.country
	    AND c.purpose = t.purpose
	LEFT JOIN SIDR.dbo.Ref_Country cnt 
        ON cnt.Country_Name_En = c.country
    LEFT JOIN SIDR.dbo.Rel_BU_level_Country bu WITH (NOLOCK)
        ON bu.Country_Key = cnt.Country_Key
)SELECT * INTO #result FROM combined_with_targets;

EXEC ibraheem_test.dailyData.usp_UpsertDailyTable @T;







END;

