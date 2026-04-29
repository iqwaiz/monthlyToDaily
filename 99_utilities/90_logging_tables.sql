/* ------------------------------------------------------------
   90_logging_tables
   ------------------------------------------------------------
   Description:
     Creates logging tables for ETL module execution and errors.

   Instructions:
     Optional but recommended for production monitoring.
------------------------------------------------------------ */

--USE ibraheem_test;
--

IF OBJECT_ID('dailyData.ETL_Log') IS NOT NULL
    DROP TABLE dailyData.ETL_Log;

CREATE TABLE dailyData.ETL_Log (
    log_id        INT IDENTITY(1,1) PRIMARY KEY,
    module_name   SYSNAME,
    start_time    DATETIME NOT NULL DEFAULT GETDATE(),
    end_time      DATETIME NULL,
    status        VARCHAR(20) NOT NULL,   -- Started, Success, Failed
    error_message NVARCHAR(MAX) NULL
);

IF OBJECT_ID('dailyData.ETL_ErrorLog') IS NOT NULL
    DROP TABLE dailyData.ETL_ErrorLog;

CREATE TABLE dailyData.ETL_ErrorLog (
    error_id      INT IDENTITY(1,1) PRIMARY KEY,
    module_name   SYSNAME,
    error_time    DATETIME NOT NULL DEFAULT GETDATE(),
    error_message NVARCHAR(MAX),
    error_details NVARCHAR(MAX)
);
