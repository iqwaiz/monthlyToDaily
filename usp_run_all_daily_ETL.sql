------------------------------------------------------------
-- usp_run_all_daily_ETL
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_run_all_daily_ETL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dailyData.usp_BuildBorder;
    EXEC dailyData.usp_BuildTargets;

    EXEC dailyData.usp_BuildDaily_domestic_facts;
    EXEC dailyData.usp_BuildDaily_inbound_facts;

    EXEC dailyData.usp_BuildDaily_domestic_estimates;
    EXEC dailyData.usp_BuildDaily_inbound_estimates;

    EXEC dailyData.usp_BuildDaily_domestic_predictions;
    EXEC dailyData.usp_BuildDaily_inbound_predictions;

    EXEC dailyData.usp_build_all_daily_data;
END;

--EXEC dailyData.usp_RunAllDailyETL;
