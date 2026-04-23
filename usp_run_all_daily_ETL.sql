------------------------------------------------------------
-- usp_run_all_daily_ETL
------------------------------------------------------------
--USE ibraheem_test;
--
CREATE OR ALTER PROCEDURE dailyData.usp_run_all_daily_ETL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dailyData.usp_build_border;
    EXEC dailyData.usp_build_targets;

    EXEC dailyData.usp_build_daily_domestic_facts;
    EXEC dailyData.usp_build_daily_inbound_facts;

    EXEC dailyData.usp_build_daily_domestic_estimates;
    EXEC dailyData.usp_build_daily_inbound_estimates;

    EXEC dailyData.usp_build_daily_domestic_predictions;
    EXEC dailyData.usp_build_daily_inbound_predictions;

    EXEC dailyData.usp_build_all_daily_data;
END;

--EXEC dailyData.usp_run_all_daily_ETL;
