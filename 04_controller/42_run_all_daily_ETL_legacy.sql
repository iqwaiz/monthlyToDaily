/*======================================================================================================================
  Stored Procedure : dailyData.usp_run_all_daily_ETL
  Purpose          : Legacy full ETL runner — executes ALL ETL modules in hardcoded order.
                     This version predates the metadata‑driven controller.

  Usage            :
                     - Manual full rebuilds
                     - Developer testing
                     - Backward compatibility

  Notes            :
                     - This procedure is NOT used by SQL Agent.
                     - The recommended controller is:
                           usp_run_all_daily_ETL_change_driven
                     - The recommended manual full rebuild is:
                           usp_manually_run_all_daily_etl

======================================================================================================================*/

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
