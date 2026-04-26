------------------------------------------------------------
-- all_daily_data
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_build_all_daily_data
AS
BEGIN
    SET NOCOUNT ON;




DECLARE @start_date date = '2024-01-01';

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

SELECT * FROM #domestic_facts;


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

SELECT * FROM #inbound_facts;


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

SELECT * FROM #domestic_estimates;


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

SELECT * FROM #inbound_estimates;


------------------------------------------------------------
-- DOMESTIC PREDICTIONS
------------------------------------------------------------
IF OBJECT_ID('tempdb..#domestic_predictions') IS NOT NULL DROP TABLE #domestic_predictions;

SELECT *
INTO #domestic_predictions
FROM ibraheem_test.dailyData.daily_domestic_predictions
WHERE date >= @domestic_predictions_start;

SELECT * FROM #domestic_predictions;


------------------------------------------------------------
-- INBOUND PREDICTIONS
------------------------------------------------------------
IF OBJECT_ID('tempdb..#inbound_predictions') IS NOT NULL DROP TABLE #inbound_predictions;

SELECT *
INTO #inbound_predictions
FROM ibraheem_test.dailyData.daily_inbound_predictions
WHERE date >= @inbound_predictions_start;

SELECT * FROM #inbound_predictions;


------------------------------------------------------------
-- DATES
------------------------------------------------------------
SELECT
    @domestic_estimates_start     AS domestic_estimates_start,
    @inbound_estimates_start      AS inbound_estimates_start,
    @domestic_predictions_start   AS domestic_predictions_start,
    @inbound_predictions_start    AS inbound_predictions_start;






END;

